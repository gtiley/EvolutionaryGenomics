#!/usr/bin/perl -w

@fileList = glob("../data/*.params");
for $i (0..(scalar(@fileList)-1))
{
    print "$fileList[$i]\n";
}
exit;
