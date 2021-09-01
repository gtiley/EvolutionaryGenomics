---
layout: page
title: de Bruijn Graphs and OLC
permalink: /labs/genomeAssembly1/
---

Assembling a reference genome *de novo* has become easier over time, with decreasing costs and more efficient assemblers. Long-read data has especially been a game-changer that has helped overcome some of the notable weaknesses of assemblies based on short-reads alone. Still significant challenges remain in the pursuit of chromosome-level assemblies. Today, we start the process of assembling a chromosome level genome by getting *contigs*. Next week, we will focus on how these contigs are arranged into *scaffolds*. Here are today's goals, some of which will not be possible until next week when assemblies are done.
1. Understand the formats of Illumina and PacBio data
2. Describe a kmer and general assembly algorithm strategies
3. Run some assembly software
4. Evaluate contig assembly quality
5. Compare assemblies that use or do not use long reads

Because each assembly is resource intensive you will run analyses in your `work` directory. You will also work in teams of two.

|Team (Spotter/Driver)                |Strategy                  |Software            |
|-------------------------------------|--------------------------|--------------------|
|Mantis (Blake/Melodie)               |Bad kmer - short only     |Abyss               |
|Ctenophore (Carlos/Gabi)             |optimal kmer - short only |Abyss               |
|Raptor (Elissa/Shannon)              |high coverage - long only |Canu                |
|Big Bluestem (Ian/Tristan F-B)       |low coverage - long only  |Canu                |
|Polyploid Admixed Yeast (Elise/Marta)|hybrid data               |MaSurCa             |
|Scaly Tree Fern (Hannah/Tristan F)   |hybrid algo - short only  |MaSurCa             |
|Mouse Lemur (George/Anne)            |hybrid data - long low    |MaSurCa             |

We are not making the most scientific comparison of assemblers, but we should be able to get some gestalt of what is useful for genome assemblies. The three assemblers we are comparing here are:
1. Abyss - A de Bruijn graph short read assembler that has performed well and been maintained over time. Capable of assembling large genomes with many libraries.
2. Canu - Uses an OLC algorithm from the Celera assembler but does some smart tricks to allow fuzzy matching due to error
3. MaSurCa - We read the manuscript for this one. A somewhat hybrid algorithm that bins short reads in larger sequences subsequently used for OLC. Capable of using *polished* long reads.

### Thrips!
We will focus on a recently published thrip genome[^1]. Why? The genome is small, about 200Mb. We still get to work with a diploid though since the libraries were constructed from a single female. Plus, thrips have a lot of gene duplications that should make things interesting. The authors generated three types of data:
1. Vanilla Illumina (60x) 150bp paired-end reads - Basic Illumina library prep protocol with a 500bp insert size. These libraries are ubiquitous to both *de novo* assemblies and population resquencing experiments.
2. PacBio Sequel (120x) long reads - The Sequel had higher error rates than the current HiFi machines, but are still high quality and compensated by the insane *depth* here. Larger insert sizes are possible, but most of these are around 6Kb.
3. High-throughput chromosome conformation capture (Hi-C) Illumina (300x) 150bp paired-end reads - These libraries are used for scaffolding, which will be the focus of next week. Cross-linking and digestion of chromatin proteins are used to generate libraries with a range of large inserts. Hi-C data is used in other contexts too, but has been transformative for genome assembly.

The data has been organized in our folder on the cluster
**Vanilla Illumina**
```
/hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/Illumina/SRR11591408_1.fq.gz
/hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/Illumina/SRR11591408_2.fq.gz
```
There is file for both the forward and reverse read from the paired-end data. The fastq files contain information on both the sequences and the per-base qualities of those sequences. If this is your first time working with fastq data, have a peak at one of the files
```
less /hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/Illumina/SRR11591408_1.fq.gz
```
Note the first line of each read starts with a "@" for the header. When data do not come from SRA, these will be strings of numbers to indicated the read's address on a sequencing machine. The second line is the detected sequence. The third line is the header again but with a "+". This is to help file readers parse the next string of quality scores. The quality scores are represented by standard keyboard characters used for communication between computers (ASCII) that are all associated with a number between 0 and 127. These numbers are used to determine the probability of an erroneous base call, see an explanation by muscle man Robert Edgar [here](https://www.drive5.com/usearch/manual/quality_score.html).
Because assemblers need accurate data to get the assembly right, discarding a few really bad reads and adaptor contamination can be a good idea. Reads cleaned in advance by Trimmomatic are available too
```
/hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/Illumina/trimmed_1.fq.gz
/hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/Illumina/trimmed_2.fq.gz
```
**PacBio**
```
/hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/data/PacBio/SRR11148454.fasta
```
PacBio data is typically processed with PacBio's proprietary software that handles adapter removal. You might sometimes see PacBio data delivered as a fastq - but the quality scores are pretty meaningless. Instead, PacBio reads leverage *circular consensus sequencing* (CCS) that should swamp out the noise by sequencing the same molecular many times over.

### Assembling in the /work directory
Last time on the cluster, we did our work on `/hpc/group/bio790s-01-f21`. Clusters will often have limited long-term storgage space and more headroom in a temporary scratch directory. This directory on DCC is called `/work` and every user will have their personal directory in there. Be sure to run your jobs in `work` or we will quickly run out of space. Genome assemblies generate many temporary files that consume disk space but are of no value once the assembly is done.
Your driver will log onto the cluster and copy their respective teams template files to their user directory in work. Spotters will help their drivers edit and execute the templates. Take time to learn about the program options, investigate what they do, and discuss.
```
ssh YOUR_USER_NAME@dcc-login.oit.duke.edu
cd /work/YOUR_USER_NAME
mkdir evolutionaryGenomics
cd evolutionaryGenomics
cp -r /hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly1/YOUR_TEAM .
cd YOUR_TEAM
mkdir temp
emacs runAssembler.sh
sbatch runAssembler.sh
```
Observe that your jobs starts without incident and inspect the logs. Can you find some basic information about coverage, kmer distributions, and expected genome size? This is going to take a while but should be ready by next week. You can check on how your job is doing with some SLURM commands on the cluster
```
squeue -u YOUR_USER_NAME
```
You can also track the progress by checking the log files and confirming there are no error messages.

### Measuring assembly quality
A classic summary statistic is *N50*. This is when 50% of the *assembly* is represented by contigs of length n or greater. Typically, the bigger the N50 the better, and this can improve with increased sequencing depth, but only to an extent and there are diminishing returns. *L50* might also come up some times, this is the number of contigs that contain 50% of the genome. When genome size is known from some external evidence such as flow cytometry or optical mapping, you can also calculate *NG50*. This differs from N50 because it is based on the genome size and not the assembly size; assemblies are always shorter than the true genome size.
Many assemblers will calculate these statistics for you, but when comparing multiple assemblies, it is a good idea to use a single software since different developers might, for example, exclude contigs less than 1 Kb. Quast is a good choice for generating these stats. We are waiting for our own assemblies, but you can run it on the thrip reference assembly to get an idea of what to expect. Remember to edit the quast script for SLURM with your appropriate information.
```
emacs runQuast.sh
sbatch runQuast.sh
```

Can you find the relevant information in the quast output folder? It generates a nice html file that you can view, but you will need to scp it to your local computer. If you do not remember how to do this, have a look at last weeks activity. When your assembly finishes, your will need to edit the quast script to run it on your assembly.

### References
[^1]: Guo S-K, Cao L-J, Song W, Shi P, Gao Y-F, Gong Y-J, Chen J-C, Hoffmann AA, Wei S-J. 2020. Chromosome level assembly of the melon thrips genome yields insights into evolution of sap-sucking lifestyle and pesticide resistance. Mol Ecol. 20:1110-1125.