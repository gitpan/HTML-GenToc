# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Test::Simple tests => 15;
use HTML::GenToc;
ok(1); # If we made it this far, we're ok.

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

$toc = new HTML::GenToc();
ok( defined $toc, 'new() returned something' );
ok( $toc->isa('HTML::GenToc'), "  and it's the right class" );

@args = ();
push @args, '--quiet', '--file', 'test1.wml', '--outfile', 'test1_anch.wml';
$result = $toc->generate_anchors(\@args);
ok($result, 'generated anchors from test1.wml');

# compare the files
$result = compare('test1_anch.wml', 'good_test1_anch.wml');
ok($result, 'test1_anch.wml matches good output exactly');

@args = ();
push @args, '--file', 'CLEAR', '--outfile', '',
'--file', 'test1_anch.wml', '--toc_file', 'test1_toc.html';
$result = $toc->generate_toc(\@args);
ok($result, 'generated toc from test1_anch.wml');

# compare the files
$result = compare('test1_toc.html', 'good_test1_toc.html');
ok($result, 'test1_toc.html matches good output exactly');

# clean up test1
unlink('test1_anch.wml');
unlink('test1_toc.html');

@args = ();
push @args, '--file', 'CLEAR', '--toc_file', '',
'--file', 'test2.html', '--outfile', 'test2_anch.html';
$result = $toc->generate_anchors(\@args);
ok($result, 'generated anchors from test2.html');

# compare the files
$result = compare('test2_anch.html', 'good_test2_anch.html');
ok($result, 'test2_anch.html matches good output exactly');

@args = ();
push @args, '--file', 'CLEAR', '--outfile', '',
'--file', 'test2_anch.html', '--inline', '--overwrite';
$result = $toc->generate_toc(\@args);
ok($result, 'generated toc inline test2_anch.html');

# compare the files
$result = compare('test2_anch.html', 'good_test2_toc.html');
ok($result, 'test2_anch.html matches good output exactly');

# clean up
unlink('test2_anch.html');
unlink('test2_anch.html.org');

@args = ();
push @args, '--file', 'CLEAR', '--bak', '', '--noinline', '--nooverwrite',
'--file', 'test3.wml', '--outfile', 'test3_anch.wml';
push @args, '--toc_entry', 'H3=3';
push @args, '--toc_end', 'H3=/H3';
$result = $toc->generate_anchors(\@args);
ok($result, 'generated anchors from test3.wml');

# compare the files
$result = compare('test3_anch.wml', 'good_test3_anch.wml');
ok($result, 'test3_anch.wml matches good output exactly');

@args = ();
push @args, '--file', 'CLEAR', '--outfile', '',
'--file', 'test3_anch.wml', '--toc_file', 'test3_toc.html';
$result = $toc->generate_toc(\@args);
ok($result, 'generated toc from test3_anch.wml');

# compare the files
$result = compare('test3_toc.html', 'good_test3_toc.html');
ok($result, 'test3_toc.html matches good output exactly');

# clean up
unlink('test3_anch.wml');
unlink('test3_toc.html');

# misc stuff
#@args = ();
#push @args, '--unknown_option';
#$result = $toc->args(\@args);
