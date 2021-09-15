---
layout: post
title:  "Juicer is now working"
date:   2021-08-20 00:00:00 -0400
categories: jekyll update
---
There were some troubles getting juicer to behave on our cluster last week. There were a few fixes needed to get this running.
1. First, it seems like Juicer was have trouble with the gzip compressed fastqs. Upon inspection of the juicer.sh script, it is hard to know why, but it seems like others ran into this problem too. This was resolved by simply uncompressing the gzipped fastqs.
2. We used symbolic links to avoid everybody replicating the same fastq files in their work directories. Because the uncompressed files are too large to keep in our /hpc/group folder, you now have to copy those compressed fastqs into work and then uncompress them.
3. I changed some options in the juicer.sh script to correctly load dependent software when needed.

All of the changes are now reflected in an updated activity page from last week. If you are interested in finishing the Hi-C scaffolding, it will be a little bit of work to go back, but you should be able to finish now - or copy the juicedir for future use on your own data.