library(getopt)
library(methods)
suppressMessages(library(stringr))
suppressMessages(library(data.table))
suppressMessages(library(ggplot2))
options(error=traceback)

# get options
spec <- matrix(c(
  'input.file', 'i', 1, "character", "File containing predicted traits.",
  'cutoff', 'c', 1, "numeric", "For classification of organisms into strategies relative meassure is used to define whether a species has high or low presence of a trait. By default the 0.75 quantile is used, x>0.75 indicating high presence and x<1-0.75 low presence of a trait.",
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

if(is.null(opt$cutoff)) cutoff <- 0.75 else cutoff <- opt$cutoff


lht.dt[,gapseq_catabolism:=sum(`gapseq_Energy-Metabolism`,gapseq_Degradation), by=org]

competitive.traits.high <- c("bakta_Length","gapseq_Antibiotic.Biosynthesis","gapseq_Siderophore.Biosynthesis","gapseq_catabolism")
competition.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=competitive.traits.high]

stress.toleration.traits.low  <- c("gapseq_growth", "bakta_rRNAs")
stress.toleration.traits.high <- c("vfdb_Biofilm", "gapseq_auxotrophy")
stress.toleration.low.dt <- lht.dt[,lapply(.SD,function(x) x<quantile(x,1-cutoff)),.SDcols=stress.toleration.traits.low]
stress.toleration.high.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=stress.toleration.traits.high]
stress.toleration.dt <- cbind(stress.toleration.low.dt, stress.toleration.high.dt)

ruderal.traits.low <- c("gapseq_catabolism")
ruderal.traits.high <- c("bakta_rRNAs", "gapseq_growth", "grodon_CUB")
ruderal.low.dt <- lht.dt[,lapply(.SD,function(x) x<quantile(x,1-cutoff)),.SDcols=ruderal.traits.low]
ruderal.high.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=ruderal.traits.high]
ruderal.dt <- cbind(ruderal.low.dt, ruderal.high.dt)

csr.dt <- data.table(org=lht.dt$org, competition=rowSums(competition.dt), stress.toleration=rowSums(stress.toleration.dt), ruderal=rowSums(ruderal.dt))
csr.dt[,csr:=paste0(colnames(csr.dt)[-1][which(.SD==max(.SD))],collapse=","), by=org, .SDcols=is.numeric]

fwrite(csr.dt, paste0("csr-",cutoff,".csv"))


coord.lst <- list("competition"=c(-1,0), "stress.toleration"=c(0,1), ruderal=c(1,0))
csr.coord <- lapply(csr.dt$csr, function(csr) Reduce("+",coord.lst[unlist(str_split(csr,","))]))
csr.dt <- cbind(csr.dt, data.table(x=sapply(csr.coord, function(x) x[1]), y=sapply(csr.coord, function(x) x[2])))
csr.dt[grepl(",",csr), `:=`(x=x/2, y=y/2)]
p <- ggplot(csr.dt) + geom_jitter(width=0.05,height=0.05,aes(x=x,y=y)) + geom_polygon(data=data.frame(x=c(-1,1, 0), y=c(0,0,1)), aes(x=x,y=y), alpha=0.1, fill="blue") + annotate(geom="text", x=c(-1.1,0,1.1),y=c(0,1.05,0), label=c("S","C","R"), color="red", size=10) + xlab("") + ylab("") + theme_minimal(base_size=14)
ggsave(plot=p, filename=paste0("csr-",cutoff,".pdf"))
