#!/usr/bin/env python3
import os
import sys
import glob

fileList = glob.glob("../data/*.txt")
for i in range(0,len(fileList)):
    print(fileList[i])
exit;
