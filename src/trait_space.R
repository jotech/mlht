library(getopt)
library(methods)
suppressMessages(library(stringr))
suppressMessages(library(data.table))
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
cat("Constant traits found: ", ncol(lht.mat.org)-ncol(lht.mat), "\n")

# Dimensionality
pca <- prcomp(lht.mat, center=T, scale=T)
pca.sum <- summary(pca)
dim.full <- min(which(pca.sum$importance[3,]==1))
dim.half <- min(which(pca.sum$importance[3,]>0.5))
cat("Principal components needed to explain all variance : ", dim.full, "\n")
cat("Principal components needed to explain half variance: ", dim.half, "\n")

# Structure (clustering)
gap.stat <- cluster::clusGap(lht.mat, FUN=kmeans, nstart=25, K.max=15, B=50)
km.clust.local <- cluster::maxSE(f=gap.stat$Tab[,"gap"], SE.f=gap.stat$Tab[,"SE.sim"], method="firstSEmax", SE.factor=1)
km.clust.global <- cluster::maxSE(f=gap.stat$Tab[,"gap"], SE.f=gap.stat$Tab[,"SE.sim"], method="globalSEmax", SE.factor=1)
cat("Kmeans cluster found by gap statistics (local) : ", km.clust.local, "\n")
cat("Kmeans cluster found by gap statistics (global): ", km.clust.global, "\n")
km.final <- kmeans(lht.mat, centers=km.clust.global, nstart=25)
p <- factoextra::fviz_cluster(km.final, data=lht.mat)
ggplot2::ggsave(p, file="./cluster.pdf")

# Robustness
