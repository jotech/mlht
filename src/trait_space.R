library(getopt)
library(methods)
suppressMessages(library(stringr))
suppressMessages(library(data.table))
suppressMessages(library(Matrix))
suppressMessages(library(coRanking))
suppressMessages(library(ggplot2))
#suppressMessages(library(cobrar))
options(error=traceback)

# get options
spec <- matrix(c(
  'input.file', 'i', 1, "character", "File containing predicted traits.",
  'help' , 'h', 0, "logical", "help"
), ncol = 5, byrow = T)

opt <- getopt(spec)

# Help Screen
if ( !is.null(opt$help) | is.null(opt$input.file)) {
  cat(getopt(spec, usage=TRUE))
  
  cat("\n")
  cat("Details:\n")
  q(status=1)
}

input.file <- opt$input.file
if( !file.exists(input.file) ) stop("Input file not found.")

lht.dt <- fread(input.file)
lht.mat.org <- data.matrix(lht.dt)
lht.mat <- lht.mat.org[,apply(lht.mat.org, 2, function(x){(length(unique(x))>1)})] # remove constant rows

cat("Organisms found: ", nrow(lht.dt), "\n")
cat("Traits found: ", ncol(lht.dt), "\n")
cat("Constant traits found: ", ncol(lht.mat.org)-ncol(lht.mat), "(will be removed)\n")

# Sparsity
rank <- as.numeric(rankMatrix(lht.mat))
cat("Rank:", rank, "\n")
sparsity <- 1 - rank / ncol(lht.mat)
cat("Sparsity:", sparsity, "\n")

# Dimensionality
pca <- prcomp(lht.mat, center=T, scale=T)
pca.sum <- summary(pca)
dim.full <- min(which(pca.sum$importance[3,]==1))
dim.half <- min(which(pca.sum$importance[3,]>0.5))
cat("Principal components needed to explain all variance : ", dim.full, "\n")
cat("Principal components needed to explain half variance: ", dim.half, "\n")

# co-ranking matrix based estimation of dimension reduction quality
co_mat <- coRanking::coranking(dist(lht.mat), dist(pca$x), input_Xi = "dist")
nx <- coRanking::R_NX(co_mat)
auc <- coRanking::AUC_ln_K(nx)
cat("Overall quality of dimension reduction:", auc, "\n")
cat("Quality of lower dimensions:\n")
corank_dt <- data.table()
for(i in 2:20){
  co_mat <- coRanking::coranking(dist(lht.mat), dist(pca$x[,1:i]), input_Xi = "dist")
  nx <- coRanking::R_NX(co_mat)
  auc <- coRanking::AUC_ln_K(nx)
  corank_dt <- rbind(corank_dt, data.table(dim=i, auc))
}
print(corank_dt[c(1,4,9,14,19)])


# Structure (clustering)
gap.stat <- cluster::clusGap(lht.mat, FUN=kmeans, nstart=25, K.max=15, B=50)
km.clust.local <- cluster::maxSE(f=gap.stat$Tab[,"gap"], SE.f=gap.stat$Tab[,"SE.sim"], method="firstSEmax", SE.factor=1)
#km.clust.global <- cluster::maxSE(f=gap.stat$Tab[,"gap"], SE.f=gap.stat$Tab[,"SE.sim"], method="globalSEmax", SE.factor=1)
cat("Kmeans cluster found by gap statistics (local) : ", km.clust.local, "\n")
#cat("Kmeans cluster found by gap statistics (global): ", km.clust.global, "\n")
km.final <- kmeans(lht.mat, centers=km.clust.local, nstart=25)
p <- factoextra::fviz_cluster(km.final, data=lht.mat)
suppressMessages(ggplot2::ggsave(p, file="./cluster.pdf"))

# Robustness
robust_dt <- data.table()
for(omit in 10 * c(1:8)){
  for(i in 1:100){
    omit_idx  <- sample( 1:ncol(lht.mat), floor(omit*ncol(lht.mat)/100), replace = FALSE)
    lht_omit  <- lht.mat[,-omit_idx]
    co_omit   <- coRanking::coranking(dist(lht.mat), dist(lht_omit), input_Xi = "dist")
    rnx_omit  <- coRanking::R_NX(co_omit)
    auc_omit  <- coRanking::AUC_ln_K(rnx_omit)
    robust_dt <- rbind(robust_dt, data.table(omit, i, auc_omit))
  }
}  
p2 <- ggplot2::ggplot(robust_dt, aes(x=omit, y=auc_omit, group=omit)) + 
  geom_boxplot() + ylim(0, 1) +
  theme_minimal(base_size=14) +
  xlab("Omitted traits (%)") + ylab("AUC")
suppressMessages(ggplot2::ggsave(p2, file="./robustness.pdf"))
fwrite(robust_dt, "./robustness.csv")
cat("Robustness when omitting traits (%)\n")
print(robust_dt[,list(AUC=median(auc_omit)),by=omit])
