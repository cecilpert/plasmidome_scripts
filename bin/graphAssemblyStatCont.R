library(ggplot2)
library(svglite)
library(grid) 

args = commandArgs(trailingOnly=TRUE) 

if (length(args)!=5) {
  stop("usage : RScript --vanilla graphs.R <length file> <contigs file> <plasmids file> <outdir> <prefix>", call.=FALSE)
}


outputName <- function(outdir,prefix,suffix){
	g=paste(outdir,prefix,sep="/")
	g=paste(g,suffix,sep="") 
	return(g)   
}

f=read.table(args[1],header=TRUE,sep="\t")
f_contigs=read.table(args[2],header=TRUE,sep="\t")
f_plasmids=read.table(args[3],header=TRUE,sep="\t")
f$Contamination=factor(f$Contamination,levels=c("0%","5%","10%","20%"))
f_plasmids$Contamination=factor(f_plasmids$Contamination,levels=c("0%","5%","10%","20%"))
f_contigs$Contamination=factor(f_contigs$Contamination,levels=c("0%","5%","10%","20%"))
f$Assembly=factor(f$Assembly,levels=c("megahit","metaspades","spades","hybridspades","unicycler")) 
f_contigs$Assembly=factor(f_contigs$Assembly,levels=c("megahit","metaspades","spades","hybridspades","unicycler")) 
f_plasmids$Assembly=factor(f_plasmids$Assembly,levels=c("megahit","metaspades","spades","hybridspades","unicycler")) 


outdir=args[4]
prefix=args[5]

N50=ggplot(f,aes(x=Assembly,fill=Assembly,y=N50.good.contigs))+geom_bar(stat="identity")+labs(y="N50 (bp)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(~Contamination) 

max_contig=ggplot(f,aes(x=Assembly,fill=Assembly,y=Max.good.contig.length))+geom_bar(stat="identity")+labs(y="Largest contig (bp)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(~Contamination)   

misassembled_contigs=ggplot(f,aes(x=Assembly,fill=Assembly,y=Misassembled.length))+geom_bar(stat="identity")+labs(y="Misassembled contigs (bp)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(~Contamination)  

misassembled_contigs_percent=ggplot(f,aes(x=Assembly,fill=Assembly,y=Misassembled.length/Total.length*100))+geom_bar(stat="identity")+labs(y="Misassembled contigs (%)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +ylim(0,100)+facet_grid(~Contamination) 

contigsLength=ggplot(f_contigs,aes(x=Assembly,fill=Contig,y=Length))+geom_bar(stat="identity")+scale_fill_manual(values=c("lightgreen","limegreen","red","purple","blue"))+labs(y="Length (bp)")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+facet_grid(~Contamination)
contigsNumber=ggplot(f_contigs,aes(x=Assembly,fill=Contig,y=Number))+geom_bar(stat="identity")+scale_fill_manual(values=c("lightgreen","limegreen","red","purple","blue"))+labs(t="Number of contigs")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+facet_grid(~Contamination) 

refCov=ggplot(f_plasmids,aes(x=Assembly,y=Aligned_length/Length*100,fill=Assembly))+geom_boxplot()+labs(y="Reference coverage(%)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(~Contamination) 

f_complet=subset(f_plasmids,f_plasmids$Status=="complete") 

completePlasmids=ggplot(f_complet,aes(x=Assembly,fill=Assembly))+geom_bar()+geom_hline(yintercept=1828)+labs(y="Number of complete plasmids")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(~Contamination) 

completePlasmidsPercentLength=ggplot(f,aes(x=Assembly,fill=Assembly,y=X.Plasmids.complete..length.))+geom_bar(stat="identity")+labs(y="Complete plasmids (%Length)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +ylim(0,100)+facet_grid(~Contamination) 

#Abundance 
#Separate into 4 equal parts 

first=subset(f_plasmids,f_plasmids$Abundance<unname(quantile(f_plasmids$Abundance)["25%"]))
second=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["25%"]))
second=subset(second,second$Abundance<unname(quantile(f_plasmids$Abundance)["50%"]))
third=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["50%"]))
third=subset(third,third$Abundance<unname(quantile(f_plasmids$Abundance)["75%"]))
fourth=subset(f_plasmids,f_plasmids$Abundance>=unname(quantile(f_plasmids$Abundance)["75%"]))

first$Cat="<0.051" 
second$Cat="0.051-0.053" 
third$Cat="0.053-0.057" 
fourth$Cat=">=0.057"

f_plasmids=rbind(first,second,third,fourth) 
f_plasmids$Cat=factor(f_plasmids$Cat,levels=c(">=0.057","0.053-0.057","0.051-0.053","<0.051"))

abundance=ggplot(f_plasmids,aes(x=Cat,y=Aligned_length/Length*100))+geom_boxplot()+labs(y="Reference coverage(%)",x="Abundance")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14))+coord_flip()+facet_grid(Contamination~.)

abundanceDetailed=ggplot(f_plasmids,aes(x=Cat,y=Aligned_length/Length*100,fill=Assembly))+geom_boxplot()+labs(y="Reference coverage(%)",x="Abundance")+theme(axis.text.x=element_text(size=14),axis.title.x=element_text(size=14),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+coord_flip()+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler")) +facet_grid(Contamination~.)

contamination=ggplot(f,aes(x=Assembly,fill=Assembly,y=Contamination.length/Total.length*100))+geom_bar(stat="identity")+labs(y="Contaminated contigs (%)")+theme(axis.text.x=element_blank(),axis.title.x=element_blank(),axis.ticks.x=element_blank(),axis.title.y=element_text(size=14),axis.text.y=element_text(size=14),legend.text=element_text(size=14),legend.title=element_text(size=14))+scale_fill_discrete(labels=c("Megahit","MetaSPAdes","SPAdes","HybridSPAdes","Unicycler"))+facet_grid(~Contamination) 

outN50=outputName(outdir,prefix,".N50.svg") 
outMax=outputName(outdir,prefix,".MaxContig.svg") 
outMis=outputName(outdir,prefix,".MisassembledContigs.svg") 
outMisPercent=outputName(outdir,prefix,".MisassembledContigsPercent.svg") 
outContigLength=outputName(outdir,prefix,".AllContigsLength.svg") 
outContigNumber=outputName(outdir,prefix,".AllContigsNumber.svg") 
outRefCov=outputName(outdir,prefix,".RefCov.svg")
outCompPlas=outputName(outdir,prefix,".completePlasmids.svg") 
outCompPlasPerc=outputName(outdir,prefix,".completePlasmidsPercent.svg") 
outAbundanceDetailed=outputName(outdir,prefix,".AbundanceDetailed.svg") 
outAbundance=outputName(outdir,prefix,".Abundance.svg")
outContamination=outputName(outdir,prefix,".ContaminationPercent.svg") 

ggsave(file=outN50, plot=N50, width=10, height=8)
ggsave(file=outMax,plot=max_contig,width=10,height=8) 
ggsave(file=outMis,plot=misassembled_contigs,width=10,height=8) 
ggsave(file=outMisPercent,plot=misassembled_contigs_percent,width=10,height=8) 
ggsave(file=outContigLength,plot=contigsLength,width=10,height=8) 
ggsave(file=outContigNumber,plot=contigsNumber,width=10,height=8) 
ggsave(file=outRefCov,plot=refCov,width=10,height=8) 
ggsave(file=outCompPlas,plot=completePlasmids,width=10,height=8) 
ggsave(file=outCompPlasPerc,plot=completePlasmidsPercentLength,width=10,height=8)
ggsave(file=outAbundance,plot=abundance,width=10,height=8) 
ggsave(file=outAbundanceDetailed,plot=abundanceDetailed,width=10,height=8) 
ggsave(file=outContamination,plot=contamination,width=10,height=8) 
