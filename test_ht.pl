# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Test::Simple tests => 4;

#########################

# compare two files
sub compare {
    my $file1 = shift;
    my $file2 = shift;

    open(F1, $file1) || return 0;
    open(F2, $file2) || return 0;

    my $res = 1;
    my $count = 0;
    while (<F1>)
    {
	$count++;
	my $comp1 = $_;
	# remove newline/carriage return (in case these aren't both Unix)
	$comp1 =~ s/\n//;
	$comp1 =~ s/\r//;

	my $comp2 = <F2>;

	# check if F2 has less lines than F1
	if (!defined $comp2)
	{
	    print "error - line $count does not exist in $file2\n  $file1 : $comp1\n";
	    close(F1);
	    close(F2);
	    return 0;
	}

	# remove newline/carriage return
	$comp2 =~ s/\n//;
	$comp2 =~ s/\r//;
	if ($comp1 ne $comp2)
	{
	    print "error - line $count not equal\n  $file1 : $comp1\n  $file2 : $comp2\n";
	    close(F1);
	    close(F2);
	    return 0;
	}
    }
    close(F1);

    # check if F2 has more lines than F1
    if (defined($comp2 = <F2>))
    {
	$comp2 =~ s/\n//;
	$comp2 =~ s/\r//;
	print "error - extra line in $file2 : '$comp2'\n";
	$res = 0;
    }

    close(F2);

    return $res;
}

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

# now test the script
my $command = "hypertoc --gen_anchors --infile test1.wml --outfile test1_anch.wml";
#my $command = "hypertoc --gen_anchors --quiet --infile test1.wml --outfile test1_anch.wml";
$result = system($command);
ok($result == 0, 'hypertoc generated anchors from test1.wml');

# compare the files
$result = compare('test1_anch.wml', 'good_test1_anch.wml');
ok($result, 'hypertoc: test1_anch.wml matches good output exactly');

$command = "hypertoc --gen_toc --quiet --toc_file test1_toc.html test1_anch.wml";
$result = system($command);
ok($result == 0, 'hypertoc generated toc from test1_anch.wml');

# compare the files
$result = compare('test1_toc.html', 'good_test1_toc.html');
ok($result, 'hypertoc: test1_toc.html matches good output exactly');

# clean up test1
if ($result) {
    unlink('test1_anch.wml');
    unlink('test1_toc.html');
}

