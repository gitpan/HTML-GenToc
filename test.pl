# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use HTML::GenToc;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$toc = new HTML::GenToc();
if ($toc) {
    print "ok 2\n";
} else {
    print "ok 2\n";
}

@args = ();
push @args, "--file", "test.wml", "--outfile", "test2.wml";
$result = $toc->generate_anchors(\@args);
if ($result) {
    print "ok 3\n";
} else {
    print "ok 3\n";
}

@args = ();
push @args, "--file", "CLEAR", "--outfile", "",
"--file", "test2.wml";
$result = $toc->generate_toc(\@args);
if ($result) {
    print "ok 4\n";
} else {
    print "ok 4\n";
}

@args = ();
push @args, "--file", "CLEAR",
"--file", "test.html", "--outfile", "test2.html";
$result = $toc->generate_anchors(\@args);
if ($result) {
    print "ok 5\n";
} else {
    print "ok 5\n";
}

@args = ();
push @args, "--file", "CLEAR", "--outfile", "",
"--file", "test2.html", "--inline", "--overwrite";
$result = $toc->generate_toc(\@args);
if ($result) {
    print "ok 6\n";
} else {
    print "ok 6\n";
}

# clean up
unlink("test2.wml");
unlink("test2.html");
unlink("test2.html.org");
