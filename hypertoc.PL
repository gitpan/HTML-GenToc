use ExtUtils::configPL;
<<--startperl-->> -w
##---------------------------------------------------------------------------##

=head1 NAME

hypertoc - Perl program to generate a table of contents for HTML documents

=head1 SYNOPSIS

hypertoc --help | --manpage | --man_help | --man

hypertoc [I<common options>] --gen_anchors [I<gen_anchors options>] file ...

hypertoc [I<common options>] --gen_toc [I<gen_toc options>] file ...

where I<common options> are:

[--bak I<string> | --debug | --infile I<file> | --notoc_match I<string> | --overwrite | --quiet | --toc_after I<tag=suffix> | --toc_before I<tag=prefix> | --toc_end I<tag=endtag> | --toc_entry I<tag=level> | --tocmap I<file>]

and I<gen_anchors options> are:

[--outfile I<file> | --useorg]

and I<gen_toc options> are:

[--entrysep I<string> | --footer I<file> | --header I<file> | --inline | --ol | --textonly | --title I<string> | --toc_file I<file> | --toc I<file> | --toc_label I<string> | --toc_tag I<string> | --toc_tag_replace | --toc_only | --notoc_only | --toclabel I<string>]

=head1 DESCRIPTION

hypertoc allows you to specify "significant elements" that will be
hyperlinked to in a "Table of Contents" (ToC) for a given set of HTML
documents.

Basically, the ToC generated is a multi-level level list containing
links to the significant elements. hypertoc inserts the links into the
ToC to significant elements at a level specified by the user.

B<Example:>

If H1s are specified as level 1, than they appear in the first
level list of the ToC. If H2s are specified as a level 2, than
they appear in a second level list in the ToC.

There are two phases to the ToC generation.  The first phase
(--gen_anchors) is to put suitable anchors into the HTML documents, and the
second phase (--gen_toc) is to generate the ToC from HTML documents which
have anchors in them for the ToC to link to.  Depending on what options are
chosen, it may or may not make sense to apply both phases in the same
command.  It is merely a convenient shorthand; applying both phases in the
same command is the equivalent of calling hypertoc with --gen_anchors
and then hypertoc with --gen_toc with the same arguments.

B<Example:>

    hypertoc --gen_anchors --gen_toc --overwrite --inline index.html

is the equivalent of

    hypertoc --gen_anchors --overwrite index.html;
    hypertoc --gen_toc --inline --overwrite index.html

If you want more control over how your ToC is created, it may be better
to do both phases separately.

hypertoc also supports the ability to incorporate the ToC into the HTML
document itself via the -inline option.

In order for hypertoc to support linking to significant elements,
hypertoc inserts anchors into the significant elements.  One can
use hypertoc as a filter, outputing the result to another file,
or one can overwrite the original file, with the original backed
up with a suffix (default: "org") appended to the filename.

One can also define options in a config file as well as on the command-line.

=head1 OPTIONS

=head2 A Note about Options

Options can start with "--" or "-"; boolean options can be negated
by preceding them with "no"; options with hash or array values
can be added to by giving the option again for each value.

See L<Getopt::Long> for more information.

If the Getopt::ArgvFile module is installed, then groups of options can
be read from a file or files designated by the @ character preceding
the name.  For example:

    hypertoc --gen_anchors @gen_anch_options  myfile.html

See L<Options Files> for more information.

=head2 Common Options

The following arguments apply to both generating anchors and generating
table-of-contents phases.

=over 4

=item *
--bak I<string>

If the input file/files is/are being overwritten (--overwrite is on), copy
the original file to "I<filename>.I<string>".  If the value is empty, there
is no backup file written.
(default:org)

=item *
--debug

Enable verbose debugging output.  Used for debugging this module;
in other words, don't bother.
(default:off)

=item *
--infile I<file>

Input file.  This is a cumulative list argument.  If you want to process
more than one file, just add another --infile I<file> to the list of
arguments.
(default:undefined)

=item *
--help

Print a short help message and exit.

=item *
--man_help | --manpage | --man

Print all documentation and exit.

=item *
--notoc_match I<string>

If there are certain individual tags you don't wish to include in the table
of contents, even though they match the "significant elements", then
if this pattern matches contents inside the tag (not the body),
then that tag will not be included, either in generating anchors
nor in generating the ToC.
(default: class="notoc")

=item *
--overwrite

Overwrite the input file with the output.  If this is in effect, --outfile
and --toc_file are ignored. Used in I<generate_anchors> for creating the
anchors "in place" and in I<generate_toc> if the --inline option is in
effect.  (default:off)

=item *
--quiet

Suppress informative messages.

=item *
--toc_after I<tag>=I<suffix>

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<suffix> is what is required
to be appended to the Table of Contents entry generated for that tag.
This is a cumulative hash argument.
(default: undefined)

=item *
--toc_before I<tag>=I<prefix>

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<prefix> is what is required
to be prepended to the Table of Contents entry generated for that tag.
This is a cumulative hash argument.
(default: undefined)

=item *
--toc_end I<tag>=I<endtag>

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<endtag> the HTML tag which
marks the end of the element.  When matching in the input file, case
is ignored (but make sure that all your I<tag> options referring to the same
tag are exactly the same!).  This is a cumulative hash argument.
(default: H1=/H1  H2=/H2)

=item *
--toc_entry I<tag>=I<level>

For defining significant elements.  The I<tag> is the HTML tag which marks
the start of the element.  The I<level> is what level the tag is considered
to be.  The value of I<level> must be numeric, and non-zero. If the value
is negative, consective entries represented by the significant_element will
be separated by the value set by --entrysep option.
This is a cumulative hash argument.
(default: H1=1  H2=2)

=item *
--tocmap I<file>

ToC map file defining significant elements.  This is read in immediately,
and overrides any previous toc_entry, toc_end, toc_before and toc_after
options.  However, they can be cleared and/or added to by later options.
See L<ToC Map File> for further information.

=back 4

=head2 Generate Anchors Options

These arguments apply only to generating anchors,
but see above for common arguments.

=over 4

=item *
--outfile I<file>

File to write the output to.  This is where the modified be-anchored HTML
output goes to.  Note that it doesn't make sense to use this option if you
are processing more than one file.  If you give '-' as the filename, then
output will go to STDOUT.
(default: STDOUT)

=item *
--useorg	

Use pre-existing backup files as the input source; that is, files of the
form I<infile>.I<bak>  (see --infile and --bak).

=back 4

=head2 Generate TOC Options

These arguments apply only to generating a table-of-contents,
but see above for common arguments.

=over 4

=item *
--entrysep I<string>

Separator string for non-E<lt>liE<gt> item entries
(default: ", ")

=item *
--footer I<file>

File containing footer text for ToC

=item *
--header I<file>

File containing header text for ToC.

=item *
--inline	

Put ToC in document at a given point.
See L<Inlining the ToC> for more information.

=item *
--ol

Use an ordered list for level 1 ToC entries.

=item *
--textonly	

Use only text content in significant elements.

=item *
--title I<string>

Title for ToC page (if not using --header or --inline or --toc_only)
(default: "Table of Contents")

=item *
--toc_file I<file> / --toc I<file>

File to write the output to.  This is where the ToC goes.
If you give '-' as the filename, then output will go to STDOUT.
(default: STDOUT)

=item *
--toc_label I<string>

HTML text that labels the ToC.  Always used.
(default: "E<lt>H1E<gt>Table of ContentsE<lt>/H1E<gt>")


=item *
--toc_tag I<string>

If a ToC is to be included inline, this is the pattern which is used to
match the tag where the ToC should be put.  This can be a start-tag, an
end-tag or a comment, but the E<lt> should be left out; that is, if you
want the ToC to be placed after the BODY tag, then give "BODY".  If you
want a special comment tag to make where the ToC should go, then include
the comment marks, for example: "!--toc--" (default:BODY)

=item *
--toc_tag_replace

In conjunction with --toc_tag, this is a flag to say whether the given tag
should be replaced, or if the ToC should be put after the tag.
(default:false)

=item *
--toc_only / --notoc_only

Output only the Table of Contents, that is, the Table of Contents plus
the toc_label.  If there is a --header or a --footer, these will also be
output.
If --toc_only is false (i.e. --notoc_only is set) then if there is no
--header, and --inline is not true, then a suitable HTML page header will
be output, and if there is no --footer and --inline is not true,
then a HTML page footer will be output.
(default:--notoc_only)

=item *
--toclabel I<string>

(same as --toc_label)

=back 4

=head1 FILE FORMATS

=head2 Options Files

Options can be given in files as well as on the command-line by
flagging an option file with @I<filename> in the command-line.
Also, the files ~/.hypertocrc and ./.hypertocrc are checked for options.

The format is as follows:
Lines starting with # are comments.  Lines enclosed in PoD markers are
also comments.  Blank lines are ignored.  The options themselves
should be given the way they would be on the command line, that is,
the option name (I<including> the --) followed by its value (if any).

For example:

    # set the ToC to be three-level
    --toc_entry H1=1
    --toc_entry H2=2
    --toc_entry H3=3

    --toc_end H1=/H1
    --toc_end H2=/H2
    --toc_end H3=/H3

See L<Getopt::ArgvFile> for more information.

=head2 ToC Map File

For backwards compatibility with htmltoc, this method of specifying
significant elements for the ToC is retained.

The ToC map file allows you to specify what significant elements to
include in the ToC, what level they should appear in the ToC, and any
text to include before and/or after the ToC entry. The format of the map
file is as follows:

    significant_element:level:sig_element_end:before_text,after_text
    significant_element:level:sig_element_end:before_text,after_text
    ...

Each line of the map file contains a series of fields separated by the
`:' character. The definition of each field is as follows:

=over 4

=item *
significant_element

The tag name of the significant element. Example values are H1,
H2, H5. This field is case-insensitive.

=item *
level

What level the significant element occupies in the ToC. This
value must be numeric, and non-zero. If the value is negative,
consective entries represented by the significant_element will
be separated by the value set by -entrysep option.

=item *
sig_element_end (Optional)

The tag name that signifies the termination of the
significant_element.

Example: The DT tag is a marker in HTML and not a container.
However, one can index DT sections of a definition list by
using the value DD in the sig_element_end field (this does
assume that each DT has a DD following it).

If the sig_element_end is empty, then the corresponding end tag of the
specified significant_element is used. Example: If H1 is the
significant_element, then the program looks for a "E<lt>/H1E<gt>" for
terminating the significant_element.

Caution: the sig_element_end value should not contain the `E<lt>`
and `E<gt>' tag delimiters. If you want the sig_element_end to be
the end tag of another element than that of the
significant_element, than use "/element_name".

The sig_element_end field is case-insensitive.

=item *
before_text,after_text (Optional)

This is literal text that will be inserted before and/or after
the ToC entry for the given significant_element. The
before_text is separated from the after_text by the `,'
character (which implies a comma cannot be contained in the
before/after text). See examples following for the use of this
field.

=back 4

In the map file, the first two fields MUST be specified.

Following are a few examples to help illustrate how a ToC map file
works.

B<EXAMPLE 1>

The following map file reflects the default mapping used if no
map file is explicitly specified:

    # Default mapping
    # Comments can be inserted in the map file via the '#' character
    H1:1 # H1 are level 1 ToC entries
    H2:2 # H2 are level 2 ToC entries

B<EXAMPLE 2>

The following map file makes use of the before/after text fields:

    # A ToC map file that adds some formatting
    H1:1::<STRONG>,</STRONG>      # Make level 1 ToC entries <STRONG>
    H2:2::<EM>,</EM>              # Make level 2 entries <EM>
    H2:3                          # Make level 3 entries as is

B<EXAMPLE 3>

The following map file tries to index definition terms:

    # A ToC map file that can work for Glossary type documents
    H1:1
    H2:2
    DT:3:DD:<EM>,<EM>    # Assumes document has a DD for each DT, otherwise ToC
                       # will get entries with alot of text.

=head1 DETAILS

See B<ToC Map File>
on how to tell hypertoc what are the significant
elements and at what level they should occur in the ToC.

=head2 Formatting the ToC

The ToC Map File gives you control on how the ToC entries may look,
but there are other options to affect the final appearance of the
ToC file created.

With the -header option, the contents of the given file will be prepended
before the generated ToC. This allows you to have introductory text,
or any other text, before the ToC.

=over 4

=item Note:

If you use the -header option, make sure the file specified
contains the opening HTML tag, the HEAD element (containing the
TITLE element), and the opening BODY tag. However, these
tags/elements should not be in the header file if the -inline
options is used. See L<Inlining the ToC> for information on what
the header file should contain for inlining the ToC.

=back 4

With the --toc_label option, the contents of the given string will be
prepended before the generated ToC (but after any text taken from a
--header file).

With the -footer option, the contents of the file will be appended
after the generated ToC.

=over 4

=item Note:

If you use the -footer, make sure it includes the closing BODY
and HTML tags (unless, of course, you are using the --inline option).

=back 4

If the -header option is not specified, the appropriate starting
HTML markup will be added, unless the --toc_only option is specified.
If the -footer option is not specified, the appropriate closing
HTML markup will be added, unless the --toc_only option is specified.

If you do not want/need to deal with header, and footer, files, then
you are alloed to specify the title, -title option, of the ToC file;
and it allows you to specify a heading, or label, to put before ToC
entries' list, the -toclabel option. Both options have default values,
see L<OPTIONS> for more information on each option.

If you do not want HTML page tags to be supplied, and just want
the ToC itself, then specify the --toc_only option.
If there are no --header or --footer files, then this will simply
output the contents of --toc_label and the ToC itself.

=head2 Inlining the ToC

The ability to incorporate the ToC directly into an HTML document
is supported via the -inline option.

Inlining will be done on the first file in the list of files processed,
and will only be done if that file contains an opening tag matching the
--toc_tag value.

If --overwrite is true, then the first file in the list will be
overwritten, with the generated ToC inserted at the appropriate spot.
Otherwise a modified version of the first file is output to either STDOUT
or to the output file defined by the --toc_file option.

The options --toc_tag and --toc_tag_replace are used to determine where
and how the ToC is inserted into the output.

B<Example 1>

    # this is the default
    --toc_tag BODY --notoc_tag_replace

This will put the generated ToC after the BODY tag of the first file.
If the --header option is specified, then the contents of the specified
file are inserted after the BODY tag.  If the --toc_label option is not
empty, then the text specified by the --toc_label option is inserted.
Then the ToC is inserted, and finally, if the --footer option is
specified, it inserts the footer.  Then the rest of the input file
follows as it was before.

B<Example 2>

    --toc_tag '!--toc--' --toc_tag_replace

This will put the generated ToC after the first comment of the form
<!--toc-->, and that comment will be replaced by the ToC
(in the order
--header
--toc_label
ToC
--footer)
followed by the rest of the input file.

=over 4

=item Note:

The header file should not contain the beginning HTML tag
and HEAD element since the HTML file being processed should
already contain these tags/elements.

=back 4

=head1 EXAMPLES

B<Create an inline ToC for one file>

    hypertoc --inline --gen_anchors --overwrite --gen_toc index.html

This will create anchors in C<index.html>, create a ToC with
a heading of "Table of Contents" and place it after the BODY
tag of C<index.html>

Note that the file in "index.html.org" won't actually be the original file,
but will be the version with the anchors in it, after the gen_anchors
phase.  This is because the command is the equivalent of:

    hypertoc --gen_anchors --overwrite index.html

followed by

    hypertoc --gen_toc --inline --gen_anchors --overwrite index.html

After the first phase, the file C<index.html.org> contains the original
file; then the second phase takes the be-anchored file as its input,
and backs I<it> up to C<index.html.org>, overwriting the first original
file.

B<Create a ToC file from multiple files>

First, create the anchors.

    hypertoc --gen_anchors --overwrite index.html fred.html george.html

Then create the ToC

    hypertoc --gen_toc --toc_file table.html

B<Create an inline ToC after the first heading of the first file>

    hypertoc --gen_anchors --inline --overwrite --gen_toc --toc_tag /H1 \
    --notoc_tag_replace --toc_label "" index.html fred.html george.html

This will create anchors in the C<index.html>, C<fred.html> and
C<george.html> files, create a ToC with no header and place it after the
first H1 header in C<index.html> and back up the original files to
C<index.html.org>, C<fred.html.org> and C<george.html.org>

Note that the file in "index.html.org" won't actually be the original file,
but will be the version with the anchors in it, after the gen_anchors
phase.

=head1 NOTES

=over 4

=item *

hypertoc is smart enough to detect anchors inside significant
elements. If the anchor defines the NAME attribute, hypertoc uses
the value. Else, it adds its own NAME attribute to the anchor.

=item *

The TITLE element is treated specially if specified in the ToC map
file. It is illegal to insert anchors (A) into TITLE elements.
Therefore, hypertoc will actually link to the filename itself
instead of the TITLE element of the document.

=item *

hypertoc will ignore significant elements if it does not contain
any non-whitespace characters. A warning message is generated if
such a condition exists.

=back 4

=head1 CAVEATS

=over 4

=item *

Version 2.00 of hypertoc behaves slightly differently in regard to
default values for hash options than did the earlier (1.x) versions.
In the 1.x versions, all user options for things like --toc_entry,
--toc_end, --toc_before and --toc_after were I<added> to the default
values; the default values had to be explicitly CLEARed.  Now, if
any value is given for these options, the default value is I<replaced>
for that option.

=item *

Care needs to be taken when using --gen_anchors and --gen_toc in the same
command, because the options for both of them may interact in ways one does
not expect.  Particularly of note is if one is using --inline and
--overwrite -- the backup file will not be the original one.

=item *

When using --inline, care needs to be taken if overwriting -- if
one sets the ToC to be included after a given tag (such as the default
BODY) then if one runs the command repeatedly one could get multiple
ToCs in the same file, one after the other.

=item *

hypertoc is not very efficient (memory and speed), and can be
extremely slow for large documents.

=item *

Invalid markup will be generated if a significant element is
contained inside of an anchor. For example:

    <A NAME="foo"><H1>The FOO command</H1></A>

will be converted to (if H1 is a significant element),

    <A NAME="foo"><H1><A NAME="xtocidX">The</A> FOO command</H1></A>

which is illegal since anchors cannot be nested.

It is better style to put anchor statements within the element to
be anchored. For example, the following is preferred:

    <H1><A NAME="foo">The FOO command</A></H1>

hypertoc will detect the "foo" NAME and use it.

=item *

NAME attributes without quotes are not recognized.

=back 4

=head1 BUGS

Tell me about them.

=head1 PREREQUISITES

    Getopt::Long
    Getopt::ArgvFile
    Pod::Usage
    HTML::GenToc
    perldoc

=head1 SCRIPT CATEGORIES

Web

=head1 ENVIRONMENT

=over 4

=item HOME

hypertoc looks in the HOME directory for config files.

=back 4

=head1 FILES

These files are only read if the Getopt::ArgvFile module is
available on the system.

=over 4

=item C<~/.hypertocrc>

User configuration file.

=item C<.hypertocrc>

Configuration file in the current working directory; overrides
options in C<~/.hypertocrc> and is overridden by command-line options.

=back 4

=head1 SEE ALSO

perl(1)
htmltoc(1)
HTML::GenToc
Getopt::ArgvFile
Getopt::Long

=head1 AUTHOR

Kathryn Andersen      http://www.katspace.com
based on htmltoc by
Earl Hood       ehood AT medusa.acs.uci.edu

=head1 COPYRIGHT

Copyright (C) 1994-1997  Earl Hood, ehood AT medusa.acs.uci.edu
Copyright (C) 2002 Kathryn Andersen

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=head1 HISTORY

=over 4

=item Version 1.0

initial version

=item Version 1.1

added --notoc_match option

=item Version 1.2

Revamped the --manpage option to prevent duplication
of effort when HTML::GenToc changes its options.
This means that
    hypertoc --manpage

actually gives more information than
    perldoc hypertoc

because the --manpage option takes certain sections directly
from the documentation of HTML::GenToc rather than having to document
the same thing twice.

=item Version 1.3

Expanded the SYNOPSIS to actually contain useful information.

=item Version 2.00

Made hypertoc part of the the HTML::GenToc distribution, and
changed version numbers to match.  Replaced AppConfig with Getopt::Long
and Getopt::ArgvFile.  Expanded the manpage so all documentation for
this script is back here in this file.

=back 4

=cut

#################################################################
# Globals
#
use vars qw($VERSION);
$VERSION = '2.02';

#################################################################
# Includes
require 5.005_03;
use Getopt::Long;
use Pod::Usage;
use HTML::GenToc;

#################################################################
# Subroutines

sub init_data ($) {
    my $data_ref = shift;

    my %args = ();
    $args{manpage} = 0;
    $args{debug} = 0;
    $args{version} = 0;
    $args{quiet} = 0;
    $args{help} = 0;
    $args{gen_anchors} = 0;
    $args{gen_toc} = 0;
    $args{infile} = [];

    $data_ref->{args} = \%args;
}

sub process_args ($) {
    my $data_ref = shift;
    my $args_ref = $data_ref->{args};

    my $ok = 1;

    # check the rc file if we can
    if (eval("require Getopt::ArgvFile")) {
	Getopt::ArgvFile::argvFile(
	    startupFilename=>'.hypertocrc',
	    home=>1,
	    current=>1);
    }
    $ok = GetOptions($args_ref,
	'help',
	'manpage|man_help',
	'debug',
	'version',
	'quiet!',
	'bak=s',
	'entrysep=s',
	'footer=s',
	'inline!',
	'header=s',
	'infile|file=s@',
	'notoc_match=s',
	'ol|ordered_list!',
	'overwrite!',
	'outfile=s',
	'textonly!',
	'title=s',
	'toclabel|toc_label=s',
	'tocmap=s',
	'toc_file|tocfile=s',
	'toc_tag|toctag=s',
	'toc_tag_replace!',
	'toc_only!',
	'toc_entry=s%',
	'toc_end=s%',
	'toc_before=s%',
	'toc_after=s%',
	'useorg!',
	'gen_toc|generate_toc',
	'gen_anchors|generate_anchors',
    );
    if (!$ok)
    {
	pod2usage({ -message => "$0",
		    -exitval => 1,
		    -verbose => 0,
	    });
    }

    if ($args_ref->{'version'})
    {
	print STDERR "$0 version: $VERSION\n";
	exit 0;
    }
    if ($args_ref->{'manpage'})
    {
	pod2usage({ -message => "$0 version $VERSION",
		    -exitval => 0,
		    -verbose => 2,
	    });
    }
    if ($args_ref->{'help'})
    {
	pod2usage({ -message => "$0 version $VERSION",
		    -exitval => 0,
		    -verbose => 1,
	    });
    }
    # transfer script-only things to the data-ref
    $data_ref->{gen_anchors} = $args_ref->{gen_anchors};
    undef $args_ref->{gen_anchors};
    $data_ref->{gen_toc} = $args_ref->{gen_toc};
    undef $args_ref->{gen_toc};
    undef $args_ref->{help};
    undef $args_ref->{manpage};
    undef $args_ref->{version};
    # make the object
    my $toc = HTML::GenToc->new(%{$args_ref});
    $data_ref->{toc} = $toc;
}

#################################################################
# Main

MAIN: {
    my %data = ();
    my $result = 0;
    init_data(\%data);
    process_args(\%data);

    # now the remainder must be input-files
    # Push the infiles onto the infile array,
    # because there might already have been infiles added with --infile.
    foreach my $df (@ARGV)
    {
	if ($data{toc}->{debug}) {
	    print STDERR "--infile $df\n";
	}
	push @{$data{toc}->{infile}}, $df;
    }

    if ($data{gen_anchors}) {
	if ($data{toc}->{debug}) {
	    print STDERR "doing gen_anchors\n";
	}
	if (!$data{toc}->generate_anchors()) {
	    $result = 1;
	}
    }
    if ($data{gen_toc}) {
	if ($data{toc}->{debug}) {
	    print STDERR "doing gen_toc\n";
	}
	if (!$data{toc}->generate_toc()) {
	    $result = 1;
	}
    }
    if ($data{toc}->{debug}) {
	print STDERR "result is $result\n";
    }
    exit $result;
}

# vim: sw=4 sts=4 ai
