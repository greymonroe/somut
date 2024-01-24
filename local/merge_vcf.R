# load necessary libraries
directory="~/Documents/4_strelka_organized/"

library(polymorphology2)
require(data.table)

bp <- c("A","C","G","T") # base pairs

normals <- list.files(directory, full.names = FALSE)
normals<-normals[!normals %in% c("WT_10","atx12r7_F4_11","atx12r7_F4_10", "WT_9")]
tumors <- normals

results <- rbindlist(lapply(tumors, function(tumor){
  message("Processing normal sample: ", tumor)
  mutations <- rbindlist(lapply(normals, function(norm){
    if (norm != tumor){
      message("\tComparing with tumor sample: ", norm)
      vcf_file<-paste0(directory, tumor, "/", norm, "/results/variants/somatic.snvs.vcf.gz")
      if(file.exists(vcf_file)){
        calls <- read.VCF(paste0(directory, tumor, "/", norm, "/results//variants/somatic.snvs.vcf.gz"), caller = "strelka2")
        message("\t\tcalls:", nrow(calls))
      } else return(NULL)
      calls[, c("NORMAL_SAMPLE", "TUMOR_SAMPLE") := .(norm, tumor)]
      return(calls)
    }
  }))
  
  if(nrow(mutations)==0) return(NULL)
  message("Processing mutations for sample: ", tumor)
  mutations[, unique := paste(CHROM, POS, ALT,sep = "_")]
  mutations[,PASS_N:=.N, by=.(unique, FILTER)]
  return(unique_mut)
}))

# results[, tumor_unique := paste(CHROM, POS, ALT,sep = "_")]
# counts<-data.table(table(tumor_unique=results$tumor_unique, TUMOR_SAMPLE=results$TUMOR_SAMPLE))[N>0]
# counts<-data.table(table(tumor_unique=counts$tumor_unique))[N==1]
results[, N := .N, by = .(unique)]

PASS<-results[N==15]
PASS <- PASS[FILTER == "PASS"]
PASS[, Tumor_N_PASS := .N, by = .(tumor_unique_PASS=paste(CHROM, POS, ALT,TUMOR_SAMPLE,sep = "_"))]
ggplot(PASS, aes(x=Tumor_N_PASS))+
  geom_histogram(bins=100)+
  facet_grid(~TUMOR_SAMPLE)
PASS2<-PASS[Tumor_N_PASS==15]
PASS2[, minEVS := min(EVS), by = .(unique)]

PASS2$trimer<-tricontexts(PASS2, genome)
PASS2$mut<-paste0(substr(PASS2$trimer, 2, 2),">", substr(PASS2$trimer, 6, 6))

plot_tricontexts(PASS2$trimer, full=F)

PASS2[unique=="1_6126842_G"]


PASS[,.(max(Tumor_N_PASS)), by=TUMOR_SAMPLE]

table(PASS$TUMOR_SAMPLE, PASS$NORMAL_SAMPLE)

PASS3<-unique(PASS2[minEVS>8,.(CHROM, POS, trimer, TUMOR_SAMPLE, minEVS)])
plot_tricontexts(PASS3$trimer, full=F)


ggplot(PASS2, aes(y=minEVS, x=mut))+
  geom_boxplot()+
  facet_grid(~TUMOR_SAMPLE)

PASS2[, unique2 := paste(unique, TUMOR_SAMPLE, sep = "_")]


PASS2$tumor_ref_depth<-as.numeric(apply(PASS2, 1, function(x) unlist(strsplit(unlist(strsplit(x["TUMOR"], split = ":"))[4+which(bp==x["REF"])],split=","))[1]))
PASS2$tumor_alt_depth<-as.numeric(apply(PASS2, 1, function(x) unlist(strsplit(unlist(strsplit(x["TUMOR"], split = ":"))[4+which(bp==x["ALT"])],split=","))[1]))

PASS2$normal_ref_depth<-as.numeric(apply(PASS2, 1, function(x) unlist(strsplit(unlist(strsplit(x["NORMAL"], split = ":"))[4+which(bp==x["REF"])],split=","))[1]))
PASS2$normal_alt_depth<-as.numeric(apply(PASS2, 1, function(x) unlist(strsplit(unlist(strsplit(x["NORMAL"], split = ":"))[4+which(bp==x["ALT"])],split=","))[1]))

u=PASS2$unique[1]
PASS2_chi_EVS<-rbindlist(lapply(unique(PASS2$unique), function(x){
  u<-PASS2[unique==x]
  normal_alt_depth=sum(u$normal_alt_depth)
  normal_ref_depth=sum(u$normal_ref_depth)
  tumor_alt_depth=sum(u$tumor_alt_depth)
  tumor_ref_depth=sum(u$tumor_ref_depth)
  chi<-chisq.test(matrix(c(normal_alt_depth, normal_ref_depth, tumor_alt_depth, tumor_ref_depth), nrow=2))
  return(data.table(u, p=chi$p.value))
  
}))

ggplot(PASS2_chi_EVS, aes(x=minEVS, y=-log10(p), col=mut))+
  geom_point()

PASS3<-unique(PASS2[minEVS>8,.(CHROM, POS, trimer, TUMOR_SAMPLE, minEVS)])
plot_tricontexts(PASS3$trimer, full=F)


PASS2[, tumor_depth := tumor_ref_depth + tumor_alt_depth]

PASS2[, depth_pct := tumor_alt_depth / tumor_depth]

PASS2 <- unique(PASS2[, .(CHROM, POS, REF, ALT, TUMOR_SAMPLE, unique, tumor_alt_depth, tumor_depth, depth_pct, N, EVS = mean(EVS)), by=unique2])

message("Calculating Chi-square tests and distances...")
PASS2[, chi := apply(.SD, 1, function(x) chisq.test(c(as.numeric(x["tumor_alt_depth"]), as.numeric(x["tumor_depth"]) - as.numeric(x["tumor_alt_depth"])))$p.value)]

PASS2[, dist := sapply(1:.N, function(i) {
  x <- .SD[i]
  chr <- x[["CHROM"]]
  POS <- as.numeric(x[["POS"]])
  f <- x[["TUMOR_SAMPLE"]]
  dist <- PASS2[CHROM == chr & TUMOR_SAMPLE == f]$POS - POS
  min(abs(dist[dist != 0]))
})]

message("Classifying mutation types...")
PASS2[, type := ifelse(depth_pct > 0.5 & chi < 0.05, "homozygous", "somatic")]
PASS2[type == "somatic" & chi > 0.001, type := "heterozygous"]

PASS2 <- PASS2[!duplicated(unique2)]

table(PASS2$TUMOR_SAMPLE, PASS2$type)

hist(PASS2$depth_pct)

PASS2[, minEVS := min(EVS), by = .(unique)]

PASS2$trimer<-tricontexts(PASS2, genome)
PASS2$mut<-paste0(substr(PASS2$trimer, 2, 2),">", substr(PASS2$trimer, 6, 6))

ggplot(PASS2, aes(y=minEVS, x=TUMOR_SAMPLE))+
  geom_boxplot()

genes<-fread("~/repos/Atdamagescreen/arabidopsis_genes.csv")

PASS3<-unique(PASS2[mut!="C>G" & minEVS>1,.(CHROM, POS, trimer, TUMOR_SAMPLE, minEVS)])
PASS3$ID<-1:nrow(PASS3)
PASS3_genic<-features_in_sites(genes, PASS3)
PASS3$genic<-PASS3_genic$overlaps[match(PASS3$ID, PASS3_genic$ID)]

table(PASS3$genic, PASS3$TUMOR_SAMPLE)

PASS<-results[EVS>12]
PASS$ID<-1:nrow(PASS)
PASS_genic<-features_in_sites(genes, PASS)
PASS$genic<-PASS_genic$overlaps[match(PASS$ID, PASS_genic$ID)]

PASS[, minEVS := min(EVS), by = .(unique)]

PASS3<-unique(PASS[,.(CHROM, POS, REF, ALT, TUMOR_SAMPLE, genic, EVS=mean(EVS), unique), by=unique])
PASS3$GT<-grepl("WT", PASS3$TUMOR_SAMPLE)

chisq.test(table(genic=PASS3$genic,GT=PASS3$GT))

ggplot(PASS3, aes())

PASS3$trimer<-tricontexts(PASS3, genome)
PASS3$mut<-paste0(substr(PASS3$trimer, 2, 2),">", substr(PASS3$trimer, 6, 6))

PASS3[,N :=.N, by=unique]
PASS3$single<-PASS3$N==1

ggplot(PASS3[GT==T,2:ncol(PASS3)], aes(x=mut, y=EVS, fill=mut, group=mut))+
  geom_boxplot()+
  facet_grid(ifelse(single,"single","multiple")~ifelse(genic,"genic","intergenic"))

ggplot(PASS3[GT==F,2:ncol(PASS3)], aes(x=mut, y=EVS, fill=mut, group=mut))+
  geom_boxplot()+
  facet_grid(ifelse(single,"single","multiple")~ifelse(genic,"genic","intergenic"))


hist(PASS3$N, breaks=20)

PASS4<-PASS3[(GT==T & N==8)  | (GT==F & N==3)]
chisq.test(table(genic=PASS4$genic,GT=PASS4$GT))

PASS4<-unique(PASS3[mut!="C>G"])
chisq.test(table(genic=PASS4$genic,GT=PASS4$GT))
table(mut=PASS4$mut, WT=PASS4$GT, genic=PASS4$genic)

counts<-data.table(table(mut=PASS4$mut, WT=PASS4$GT, genic=PASS4$genic, sum=PASS4$N==1))
ggplot(counts, aes(x=sum, y=N, fill=mut))+
  geom_bar(stat="identity")+
  facet_grid(WT~genic)

ggplot(PASS3[,2:ncol(PASS3)], aes(x=sum, y=N, fill=mut))+
  geom_bar(stat="identity")+
  facet_grid(WT~genic)

table(PASS4$unique, PASS4$TUMOR_SAMPLE)
PASS4[,.N:=.N, by=unique]

plot(plot_tricontexts(PASS4$trimer, full=F)$plot)

PASS$GT<-grepl("WT", PASS$TUMOR_SAMPLE)
PASS3<-unique(PASS[,.(CHROM, POS, REF, ALT, GT, genic, minEVS, unique)])

chisq.test(table(genic=PASS3$genic,GT=PASS3$GT))

PASS3$trimer<-tricontexts(PASS3, genome)
PASS3$mut<-paste0(substr(PASS3$trimer, 2, 2),">", substr(PASS3$trimer, 6, 6))

PASS3[,N :=.N, by=unique]

hist(PASS3$N, breaks=20)
PASS3[N==10]
PASS4<-PASS3[mut!="C>G"]
chisq.test(table(genic=PASS4$genic,GT=PASS4$GT))



for(Tu in unique(PASS3$TUMOR_SAMPLE)){
plot(plot_tricontexts(PASS3[TUMOR_SAMPLE==Tu]$trimer, full=F)$plot+ggtitle(Tu))
}
