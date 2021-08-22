---
layout: page
title: Getting started with computing
permalink: /labs/introduction/
---

Our first day is simply making sure everybody has the basic tools to participate in the course. There are four goals today:
1. Log on to the DCC cluster
2. Perform basic UNIX operations
3. Run some scripts
4. Recognize the difference between interpreted and compiled languages

Some or all of this may be very familiar to many of you. Today is about getting everybody on the same page for advancing later in the course. Please take time to help your less familiar neighbors.

There may be some necessary downloads for your own computers in order to log onto the cluster and edit files.

**Windows**
* [Git for Windows](https://git-for-windows.github.io/)
* [Notepad++](https://notepad-plus-plus.org/download/v8.1.3/)
* [Perl](https://strawberryperl.com/)
* [Python](https://www.python.org/downloads/windows/)

**Mac**
+ [BBEdit](https://www.barebones.com/products/bbedit/)
* I recommend downloading the command line tools from the developer [website](https://developer.apple.com/)
* Although Macs come with Python v2.7, Python 2 is no longer supported. Current and future applications are moving to Python 3 and here is a decent [guide](https://docs.python-guide.org/starting/install3/osx/) for not messing up your system

**Linux**
* you should be set up

More downloads will arise as the course progresses.

### Moving files between your computer and the cluster
Let's start by downloading materials for today. Open your command-line prompt (using git-bash for Windows users). I suggest making a folder to organize all of the class materials in one place.
```
cd ~
ls
mkdir evolutionaryGenomics
cd evolutionaryGenomics
pwd
```
Several things happened here. We *change directory* with `cd` and *list* files with `ls`. These are UNIX commands that will help us navigate the cluster. The `~` is an alias for our home directory, you can put this folder somewhere else if you prefer. We then *make directory* named evolutionaryGenomics with `mkdir`. We then change into that directory and check the location of the *present working directory* with `pwd`.

Now you will log into the cluster. Then you will copy materials from a shared folder to your home directory (on the cluster). You will then move those files from your home directory on the cluster to your computer with a *secure copy* using `scp`. These files are also available on [GitHub](https://github.com/gtiley/EvolutionaryGenomics/tree/main/data/introduction).
```
ssh YOUR_USER_NAME@dcc-login.oit.duke.edu
mkdir evolutionaryGenomics
cd evolutionaryGenomics
cp -r /datacommons/yoderlab/users/gtiley/evolutionaryGenomics/introduction .
exit
scp -r YOUR_USER_NAME@dcc-login.oit.duke.edu:~/introduction .
ls
```

Now we will look around at today's contents
```
cd introduction
ls
cd data
ls
```
Again, we *change directory* with `cd` and *list* files with `ls` on our computer just as we did on the cluster. Let's have a look at one of the files in `data` - `welcomeMessage.txt`. We will open it with a text editor directly in the command line.
```
emacs welcomeMessage.txt
```
There is some information about myself in there. But we want to know about you! Use the arrows to edit the information about yourself. Keep the research interest to 6 words only. Saving changes through a text editor such as emacs requires keyboard shortcuts - `control` + `x` + `s` to save and `control` + `x` + `c` to close. Alternatively, you could open and edit this file with your text editor such as Notepad++ or BBEdit. Please check that you are using UNIX-style line breaks.
Now we need to rename the file to make it unique. We can rename a file with *move* `mv`. You will then transfer your edited and rename file back to the cluster and you We will then *copy* it to a shared directory using `cp`.
```
mv welcomeMessage.txt welcomeMessage.YOUR_NAME.txt
scp welcomeMessage.YOUR_NAME.txt YOUR_USER_NAME@dcc-login.oit.duke.edu:~/introduction
ssh YOUR_USER_NAME@dcc-login.oit.duke.edu
cd introduction
cp welcomeMessage.YOUR_NAME.txt /datacommons/yoderlab/users/gtiley/evolutionaryGenomics/introduction
```
After everybody has their edited welcome messages available, we will update the people [page](https://gtiley.github.io/EvolutionaryGenomics/people/) using a script. What exactly is a script?

### Interpreted Code - Scripting
Most genomics applications happen, at least in part, with scripting. Scripting languages are great for performing operations on strings or text, like ACGT. They are also not bad for a human to understand and hide the messiness of turning human-readable code to machine-readable code (compiling). That is the work of the interpreter, which happens in real-time. Scripting languages include Python, Perl, and Ruby. You can also accomplish a bit with bash and awk, but my heart-felt recommendation would be to dedicate some time into learning Python if you are new to this.

Let's see some simple scripts in action and hint at how they might be useful. In `data/`, you will find three files `*.params` with some results from a model.

In all omics data, we are often iterating over many things (e.g. loci, individuals, populations, bootstrap replicates) to do something repetitive. Let's execute three different scripts that will allow us to loop over the `*.params` files.

#### loopFiles.sh - a simple bash script
The first line is a shebang. This is letting your computer know which interpreter program to use. Our first example is using bash, which will be available on any UNIX system. First, all of the `*,param` files are collected into a single array or list. We then iterate over the number of elements in that array, print the element to the screen, and quit the script.
```sh
#!/bin/bash                                                                                                                   

fileList="../data/*.params"
for i in $fileList
do
  echo "$i"
done
```
Let's run this simple script. We can execute programs that are not in our *path* by specifying the location. If we are in the same folder that we want to execute a program from we would go `./loopFiles.sh` such that `.` means *here*.
```
cd ~/YOUR_PATH/evolutionaryGenomics/introduction/scripts
./loopFiles.sh
```
Already a problem, nothing happens. To run a script this way, we need to let the computer know it is an executable program. `chmod` can be used to change the execute, read, and write permissions of files and folders.
```
chmod u+x loopFiles.sh
./loopFiles.sh
```
The file names should now print to your screen.

#### loopFiles.pl - give me Perl
Perl is a popular scripting language that is the glue of the internet and played a large role in early genomics applications. It still is, but has waned in popularity as various R packages and the more recent Python has exploded in popularity. It will give you more flexibility than bash in the long-term and can be quick to learn. Here, we use the *glob* function to get an array of the file names. We then loop over array elements from their starting position (0) to the end (2) by getting the number of elements in the array with *scalar* and subtracting 1.
```perl
#!/usr/bin/perl -w                                                                                                            

@fileList = glob("../data/*.txt");
for $i (0..(scalar(@fileList)-1))
{
    print "$fileList[$i]\n";
}
exit;
```
We could make this script executable as we did with the bash script, or we could go
```
perl loopFiles.pl
```

#### loopFiles.py - Python and its libraries
Python is certainly the zeitgeist of bioinformatics and genomics today. Python is more recent than Perl. Although they do similar things, there has been a lot of development on improving abstraction and this is supported by many libraries (or modules). These are groups of functions that you let python know you want to use with the `import <module>` syntax. Here we load two very basic modules `sys` and `os`, but a third one we actually use, `glob`! We can use functions from modules by going `<module>.<function>()`, so we see `glob.glob()` here.
```python
#!/usr/bin/env python3                                                                                                        
import os
import sys
import glob

fileList = glob.glob("../data/*.txt")
for i in range(0,len(fileList)):
    print(fileList[i])
exit;
```

Let's run it
```
python loopFiles.pl
```

If that did not work, `python` on your system likely points to Python 2 and this is written for Python 3. Systems may differentiate the two by requiring Python 3 be specified as
```
python3 loopFiles.pl
```

### Using scripts to retrieve information from files
Scripting is a helpful way to get results from our inevitable thousands of output files. Here are a couple of examples in Perl and Python that build upon looping over the file list. Now, each file is opened and we process them line-by-line to extract the relevant information. Our goal is to make one table with the parameter values for each param file.

#### getResults.pl - a regex approach
Scripting languages can use regular expressions (regex) to find patterns in strings. Good text editors can find and replace with text editors too. You can use them to save pieces of the string you care about and work with those further.
```perl
#!/usr/bin/perl -w                                                                                                          

%data = ();

@fileList = glob("../data/file*.txt");
for $i (0..(scalar(@fileList)-1))
{
#    print "$fileList[$i]\n";                                                                                               
    open FH1,'<',"$fileList[$i]";
    while(<FH1>)
    {
        if (/(\S+)\s+(\S+)/)
        {
            $parameter = $1;
            $value = $2;
            if ($parameter ne "Parameter")
            {
                push @{$data{$parameter}}, $value;
            }
        }
    }
    close FH1;
}

print "File";
foreach $parameter (sort(keys(%data)))
{
    print "\t$parameter";
}
print "\n";

for $i (0..(scalar(@fileList)-1))
{
    print "$fileList[$i]";
    foreach $parameter (sort(keys(%data)))
    {
        print "\t$data{$parameter}[$i]";
    }
    print "\n";
}
exit;
```

Scripting languages give you access to helpful *data structures*. Here, I make a *hash* called `data`, which is denoted by the `%`. Hashes have two parts, the *key* and the *value*. This is different from an *array* where you only need to know the element number to access the value - it can be a string too. And here, I actually make a hash of arrays, where each key (a,b,c) gives us the values from the three different files. I then loop back over the data structure to print a matrix that we might work with in R.
```
perl getReults.pl
```

#### getResults.py - splitting lines and tuples for keys
Python can use regex too, but here I simply apply some prior knowledge about the param files to extract what I want. Python also uses hashes, but here the data structure is called a *dictionary* or *dict*. Here, we actually have a two-dimensional dictionary where each key is a *tuple*.
```python
#!/usr/bin/env python3                                                                                                      
import os
import sys
import glob

data = {}

fileList = glob.glob("../data/file*.txt")
for i in range(0,len(fileList)):
    InFile = open (fileList[i], 'r')
    for Line in InFile:
        Line = Line.strip('\n')
        ElementList = Line.split('\t')
        if (len(ElementList) > 1) and (ElementList[0] != "Parameter"):
            data[(i,ElementList[0])] = ElementList[1]

print('File\tParameter\tValue',end='\n')
for j,k in sorted(data.keys()):
    print(fileList[j],'\t',k,'\t',data[(j,k)],end='\n')
exit;
```

 You might notice that when printing here, we access the keys a bit more efficiently than the Perl case and print out a file that would be more appropriate for tidyverse R packages, so you can start to see how things fit together here.
```
python3 getReults.py
```

### Compiled Code
Common examples of compiled languages are C and C++. They implement low-level functions compared to interpreted/scripting languages (e.g. it would take some creativity to re-implement the glob function), but they are more efficient with memory allocation and potentially faster. C and C++ underly many of the workhorses of the genomics field, such as BWA, BLAST, and RAxML.

To generate an executable program from the C code, we will run the gcc compiler as follows:
```
gcc -Wall -o betaSolver betaSolver.c solveBeta.c
```
`-Wall` is telling gcc to print warning flags which you will often see when building popular software applications. Our source code is in two different files `betaSolver.c` and `solveBeta.c`, and we use `-o` to indicate the output program `betaSolver`
You should now have the compiled C program `betaSolver`. Give it a try! Pull up the help menu and then see if you can get the program to do what it should.
```
./betaSolver -h
```

You almost never compile programs by invoking gcc yourself though. This would leave a lot of wiggle room for user errors. Thus, programs sometimes come with a Makefile. There is one to compile the `betaSolver` program for you to save some typing. Let's see it in action.
First, delete the previous application
	rm betaSolver
Now, let's run the Makefile - this is very simple
	make
You will now see that `betaSolver` has returned.

There will often be frustrating moments when compiling a program that you want to use, because you will run make and it will stop compiling with errors and give you very cryptic messages. As programs become very complex, there can be many external libraries that a program depends on. A step that happens with compiling is *linking* all of the bits of code scattered across a computer into a single computer-readable program. Let's break our program.
```
make clean
mv betaSolver.h wrong.h
make
```
Makefiles sometimes come with a *clean* option, so that all of the compiled code is removed. We then change the name of our helper file to `wrong.h` so the compiler no longer fins the correct one. You will now get a error that stops the compiler. This is an easy issue to diagnose from the error message, but sometimes it is not. Often it is a linking problem and we will revisit this when compiling some crucial population genomic programs.

### Wrap up
You have now logged onto the cluster edited some files and moved them around. You have transferred files between your computer and the cluster. You have successfully run some some scripts and compiled a program. Some system issues may arise that take longer to diagnose than in the time allowed here and we will troubleshoot those in the coming week in preparation for Falcon Phase Part 1.

### Pro Tip
It might get annoying over time with typing your password every time you want to do something on the cluster. You can get around this by setting up an rsa key on your computer and then placing the public key in a hidden folder in your home directory on the cluster. Duke has some special instructions about how to set this up in their [guide](https://rc.duke.edu/dcc/dcc-user-guide/) about ssh public keys.