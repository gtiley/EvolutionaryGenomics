---
layout: page
title: Genome Annotation
permalink: /labs/genomeAssembly3/
---

Although assemblies are still in process, today is about annotating those genomes. We will use the MAKER pipeline to annotate our thrip genome with some homology-based and predictive evidence.

First, we will be doing some copying and uncompressing on the cluster that takes a little more bandwith than we should be using on the head node. Let's get a processor on the compute node
```
srun --ntasks=1 --cpus-per-task=1 --mem-per-cpu=4gb --partition=common --account=bio790s-01-f21 --pty bash -i
```

We are going to do a pretty bad job at annotation; we are not incorporating direct mRNA evidence, retraining the gene predictors, or retraining the TE models. Some details about this can be found on some other good online [tutorials](https://darencard.net/blog/2017-05-16-maker-genome-annotation/). Retraining models used to be a pretty annoying thing to do, but now additional tools like BUSCO have streamlined this.

Go ahead and copy today's folder into your work directory
```
cd /work/YOUR_NETID/evolutionaryGenomics
cp -r hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly3 .
cd genomeAssembly3
ls
```

***BUSCO
You will see two activities for today. First, we will run BUSCO on your previous assemblies to evaluate assembly quality. There is a quick user setup step needed though. Then we will start MAKER. BUSCO can be used in the future to evaluate your gene models too.
```
cd hpc/group/bio790s-01-f21/evolutionaryGenomics/programs/buscoV3.2b
python3 setup.py install --user
cd hpc/group/bio790s-01-f21/evolutionaryGenomics/genomeAssembly3/BUSCO
emacs runBusco.sh
#sbatch runBusco.sh
```
We are using an older version of BUSCO, version 3. This is because the newer versions are a real pain to install for everybody to use. BUSCOs are genes determined to span the root of certain phylogenetic group and conserved at least in observed species within that group. Running BUSCO in "genome" mode will use HMMs to find these conserved genes in the assembly. It should get underway and take about an hour to finish.

***MAKER
MAKER is executed through several control files. These are:
* maker\_exe.ctl - Where all of the program paths are supplied. Recall that MAKER is a wrapper around other gene prediction and alignment software.
* maker\_bopts.ctl - Where all of the blast options are configured. These are generally fine to leave as default.
* maker\_opts.ctl - Where the instructions for which evidence to use and how to reconcile them are configured. You will need to edit this file some.

Let's have a closer look at maker\_opts.ctl
```
#-----Genome (these are always required)
genome=assembly/thrip.contigs.fasta #genome sequence (fasta file or fasta embeded in GFF3 file)
organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic

#-----Re-annotation Using MAKER Derived GFF3
maker_gff= #MAKER derived GFF3 file
est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no

#-----EST Evidence (for best results provide a file for at least one)
est= #set of ESTs or assembled mRNA-seq in fasta format
altest= #EST/cDNA sequence file in fasta format from an alternate organism
est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
altest_gff= #aligned ESTs from a closly relate species in GFF3 format

#-----Protein Homology Evidence (for best results provide a file for at least one)
protein=homology/insects.proteins.fasta  #protein sequence file in fasta format (i.e. from mutiple organisms)
protein_gff=  #aligned protein homology evidence from an external GFF3 file

#-----Repeat Masking (leave values blank to skip repeat masking)
model_org=drosophila #select a model organism for RepBase masking in RepeatMasker
rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
repeat_protein=/admin/apps/rhel7/maker-3.01.03/data/te_proteins.fasta #provide a fasta file of transposable element proteins for RepeatRunner
rm_gff= #pre-identified repeat elements from an external GFF3 file
prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)

#-----Gene Prediction
snaphmm= #SNAP HMM file
gmhmm= #GeneMark HMM file
augustus_species=fly #Augustus gene prediction species model
fgenesh_par_file= #FGENESH parameter file
pred_gff= #ab-initio predictions from an external GFF3 file
model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
run_evm=0 #run EvidenceModeler, 1 = yes, 0 = no
est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
protein2genome=1 #infer predictions from protein homology, 1 = yes, 0 = no
trna=0 #find tRNAs with tRNAscan, 1 = yes, 0 = no
snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
snoscan_meth= #-O-methylation site fileto have Snoscan find snoRNAs
unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no
allow_overlap= #allowed gene overlap fraction (value from 0 to 1, blank for default)

#-----Other Annotation Feature Types (features MAKER doesn't recognize)
other_gff= #extra features to pass-through to final MAKER generated GFF3 file

#-----External Application Behavior Options
alt_peptide=X #amino acid used to replace non-standard amino acids in BLAST databases
cpus=8 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)

#-----MAKER Behavior Options
max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
min_contig=10000 #skip genome contigs below this length (under 10kb are often useless)

pred_flank=200 #flank for extending evidence clusters sent to gene predictors
pred_stats=0 #report AED and QI statistics for all predictions as well as models
AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
min_protein=0 #require at least this many amino acids in predicted proteins
alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)

split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
min_intron=20 #minimum intron length (used for alignment polishing)
single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes

tries=2 #number of times to try a contig if there is a failure for some reason
clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
TMP= #specify a directory other than the system default temporary directory for temporary files
```
A few things, you will need to replace the fasta file in the assembly folder with your own. The Re-annotation section is for training the prediction software with hints. Normally, at least two rounds of annotation are done but we are overlooking that.

The EST Evidence section is where you would provide an assembled transcriptome. Ideally this comes from the target organism, but could be provided from a related species. Ir changes the expectations about sequence similarity. We provide some protein sequences in the next section though that will be blasted against the genome using tblastn.

We skipped over repeat masking. Masking occurs before the annotation, because it would be a waste of computing to blast against a lot of repetitive sequences. You can do the masking prior to annotation, but MAKER can wrap this into the pipeline for you. Training the repeat models can take some work though. Here, we assume the models based on fly are good enough, which is provided with the RepeatMasker software.

The Gene Prediction is where we decide which HMMs to use. Here, we specify Augustus only. We provide its canned fly models too. We also allow gene models to be based on the protein alignments. Here you can allow different types of data to be considered, and change what goes into the polishing steps.

We will discuss in more detail in class.

A note about MAKER. It is meant to be compiled with MPI and take advantage of many nodes and processors. Because of our limitations, we will not be using it with MPI. This can cause the annotation to take a while - plus the MPI libraries appear broken for them moment. For a serious project outside of this class, you will need to rebuild MAKER to make sure all of the libraries are linked correctly and use as many processors as you have available.

Here are a few steps to get is running - notice we make a temp directory again and you will need to specify this in the slurm script
```
cd ../MAKER
mkdir temp
emacs runMaker.sh
#sbatch runMaker.sh
```

Once that is underway - maybe your BUSCO results are done? Have a look. You should have a short text file that summarizes the typical BUSCO categories.

Next week is moving on to population genomics. You will be doing more scripty things, since we will often iterate operations over chromosomes or genomic chunks. Pre-made sh scripts will no longer be provided either, so now will be a good chance to check that all of the basic UNIX operations (cp, ls, mkdir, etc.) and slurm directives are understood.
