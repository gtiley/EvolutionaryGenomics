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
