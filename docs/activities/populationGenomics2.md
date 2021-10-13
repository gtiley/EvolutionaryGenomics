---
layout: page
title: Variant Calling and Filtering
permalink: /labs/populationGenomics2/
---

Today will be a little different - we are still waiting for genotyping to finish. We will try to push last week along, but also have a look ahead at some PCA and sliding window analyses for some unrelated data.

Today, you will download a VCF for mouse lemurs from the cluster to your local maschine. We will do a little work with [vcftools](https://vcftools.github.io/index.html), which you will need to download and install. We will use several R packages too. 

```
cd ~/evolutionaryGenomics
scp -r YOUR_NETID@duke.oit.duke.edu:/hpc/group/bio790s-01-f21/evolutionaryGenomics/populationGenomics2 .
```

A few steps in vcf tools. We use it in our genotyping discussion to kick out low-quality variants. We can also use it to thin out SNPs in LD (needed for some structure analyses) and sliding window analyses. The sliding window analyses are based on population pairs, for which the individuals are put into a list from a larger metadata table.
```
~/programs/vcftools/build/bin/vcftools --vcf populations.snps.filtered06.mac3.noOut.noinvar.vcf --thin 10000 --recode --out populations.snps.filtered06.mac3.noOut.noinvar.thin10k
grep Ankafobe populationMetadata.txt | cut -d $'\t' -f 1 > ankafobe.list
grep Ambatovy populationMetadata.txt | cut -d $'\t' -f 1 > ambatovy.list
~/programs/vcftools/build/bin/vcftools --vcf populations.snps.filtered06.mac3.noOut.noinvar.vcf --weir-fst-pop ankafobe.list --weir-fst-pop ambatovy.list --fst-window-size 1000000 --out ankafobe_vs_ambatovy_FST_1Mb
```

The thinned VCF can now be used for some PCA analyses. We skip the admixture analyses for now, but the input data for that would be the same as the thinned VCF, but as a ped (PLINK format). An R file with the commands will have been downloaded too.

``` R
setwd("~/branch/yoderlab/mleh2/data")
library(vcfR)
library(dartR)
library(adegenet)
#library(vegan)
#library(poppr)
#library(hierfstat)

vcf <- read.vcfR("populations.snps.filtered06.mac3.noOut.noinvar.thin10k.recode.vcf")
gl <- vcfR2genlight(vcf)
ploidy(gl) <- 2
metadata <- read.table("populationMetadata.txt",header=TRUE,sep="\t")
#pop(gl) <- as.factor(c("Marojejy","Marojejy","Anjanaharibe","Anjanaharibe","Anjanaharibe","Anjanaharibe","Marojejy","Ambatovy","Ambatovy","Ambohitantely","Ambohitantely","Ambohitantely","Ambohitantely","Ambatovy","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ankafobe","Ambatovy","Ambatovy","Ambatovy","Ambatovy","Riamalandy","Riamalandy","Tsinjoarivo","Tsinjoarivo","Tsinjoarivo","Tsinjoarivo","Tsinjoarivo","Ambavala","Ambavala","Ambavala","Ambavala","Ambavala","Ambavala","Ambavala","Anjozorobe","Ambatovy","Ambatovy","Anjiahely","Anjiahely","Anjiahely","Anjiahely","Anjiahely"))
pop(gl) <- metadata$Population
strata(gl) <- metadata[4:6]

####
#Colors
#Marojejy	#0A253B
#Anjanaharibe	#235179
#Anjiahely	#3E7DBB
#Ambavala	#67488B
#Riamalandy	#565676
#Ambatovy	#C90000
#Anjozorobe	#EB7C05
#Tsinjoarivo	#E09406
#Ambohitantely	#BA7839
#Ankafobe	#92583F
####

popLabels <- c("Marojejy","Anjanaharibe","Anjiahely","Ambavala","Riamalandy","Ambatovy","Anjozorobe","Tsinjoarivo","Ambohitantely","Ankafobe")
popColors <- c("#0A253B","#235179","#3E7DBB","#67488B","#565676","#C90000","#EB7C05","#E09406","#BA7839","#92583F")

pca <- glPca(gl,nf=3,parallel=F)

pdf("PCA.pdf",width=5,height=6.5)
par(mfrow=c(2,1),mar=c(3,3,1,6),oma=c(1,1,1,1))

#plot(pca$scores[,1:2],col=transp(c("#0A253B","#235179","#0A253B","#235179","#235179","#235179","#0A253B","#C90000","#C90000","#BA7839","#BA7839","#BA7839","#BA7839","#C90000","#92583F","#92583F","#92583F","#92583F","#92583F","#92583F","#92583F","#92583F","#92583F","#92583F","#C90000","#C90000","#C90000","#C90000","#565676","#565676","#E09406","#E09406","#E09406","#E09406","#E09406","#67488B","#67488B","#67488B","#67488B","#67488B","#67488B","#67488B","#EB7C05","#C90000","#C90000","#3E7DBB","#3E7DBB","#3E7DBB","#3E7DBB","#3E7DBB"),0.7),pch=19,cex.axis=0.8)
plot(pca$scores[,1:2],col=transp(popColors[metadata$Color],0.7),pch=19,cex.axis=0.8)
abline(h=0,col="black",lwd=1,lty=2)
abline(v=0,col="black",lwd=1,lty=2)
par(xpd=TRUE)
#legend(45,30,legend=c("Marojejy","Anjanaharibe","Anjiahely","Ambavala","Riamalandy","Ambatovy","Anjozorobe","Tsinjoarivo","Ambohitantely","Ankafobe"),col=c("#0A253B","#235179","#3E7DBB","#67488B","#565676","#C90000","#EB7C05","#E09406","#BA7839","#92583F"),pch=16,bty="n",cex=0.8)
legend(45,30,legend=popLabels,col=popColors,pch=16,bty="n",cex=0.8)
mtext("PC1 (9.68%)",side=1,line=2,cex=0.8)
mtext("PC2 (5.69%)",side=2,line=2,cex=0.8)
mtext("a)",side=3,line=0.25,adj=0,cex=0.8)

par(xpd=FALSE)
plot(pca$scores[,2:3],col=transp(popColors[metadata$Color],0.7),pch=19,cex.axis=0.8)
abline(h=0,col="black",lwd=1,lty=2)
abline(v=0,col="black",lwd=1,lty=2)
mtext("PC2 (5.69%)",side=1,line=2,cex=0.8)
mtext("PC3 (3.91%)",side=2,line=2,cex=0.8)
mtext("b)",side=3,line=0.25,adj=0,cex=0.8)

dev.off()
########
#Some other functionality down here. Possible to remove individuals from vcf/gl object.
gl.noscrubs <- gl.drop.ind(gl, c("Mleh_JMR002_S12","Mleh_JMR001_S12","Mleh_ANJZ11"), recalc = TRUE, mono.rm = TRUE, verbose = NULL)

#Potential applications of hierfstat here
#gi <- gl2gi(gl.noscrubs)
#summarystats <- basic.stats(gi)
####

#Using amova function from poppr
mleh.amova.1 <- poppr.amova(gl.noscrubs, ~Cluster1/Population)
mleh.amova.1.test <- randtest(mleh.amova.1,nrepet = 9999)

mleh.amova.2 <- poppr.amova(gl.noscrubs, ~Cluster2/Population)
mleh.amova.2.test <- randtest(mleh.amova.1,nrepet = 9999)

mleh.amova.3 <- poppr.amova(gl.noscrubs, ~Cluster3/Population)
mleh.amova.3.test <- randtest(mleh.amova.1,nrepet = 9999)
```