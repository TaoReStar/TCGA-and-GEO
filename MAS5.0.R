rm(list=ls())
library(GEOquery)
library(reshape)
library(affy)

##MCF10A
cha_st='GSE6784'
##MDA-MB231
cha_st='GSE44024'
##MCF-7
cha_st='GSE6462'
gse <- getGEO(cha_st,GSEMatrix=FALSE, destdir=".")
gseplatforms <- lapply(GSMList(gse),function(x) {Meta(x)$platform})
GPL=unique(unlist(gseplatforms))
print((GPL))
s=getGEOSuppFiles(cha_st)
aa1=GSMList(gse)
setwd()
untar(paste(cha_st,"_RAW.tar",sep=""), exdir="data")
cels = list.files("data/", pattern = "CEL|cel")
if(length(cels)>0)
{
	if(length(grep(".CEL$|.cel$",cels)) <1)
	{
		sapply(paste("data", cels, sep="/"), gunzip)
	}
	else
	{
		system("rm data/*.gz")
	}
}

cels0 = list.files(paste("~/CCLE",cha_st,"data/",sep="/"), pattern = "CEL$|cel$")
cels0.gse = sapply(strsplit(cels0,split="_"),"[[",1)
cels0.gse = sapply(strsplit(cels0.gse,split="[.]"),"[[", 1)
cels0.gpl = unlist(gseplatforms[][match(cels0.gse, names(gseplatforms))])
cels0.gpl.uniq = unique(cels0.gpl)
for(j in 1:length(cels0.gpl.uniq))
{
	if(cels0.gpl.uniq[j]=="GPL90")
	{
		setwd()
		cels=cels0[cels0.gpl==cels0.gpl.uniq[j]]
		raw.data=ReadAffy(filenames=cels0)
		data.rma.norm=mas5(raw.data)
		ned <- exprs(data.rma.norm)
		data.matrix=ned
		colnames(data.matrix) = sapply(strsplit(colnames(ned), split="_"),"[[",1)
		colnames(data.matrix) = sapply(strsplit(colnames(data.matrix), split="[.]"),"[[",1)
		setwd()
		save(data.matrix, file=paste(cha_st, cels0.gpl.uniq[j], "MAS5_normalized.RData", sep="_"))
	}
}
rm(list=ls())

setwd()

for(i in 1:length(GPL)
{
	if(GPL[i]=="GPL570")
	{
		ID.gpl=names(gseplatforms[gseplatforms==GPL[i]])
		aa=aa1[gseplatforms==GPL[i]]
		probesets <- Table(aa[[1]])$ID
		data.matrix <- do.call('cbind',lapply(aa,function(x){tab <- Table(x); mymatch <- match(probesets,tab$ID_REF); return(tab$VALUE[mymatch])}))
		data.matrix <- apply(data.matrix,2,function(x) {as.numeric(as.character(x))})
		rownames(data.matrix) <- probesets
		colnames(data.matrix)=sapply(strsplit(colnames(ned),split="_"),"[[",1)
		colnames(data.matrix)=sapply(strsplit(colnames(data.matrix),split="[.]"),"[[",1)
		save(data.matrix, file=paste(cha_st,GPL[i], "noMAS5_immu.RData", sep="_"))
	}
}
	
