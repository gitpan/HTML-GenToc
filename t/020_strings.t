use Test::More tests => 5;
use HTML::GenToc;

# Insert your test code below
#===================================================

$toc = new HTML::GenToc(debug=>0,
	quiet=>1);

#----------------------------------------------------------
# string input and output
$html1 ="<H1>Cool header</H1>
<P>This is a paragraph.
<H2>Getting Cooler</H2>
<P>Another paragraph.
";

$html2 ="<H1><a name=\"Cool\">Cool header</a></H1>
<P>This is a paragraph.
<H2><a name=\"Getting\">Getting Cooler</a></H2>
<P>Another paragraph.
";

$out_str = $toc->generate_anchors(infile=>['fred.html'],
    outfile=>'',
    to_string=>1,
    in_string=>$html1,
    toc_entry=>{
	'H1' =>1,
	'H2' =>2,
    },
    toc_end=>{
	'H1' =>'/H1',
	'H2' =>'/H2',
    },
);

is($out_str, $html2, 'generate_anchors matches strings');

$out_str = $toc->generate_toc(infile=>['fred.html'],
    outfile=>'',
    toc_file=>'',
    to_string=>1,
    in_string=>$html2,
);

$ok_toc_str1='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML//EN">
<html>
<head>
<title>Table of Contents</title>
</head>
<body>
<h1>Table of Contents</h1>
<ul>
<li><a href="fred.html#Cool">Cool header</a>
<ul>
<li><a href="fred.html#Getting">Getting Cooler</a></li>
</ul>
</li>
</ul>
</body>
</html>
';

is($out_str, $ok_toc_str1, 'generate_toc matches toc string');

$out_str = $toc->generate_toc(infile=>['fred.html'],
    outfile=>'',
    to_string=>1,
    in_string=>$html2,
    inline=>1,
    toc_tag=>'/H1',
    toc_tag_replace=>0,
    toclabel=>'',
);

$ok_toc_str2='<H1><a name="Cool">Cool header</a></H1>
<ul>
<li><a href="#Cool">Cool header</a>
<ul>
<li><a href="#Getting">Getting Cooler</a></li>
</ul>
</li>
</ul>

<P>This is a paragraph.
<H2><a name="Getting">Getting Cooler</a></H2>
<P>Another paragraph.
';

is($out_str, $ok_toc_str2, 'generate_toc matches inline toc string');

#
# Reset
undef $toc;
$toc = new HTML::GenToc(debug=>0,
	quiet=>1);

$html1 ="<H1>Cool header</H1>
<P>This is a paragraph.
<H2>Getting Cooler</H2>
<P>Another paragraph.
";

$html2 ="<H1 ID='Cool'>Cool header</H1>
<P>This is a paragraph.
<H2 ID='Getting'>Getting Cooler</H2>
<P>Another paragraph.
";

$out_str = $toc->generate_anchors(infile=>['fred.html'],
    outfile=>'',
    to_string=>1,
    use_id=>1,
    in_string=>$html1,
    toc_entry=>{
	'H1' =>1,
	'H2' =>2,
    },
    toc_end=>{
	'H1' =>'/H1',
	'H2' =>'/H2',
    },
);

is($out_str, $html2, 'generate_anchors (ID) matches strings');

$out_str = $toc->generate_toc(infile=>['fred.html'],
    outfile=>'',
    toc_file=>'',
    to_string=>1,
    in_string=>$html2,
);

$ok_toc_str1='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML//EN">
<html>
<head>
<title>Table of Contents</title>
</head>
<body>
<h1>Table of Contents</h1>
<ul>
<li><a href="fred.html#Cool">Cool header</a>
<ul>
<li><a href="fred.html#Getting">Getting Cooler</a></li>
</ul>
</li>
</ul>
</body>
</html>
';

is($out_str, $ok_toc_str1, 'generate_toc (ID) matches toc string');

