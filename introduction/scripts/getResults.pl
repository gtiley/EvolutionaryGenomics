#!/usr/bin/perl -w

%data = ();

@fileList = glob("../data/*.params");
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
