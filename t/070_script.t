use Test::More tests => 8;

require 't/compare.pl';

#--------------------------------------------------------------------
# Insert your test code below
#--------------------------------------------------------------------

# clear files
if (-f 'test1_anch.wml') {
    unlink('test1_anch.wml');
}
if (-f 'test1_toc.html') {
    unlink('test1_toc.html');
}

# now test the script
my $command = "perl -I lib scripts/hypertoc --quiet --gen_anchors --infile tfiles/test1.wml --outfile test1_anch.wml";
$result = system($command);
ok($result == 0, 'hypertoc generated anchors from test1.wml');

# compare the files
$result = compare('test1_anch.wml', 'tfiles/good_test1_anch.wml');
ok($result, 'hypertoc: test1_anch.wml matches good output exactly');

$command = "perl -I lib scripts/hypertoc --gen_toc --quiet --toc_file test1_toc.html test1_anch.wml";
$result = system($command);
ok($result == 0, 'hypertoc generated toc from test1_anch.wml');

# compare the files
$result = compare('test1_toc.html', 'tfiles/good_test1_toc.html');
ok($result, 'hypertoc: test1_toc.html matches good output exactly');

# clean up test1
if ($result) {
    unlink('test1_anch.wml');
    unlink('test1_toc.html');
}

#
# test with both generate options together
#
$command = "perl -I lib scripts/hypertoc --gen_anchors --quiet --infile tfiles/test1.wml --gen_toc --outfile '' --toc_file test1a_toc.html";
$result = system($command);
ok($result == 0, 'hypertoc generated toc from test1.wml');

# compare the files
$result = compare('test1a_toc.html', 'tfiles/good_test1a_toc.html');
ok($result, 'hypertoc: test1a_toc.html matches good output exactly');

# clean up test1
if ($result) {
    unlink('test1a_toc.html');
}

#
# test with option file
#
$command = "perl -I lib scripts/hypertoc --argfile tfiles/test1b.args";
$result = system($command);
ok($result == 0, 'hypertoc generated toc (argfile) from test1.wml');

# compare the files
$result = compare('test1b_toc.html', 'tfiles/good_test1a_toc.html');
ok($result, 'hypertoc: test1b_toc.html matches good output exactly');

# clean up test1
if ($result) {
    unlink('test1b_toc.html');
}

