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
  'growth.type', 'g', 1, "character", "Trait used for growth rate prediction [fba,cub] (defailt: fba)",
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

# functions returns the most frequent strings from a list of strings separated by ','
get_max_str <- function(x){ 
  tab <- table(unlist(str_split(x, ",")))
  max_str <- paste0(names(which(tab == max(tab))), collapse = ",")
  return(max_str)
}

input.file <- opt$input.file
if( !file.exists(input.file) ) stop("Input file not found.")
lht.dt <- fread(input.file)

if(is.null(opt$cutoff)) cutoff_range <- c(0.7, 0.75, 0.8) else cutoff_range <- c(opt$cutoff - 0.05, opt$cutoff, opt$cutoff + 0.05) # check increase/decrease of cutoff for stability
if(is.null(opt$growth.type)) growth.type <- "fba" else growth.type <- opt$growth.type

if(growth.type == "fba"){
  growth.trait <- "gapseq_growth"
}else if(growth.type == "cub"){
  lht.dt[, grodon_r:=log(2)/grodon_d]
  growth.trait <- "grodon_r"
}else stop("Invalid growth type")

csr.dt  <-  data.table(org=lht.dt$org)
for(cutoff in cutoff_range){
    lht.dt[,gapseq_catabolism:=sum(`gapseq_meta.Energy-Metabolism`,gapseq_meta.Degradation), by=org]

    competitive.traits.high <- c("bakta_Length","gapseq_meta_antibiotic.biosynthesis","gapseq_meta_siderophore.biosynthesis","gapseq_catabolism")
    competition.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=competitive.traits.high]

    stress.toleration.traits.low  <- c(growth.trait, "bakta_rRNAs")
    stress.toleration.traits.high <- c("vfdb_Biofilm", "gapseq_auxotrophy")
    stress.toleration.low.dt <- lht.dt[,lapply(.SD,function(x) x<quantile(x,1-cutoff)),.SDcols=stress.toleration.traits.low]
    stress.toleration.high.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=stress.toleration.traits.high]
    stress.toleration.dt <- cbind(stress.toleration.low.dt, stress.toleration.high.dt)

    ruderal.traits.low <- c("gapseq_catabolism")
    ruderal.traits.high <- c("bakta_rRNAs", growth.trait, "grodon_CUB")
    ruderal.low.dt <- lht.dt[,lapply(.SD,function(x) x<quantile(x,1-cutoff)),.SDcols=ruderal.traits.low]
    ruderal.high.dt <- lht.dt[,lapply(.SD,function(x) x>quantile(x,cutoff)),.SDcols=ruderal.traits.high]
    ruderal.dt <- cbind(ruderal.low.dt, ruderal.high.dt)

    tmp.dt <- data.table(org=lht.dt$org, c=rowSums(competition.dt), s=rowSums(stress.toleration.dt), r=rowSums(ruderal.dt))
    tmp.dt[,csr:=paste0(colnames(tmp.dt)[-1][which(.SD==max(.SD))],collapse=","), by=org, .SDcols=is.numeric]
    colnames(tmp.dt)[-1] <- paste0(colnames(tmp.dt)[-1], "_", cutoff)
    csr.dt <- merge(csr.dt, tmp.dt, by="org")
}
csr.dt[, csr := get_max_str(.SD), by=org, .SDcols=grep("csr_", colnames(csr.dt))]
cn <- colnames(csr.dt)
setcolorder(csr.dt, c("org", sort(grep("^(c|s|r)_", cn, value=TRUE)), sort(grep("csr_", cn, value=TRUE)), "csr")) # rearrange column order
fwrite(csr.dt, paste0("csr-", growth.type, ".csv"))


coord.lst <- list(c=c(-1,0), s=c(0,1), r=c(1,0))
csr.coord <- lapply(csr.dt$csr, function(csr) Reduce("+",coord.lst[unlist(str_split(csr,","))]))
csr.dt <- cbind(csr.dt, data.table(x=sapply(csr.coord, function(x) x[1]), y=sapply(csr.coord, function(x) x[2])))
csr.dt[grepl(",",csr), `:=`(x=x/2, y=y/2)]
p <- ggplot(csr.dt) + geom_jitter(width=0.05,height=0.05,aes(x=x,y=y)) + geom_polygon(data=data.frame(x=c(-1,1, 0), y=c(0,0,1)), aes(x=x,y=y), alpha=0.1, fill="blue") + annotate(geom="text", x=c(-1.1,0,1.1),y=c(0,1.05,0), label=c("S","C","R"), color="red", size=10) + xlab("") + ylab("") + theme_minimal(base_size=14)
ggsave(plot = p, filename = paste0("csr-", growth.type, ".pdf"))
