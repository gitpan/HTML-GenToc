#! /usr/bin/perl

=head1 NAME

HTML::GenToc - Generate/insert anchors and a Table of Contents (ToC) for HTML documents.

=head1 SYNOPSIS

  use HTML::GenToc;

  # create a new object
  my $toc = new HTML::GenToc();

  my $toc = new HTML::GenToc(["--title", "Table of Contents",
			  "--toc", $my_toc_file,
			  "--tocmap", $my_tocmap_file,
    ]);

  my $toc = new HTML::GenToc(\@ARGV);

  # add further arguments
  $toc->args(["--toc_tag", "BODY",
	     "--toc_tag_replace", 0,
    ]);

  # generate anchors for a file
  $toc->generate_anchors(["--file", $html_file,
			 "--nooverwrite"
    ]);

  # generate a ToC from a file
  $toc->generate_toc(["--file", $html_file,
		     "--footer", $footer_file,
		     "--header", $header_file
    ]);


=head1 DESCRIPTION

HTML::GenToc allows you to specify "significant elements" that will be
hyperlinked to in a "Table of Contents" (ToC) for a given set of HTML
documents.  Also, it does not require said documents to be strict HTML;
this makes it suitable for using with templates and meta-languages such
as WML.

Basically, the ToC generated is a multi-level level list containing
links to the significant elements. HTML::GenToc inserts the links into the
ToC to significant elements at a level specified by the user.

B<Example:>

If H1s are specified as level 1, than they appear in the first
level list of the ToC. If H2s are specified as a level 2, than
they appear in a second level list in the ToC.

See L<ToC Map File> on how to tell HTML::GenToc what are the significant
elements and at what level they should occur in the ToC.

See L<Config File> on how to tell HTML::GenToc not only what are the
significant elements and their levels, but all options you want
to use as defaults.

There are two phases to the ToC generation.  The first phase is to
put suitable anchors into the HTML documents, and the second phase
is to generate the ToC from HTML documents which have anchors
in them for the ToC to link to.

For more information on controlling the contents of the created ToC, see
L<Formatting the ToC>.

HTML::GenToc also supports the ability to incorporate the ToC into the HTML
document itself via the -inline option.  See L<Inlining the ToC> for more
information.

In order for HTML::GenToc to support linking to significant elements,
HTML::GenToc inserts anchors into the significant elements.  One can
use HTML::GenToc as a filter, outputing the result to another file,
or one can overwrite the original file, with the original backed
up with a suffix (default: "org") appended to the filename.

=head2 Methods

Because this is a subclass of AppConfig, one can use all the power of
AppConfig for defining and parsing options/arguments.

All arguments can be set when the object is created, and further options
can be set on any method (though some may not make sense).  Methods
expect a reference to an array (which will then be processed as if it were
a command-line, which makes this very easy to use from scripts).

See L<A Note about Options> for more information.

See L<OPTIONS> for the options for all these methods.

=over 4

=item *
new

    $toc = new HTML::GenToc();

    $toc = new HTML::GenToc(\@args);

    $toc = new HTML::GenToc(["--config", $my_config_file,
        ]);

Creates a new HTML::GenToc object.
Optionally takes one argument, a reference to an array of arguments, which
will be used in invocations of other methods.

See L<Common Options> for arguments to this method.

=item *
generate_anchors

    $toc->generate_anchors(["--outfile", "index2.html",
        ]);

Generates anchors for the significant elements in the HTML documents.
Optionally takes one argument, a reference to an array of arguments, which
will be used to influence this method's behavour (and if arguments have
already been set earlier, they also will be taken into account).

See L<Common Options> and L<Generate Anchors Options>
for arguments to this method.

=item *
generate_toc

    $toc->generate_toc(\@args);

Generates a Table of Contents (ToC) for the significant elements in the
HTML documents.
Optionally takes one argument, a reference to an array of arguments, which
will be used to influence this method's behavour (and if arguments have
already been set earlier, they also will be taken into account).

See L<Common Options> and L<Generate TOC Options>
for arguments to this method.

=item *
args

    $toc->args(\@args);

    $toc->args(["--file", "CLEAR"]);

Updates the current arguments/options of the HTML::GenToc object.
Takes a reference to an array of arguments, which will be used
in invocations of other methods.

=item *
do_help

    $toc->do_help();

Output the default help or manpage message (and exit) if the --help or
--manpage options are set.  This is explicitly called inside
I<generate_anchors> and I<generate_toc>, so you only need to call this
if you wish to trigger the help action without having called those
methods.

If --manpage is true, this displays all the PoD documentation
of the calling program.  Otherwise, if --help is true, then this
displays the SYNOPSIS information from the PoD documentation
of the calling program.

=back 4

=head1 OPTIONS

=head2 A Note about Options

Options can start with '--' or '-'.  If it is a yes/no option, that is the
only part of the option (and such an option can be prefaced with "no" to
negate it).  If the option takes a value, then the list must be
("--option", "value").

Order does matter.  For options which are yes/no options, a later
argument overrides an earlier one.  For arguments which are single values,
a later value replaces an earlier one.  For arguments which are
cumulative, a later argument is added on to the list.  For such arguments,
if you want to clear the old value and start afresh, give it the
special value of CLEAR.

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
--config I<file>

A file containing options, which is read in, and the options from the file
are treated as if they were in the argument list at the point at which the
--config option was.  See L<Config File> for more information.

=item *
--debug

Enable verbose debugging output.  Used for debugging this module;
in other words, don't bother.
(default:off)

=item *
--file I<file>

Input file.  This is a cumulative list argument.  If you want to process
more than one file, just add another --file I<file> to the list of
arguments.  If you want to process a different file, you need to CLEAR this
argument first.
(default:undefined)

=item *
--infile I<file>

(same as --file)

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
This is a cumulative hash argument; if you wish to clear it,
give --toc_after CLEAR to do so.
(default: undefined)

=item *
--toc_before I<tag>=I<prefix>

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<prefix> is what is required
to be prepended to the Table of Contents entry generated for that tag.
This is a cumulative hash argument; if you wish to clear it,
give --toc_before CLEAR to do so.
(default: undefined)

=item *
--toc_end I<tag>=I<endtag>

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<endtag> the HTML tag which
marks the end of the element.  When matching in the input file, case
is ignored (but make sure that all your I<tag> options referring to the same
tag are exactly the same!).  This is a cumulative hash argument; if you
wish to clear the default, give --toc_end CLEAR to do so.
(default: H1=/H1  H2=/H2)

=item *
--toc_entry I<tag>=I<level>

For defining significant elements.  The I<tag> is the HTML tag which marks
the start of the element.  The I<level> is what level the tag is considered
to be.  The value of I<level> must be numeric, and non-zero. If the value
is negative, consective entries represented by the significant_element will
be separated by the value set by --entrysep option.
This is a cumulative hash argument; if you wish to clear the default,
give --toc_entry CLEAR to do so.
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

=head2 Config File

The Config file is a way of specifying default options (including
specifying significant elements) in a file instead of having to
do it when you call this.

The file may contain blank lines and comments (prefixed by
'#') which are ignored.  Continutation lines may be marked
by ending the line with a '\'.

    # this is a comment
    toc_label = <h1>Table of Wonderful and Inexplicably Joyous \
    Things You Want To Know About</h1>

Options that are simple flags and do not expect an argument can be
specified without any value.  They will be set with the value 1, with any
value explicitly specified (except "0" and "off") being ignored.  The
option may also be specified with a "no" prefix to implicitly set the
variable to 0.

    quiet                                 # on (1)
    quiet = 1                             # on (1)
    quiet = 0                             # off (0)
    quiet off                             # off (0)
    quiet on                              # on (1)
    quiet mumble                          # on (1)
    noquiet                               # off (0)

Options that expect an argument (but are not cumulative) will
be set to whatever follows the variable name, up to the end of the
current line.  An equals sign may be inserted between the option
and value for clarity.

    bak = org
    bak   bak

Each subsequent re-definition of the option value overwites
the previous value.  From the above example, the value of the backup
suffix would now be "bak".

Some options are simple cumulative options, with each subsequent
definition of the option adding to the list of previously set values
for that option.

    file = index.html
    file = about.html

If you want to clear the list and start again, give the CLEAR option.

    file = CLEAR

Some options are "hash" cumulative options, building up a hash
of key=value pairs.  Each subsequent definition creates a new
key and value in the hash array of that option.

    toc_entry H1=1
    toc_entry H2=2
    toc_end H1=/H1
    toc_end H2=/H2
    toc_before H1=<STRONG>
    toc_after H1=</STRONG>

This is probably the most useful part, because one can use this to
define the significant elements, and other defaults all in one file,
rather than having a separate tocmap file.

If you want to clear the hash and start again, give the CLEAR option.

    toc_before CLEAR
    toc_after CLEAR

The '-' prefix can be used to reset a variable to its
default value and the '+' prefix can be used to set it to 1.

    -quiet
    +debug

Option values may contain references to other options, environment
variables and/or users' home directories.

    tocmap = ~/.tocmap	# expand '~' to home directory

    quiet = ${TOC_QUIET}   # expand TOC_QUIET environment variable

The configuration file may have options arranged in blocks.  A block
header, consisting of the block name in square brackets, introduces a
configuration block.  The block name and an underscore are then prefixed to
the names of all options subsequently referenced in that block.  The
block continues until the next block definition or to the end of the
current file.

    [toc]
    entry H1=1              # toc_entry H1=1
    entry H2=2              # toc_entry H2=2
    end H1=/H1              # toc_end H1=/H1
    end H2=/H2              # toc_end H2=/H2

See AppConfig for more information.

=head2 ToC Map File

For backwards compatibility with htmltoc, this method of specifying
significant elements for the ToC is retained, but see also L<Config File>
for an alternative method.

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
    toc_tag = BODY
    toc_tag_replace = off

This will put the generated ToC after the BODY tag of the first file.
If the --header option is specified, then the contents of the specified
file are inserted after the BODY tag.  If the --toc_label option is not
empty, then the text specified by the --toc_label option is inserted.
Then the ToC is inserted, and finally, if the --footer option is
specified, it inserts the footer.  Then the rest of the input file
follows as it was before.

B<Example 2>

    toc_tag = !--toc--
    toc_tag_replace = on

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

=head1 EXAMPLE

A simple script to process HTML documents.

    #! /usr/bin/perl -w
    require 5.005_03;
    use HTML::GenToc;

    my $toc = HTML::GenToc->new(\@ARGS);
    $toc->generate_anchors();
    $toc->generate_toc();


=head1 NOTES

=over 4

=item *

One cannot use "CLEAR" as a value for the cumulative arguments.

=item *

HTML::GenToc is smart enough to detect anchors inside significant
elements. If the anchor defines the NAME attribute, HTML::GenToc uses
the value. Else, it adds its own NAME attribute to the anchor.

=item *

The TITLE element is treated specially if specified in the ToC map
file. It is illegal to insert anchors (A) into TITLE elements.
Therefore, HTML::GenToc will actually link to the filename itself
instead of the TITLE element of the document.

=item *

HTML::GenToc will ignore significant elements if it does not contain
any non-whitespace characters. A warning message is generated if
such a condition exists.

=back 4

=head1 LIMITATIONS

=over 4

=item *

HTML::GenToc is not very efficient (memory and speed), and can be
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

HTML::GenToc will detect the "foo" NAME and use it.

=item *

NAME attributes without quotes are not recognized.

=back 4

=head1 BUGS

Tell me about them.

=head1 PREREQUSITES

HTML::GenToc requires Perl 5.005_03 or later.

It also requires HTML::SimpleParse, AppConfig, Getopt::Long,
Data::Dumper (only for debugging purposes)
and Pod::Usage.

=head1 EXPORT

None by default.

=head1 SEE ALSO

perl(1)
htmltoc(1)
perlpod(1)
AppConfig
Getopt::Long
Data::Dumper
HTML::SimpleParse

=head1 AUTHOR

Kathryn Andersen      rubykat@katspace.com    http://www.katspace.com
based on htmltoc by
Earl Hood       ehood@medusa.acs.uci.edu

=head1 COPYRIGHT

Copyright (C) 1994-1997  Earl Hood, ehood@medusa.acs.uci.edu
Copyright (C) 2002 Kathryn Andersen, rubykat@katspace.com

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

=cut

package HTML::GenToc;

require 5.005_03;
use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
BEGIN {
    @ISA	= qw(Exporter AppConfig);
    require Exporter;
    use AppConfig qw(:argcount);
    use Data::Dumper;
    use HTML::SimpleParse;
    use Pod::Usage;
}

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
# Well, since this is an Object, we ain't exportin' nuttin'
@EXPORT = qw();

@EXPORT_OK = qw();

$VERSION = '1.3';

#################################################################
use constant GEN_TOC => "GEN_TOC";

#---------------------------------------------------------------#
# Object interface
#---------------------------------------------------------------#

# Name: new
# Creates a new instance of a Toc
# Args:
#   $invocant
#   \@args (array of command-line arguments in Args style)
sub new {
    my $invocant = shift;
    my $args_ref = (@_ ? shift : 0);

    my $class = ref($invocant) || $invocant; # Object or class name
    my $self = AppConfig->new({
	    CASE => 1,
	    CREATE => 0,
	    GLOBAL => {
		ARGCOUNT => ARGCOUNT_NONE,
		EXPAND => AppConfig::EXPAND_ALL,
		ACTION => \&do_var_action,
	    }
	});

    init_our_data($self);

    # re-bless self
    bless($self, $class);

    # and set with the passed-in args
    if ($args_ref && @{$args_ref}) {
	if (!$self->args($args_ref)) {
	    print STDERR "Unrecognised option, try --help\n";
	    return 0;
	}
    }

    return $self;
} # new

# Name: args
# sets arguments for a given Toc
# Args:
#   $self
#   \@args (array of command-line arguments in Args style)
sub args {
    my $self = shift;
    my $args_ref = (@_ ? shift : 0);

    # and set with the passed-in args
    if ($args_ref && @{$args_ref}) {
	if (!$self->SUPER::args($args_ref)) {
	    print STDERR "Unrecognised option, try --help\n";
	    return 0;
	}
    }

    return 1;
} # args

# Name: generate_anchors
# Creates a version of the HTML with anchors in it
# Args:
#   $self
#   \@args (array of command-line arguments in Args style)
sub generate_anchors ($;$) {
    my $self = shift;
    my $args_ref = (@_ ? shift : 0);

    # and set with the passed-in args
    if ($args_ref && @{$args_ref}) {
	if (!$self->args($args_ref)) {
	    print STDERR "Unrecognised option, try --help\n";
	    return 0;
	}
    }

    # print help message if required
    $self->do_help();

    %{$self->{__anchors}} = ();
    my @new_html;
    my $not_to_stdout = 0;
    my $outhandle = *STDOUT;
    if ($self->outfile() && $self->outfile() ne "-") {
	open(FILEOUT, "> " . $self->outfile())
	    || die "Error: unable to open ", $self->outfile(), ": $!\n";
	$outhandle = *FILEOUT;
	$not_to_stdout = 1;
    }
    my $i = 0;
    foreach my $fn (@{$self->infile()}) {
	$self->{__file} = $fn;
	my $infn = $fn;
	my $bakfile = $fn . "." . $self->bak();
	if ($self->useorg()
	    && $self->bak()
	    && -e $bakfile) {
	    # use the old backup files as source
	    $infn = $bakfile;
	}
	@new_html = ();
	push @new_html, $self->make_anchors($infn);
	if ($self->overwrite()) {
	    if ($self->bak()
		&& !($self->useorg() && -e $bakfile))
	    {
		# copy the file to a backup
		print STDERR "Backing up ", $fn, " to ",
		    $bakfile, "\n"
		    unless $self->quiet();
		cp($fn, $bakfile);
	    }
	    open(FILEOUT, "> $fn")
		|| die "Error: unable to open ", $fn, ": $!\n";
	    $outhandle = *FILEOUT;
	    $not_to_stdout = 1;
	    print STDERR "Overwriting Anchors to ", $fn, "\n"
		unless $self->quiet();
	}
	elsif ($self->outfile() && $self->outfile() ne "-") {
	    print STDERR "Writing Anchors to ", $self->outfile(), "\n"
		unless $self->quiet();
	}
	print $outhandle @new_html;
	$i++;
    }
    print STDERR "$i files processed.\n"
	unless $self->quiet();
    if ($not_to_stdout) {
	close($outhandle);
    }

    return 1;
} # generate_anchors

# Name: generate_toc
# Creates a Table of Contents from the given HTML
# Args:
#   $self
#   \@args (array of command-line arguments in Args style)
sub generate_toc ($;$) {
    my $self = shift;
    my $args_ref = (@_ ? shift : 0);

    # and set with the passed-in args
    if ($args_ref && @{$args_ref}) {
	if (!$self->args($args_ref)) {
	    print STDERR "Unrecognised option, try --help\n";
	    return 0;
	}
    }

    # print help message if required
    $self->do_help();

    my @toc = ();
    # put the header at the start of the ToC if there is one
    if ($self->header()) {
	open(HEADER, $self->header())
	    || die "Error: unable to open ", $self->header(), ": $!\n";
	push @toc, <HEADER>;
	close (HEADER);
    }
    # if we are outputing a standalone page,
    # then make sure it can stand
    elsif (!$self->toc_only()
	&& !$self->inline()) {

	push @toc, qq|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML//EN">\n|,
			 "<html>\n",
			 "<head>\n";
	push @toc, "<title>", $self->title(), "</title>\n"  if $self->title();
	push @toc, "</head>\n",
			 "<body>\n";
    }

    # start the ToC with the ToC label
    if ($self->toclabel()) {
	push @toc, $self->toclabel();
    }
    $self->{__prevlevel} = 0;
    my $i = 0;
    my $bakfile;
    foreach my $fn (@{$self->infile()}) {
	$self->{__file} = $fn;
	my $infn = $fn;
	$bakfile = $fn . "." . $self->bak();
	if ($self->useorg()
	    && $self->bak()
	    && -e $bakfile) {
	    # use the old backup files as source
	    $infn = $bakfile;
	}
	push @toc, $self->make_toc($infn);
	$i++;
    }
    print STDERR "$i files processed.\n"
	unless $self->quiet();

    ## Close up open elements in ToC
    for ($i=$self->{__prevlevel}; $i > 0; $i--) {
	if ($self->ol() && $i == 1) {
	    push @toc, "</ol>\n";
	} else {
	    push @toc, "</ul>\n";
	}
	if ($i > 1) {
	    push @toc, "</li>";
	}
    }

    # add the footer, if there is one
    if ($self->footer()) {
	open(FOOTER, $self->footer())
	    || die "Error: unable to open ", $self->footer(), ": $!\n";
	push @toc, <FOOTER>;
	close (FOOTER);
    }
    # if we are outputing a standalone page,
    # then make sure it can stand
    elsif (!$self->toc_only()
	&& !$self->inline()) {

	push @toc, "</body>\n",
			 "</html>\n";
    }

    my $toc_str = join "", @toc;

    #
    #  Sent the full ToC to its final destination
    #
    my $not_to_stdout = 0;
    my $tochandle = *STDOUT;
    if ($self->toc_file() && $self->toc_file() ne "-") {
	open(TOCOUT, "> " . $self->toc_file())
	    || die "Error: unable to open ", $self->toc_file(), ": $!\n";
	$tochandle = *TOCOUT;
	$not_to_stdout = 1;
    }
    if ($self->inline()) {
	# either make a new output which is a modified copy
	# of the first file, or overwrite the first file.
	my $first_file = $self->infile()->[0];
	$bakfile = $first_file . "." . $self->bak();
	my @new_html;
	if ($self->useorg() && $self->bak() && -e $bakfile) {
	    @new_html = $self->put_toc_inline($toc_str, $bakfile);
	} else {
	    @new_html = $self->put_toc_inline($toc_str, $first_file);
	}
	if ($self->overwrite()) {
	    if ($self->bak()
		&& !($self->useorg() && -e $bakfile))
	    {
		# copy the file to a backup
		print STDERR "Backing up ", $first_file, " to ",
		    $bakfile, "\n"
		    unless $self->quiet();
		cp($first_file, $bakfile);
	    }
	    open(TOCOUT, "> $first_file")
		|| die "Error: unable to open ", $first_file, ": $!\n";
	    $tochandle = *TOCOUT;
	    $not_to_stdout = 1;
	    print STDERR "Overwriting ToC to ", $first_file, "\n"
		unless $self->quiet();
	}
	elsif ($self->toc_file() && $self->toc_file() ne "-") {
	    print STDERR "Writing Inline ToC to ", $self->toc_file(), "\n"
		unless $self->quiet();
	}
	print $tochandle @new_html;
    } else {
	if ($self->toc_file() && $self->toc_file() ne "-") {
	    print STDERR "Writing ToC to ", $self->toc_file(), "\n"
		unless $self->quiet();
	}
	print $tochandle $toc_str;
    }
    if ($not_to_stdout) {
	close($tochandle);
    }

    return 1;
} # generate_toc

#---------------------------------------------------------------#


#---------------------------------------------------------------#
# AppConfig-related subroutines

#--------------------------------#
# Name: do_var_action
#   ACTION function for hash AppConfig variables
# Args:
#   $state_ref -- reference to AppConfig::State
#   $name -- variable name
#   $value -- new value
sub do_var_action($$$) {
    my $state_ref = shift;
    my $name = shift;
    my $value = shift;

    my $parent = $state_ref->get(GEN_TOC);

    if ($name eq GEN_TOC) {
	# do nothing!
    }
    # clear the variable if given the value CLEAR
    elsif ($value eq "CLEAR") {
	if (ref($state_ref->get($name)) eq "HASH")
	{
	    %{$state_ref->get($name)} = ();
	}
	elsif (ref($state_ref->get($name)) eq "ARRAY")
	{
	    @{$state_ref->get($name)} = ();
	}
    }
    # if this is config, read in the given config file
    elsif ($name eq "config") {
	if ($state_ref->get('debug')) {
	    print STDERR ">>> reading in config file $value\n";
	}
	$parent->file($value);
	if ($state_ref->get('debug')) {
	    print STDERR "<<< read in config file $value\n";
	}
    }
    # if this is tocmap, read in the given tocmap file
    elsif ($name eq "tocmap") {
	if ($state_ref->get('debug')) {
	    print STDERR ">>> reading in tocmap file $value\n";
	}
	$parent->read_tocmap($value);
	if ($state_ref->get('debug')) {
	    print STDERR "<<< read in tocmap file $value\n";
	}
    }
    if ($state_ref->get('debug')) {
	print STDERR "=========\n changed $name to $value\n =========\n";
	if (ref($state_ref->get($name)) eq "HASH")
	{
	    print STDERR Dumper($state_ref->get($name));
	}
	elsif (ref($state_ref->get($name)) eq "ARRAY")
	{
	    print STDERR Dumper($state_ref->get($name));
	}
    }
} # do_var_action

#--------------------------------#
# Name: define_vars
#   define the variables which AppConfig will recognise
# Args:
#   $self
sub define_vars {
    my $self = shift;

    # since debug is checked in the action, set it first
    $self->define("debug", {
	    DEFAULT => 0,
	});

    # reference to self!  (do not change!)
    $self->define("GEN_TOC", {
		ARGCOUNT => ARGCOUNT_ONE,
    });
    $self->set(GEN_TOC, $self);

    #
    # All the options (alphabetical)
    #
    $self->define("bak=s", {
	DEFAULT => "org",
	});
    # name of a config file -- parsed immediately
    $self->define("config=s");

    $self->define("entrysep=s", {
	DEFAULT => ", ",
	});
    $self->define("footer=s");
    $self->define("help");
    $self->define("inline");
    $self->define("header=s");
    $self->define("infile|file=s@"); # names of files to be processed
    $self->define("man_help|manpage|man");
    $self->define("notoc_match=s", {
	DEFAULT => 'class="notoc"',
	});
    $self->define("ol");
    $self->define("overwrite", {
	DEFAULT => 0,
	});
    $self->define("outfile=s", {
	DEFAULT => "",
	});
    $self->define("quiet");
    $self->define("textonly");
    $self->define("title=s", {
	DEFAULT => "Table of Contents",
	});
    $self->define("toclabel|toc_label=s", {
	DEFAULT => "<h1>Table of Contents</h1>",
	});
    $self->define("tocmap=s");
    $self->define("toc_file|toc=s", {
	DEFAULT => "",
	});
    $self->define("toc_tag=s", {
	DEFAULT => "^BODY",
	});
    $self->define("toc_tag_replace", {
	DEFAULT => 0,
	});
    $self->define("toc_only", {
	DEFAULT => 0,
	});
    # define TOC entry elements
    $self->define("toc_entry=s%");
    # TOC entry element terminators
    $self->define("toc_end=s%");
    # before text for TOC entries
    $self->define("toc_before=s%");
    # after text for TOC entries
    $self->define("toc_after=s%");

    $self->define("useorg");

} # define_vars

#--------------------------------#
# Name: init_our_data
# Args:
#   $self
sub init_our_data ($) {
    my $self = shift;

    define_vars($self);

    # read in from the __DATA__ section
    $self->file(\*DATA);

    # accumulation variables
    $self->{__file} = "";	    # Current file being processed
    $self->{__prevlevel} = 0; # Previous ToC entry level
    my %anchors = ();
    $self->{__anchors} = \%anchors;

} # init_our_data

#--------------------------------#
# Name: do_help
# Args:
#   $self
sub do_help ($) {
    my $self = shift;

    if ($self->man_help()) {
	pod2usage({ -message => "$0",
		    -exitval => 0,
		    -verbose => 2,
	    });
    }
    if ($self->help()) {
	pod2usage({ -message => "$0",
		    -exitval => 0,
		    -verbose => 0,
	    });
    }

} # do_help

#--------------------------------#
# Name: read_tocmap
# Reads the ToC mapfile.
# Args:
#   $self
#   $tocmap
sub read_tocmap ($$) {
    my $self = shift;
    my $tocmap = shift;
    my @array;
    my @befaft;
    my @args = ();

    open(TOCMAP, $tocmap)
	|| die "Error: unable to open ", $tocmap, ": $!\n";

    # clear the old values of toc_entry, toc_end, toc_before and toc_after
    %{$self->get("toc_entry")} = ();
    %{$self->get("toc_end")} = ();
    %{$self->get("toc_before")} = ();
    %{$self->get("toc_after")} = ();
    while (<TOCMAP>) {
	next if /^\s*#/ || /^\s*$/;	# Skip comment/blank lines
	s/#.*$//;  s/\s//g;		# Remove eol comments and whitespaces
	@array = split(/:/, $_);	# Split line into fields
	if ($#array < 1) {		# Error checking
	    die "Error: ToC mapfile: less than 2 fields: line $.\n";
	} elsif ($array[1] !~ /^[-]?\d+$/ || $array[1] == 0) {
	    die "Error: ToC mapfile: ",
		"2nd field must be a non-zero number: line $.\n";
	}
	# set up the values as arguments to be parsed
	# store ToC tag and level
	push @args, "--toc_entry", "$array[0]=$array[1]";
	if ($array[2]) {		# Store end delimiter
	    push @args, "--toc_end", "$array[0]=$array[2]";
	} else {
	    push @args, "--toc_end", "$array[0]=/$array[0]";
	}
	if ($array[3]) {		# Store before/after text
	    @befaft = split(/,/, $array[3]);
	    push @args, "--toc_before", "$array[0]=$befaft[0]";
	    push @args, "--toc_after", "$array[0]=$befaft[1]";
	}
    }
    $self->args(\@args);
    close(TOCMAP);
}

#---------------------------------------------------------------#
# common subroutines

#--------------------------------#
# Name: cp
# copies file $src to $dst
# Args:
#   $src
#   $dst
sub cp ($$) {
    my($src, $dst) = @_;
    open (SRC, $src) ||
	die "Error: unable to open ", $src, ": $!\n";
    open (DST, "> $dst") ||
	die "Error: unable to open ", $dst, ": $!\n";
    print DST <SRC>;
    close(SRC);
    close(DST);
}

#---------------------------------------------------------------#
# generate_anchors related subroutines

#--------------------------------#
# Name: make_anchor_name
# Makes the anchor-name for one anchor
# Args:
#   $self
#   $file
sub make_anchor_name ($$) {
    my $self = shift;
    my $content = shift;

    my $name = "";

    if ($content !~ /^\s*$/) {
	# try to generate a unique anchor
	# try the first word of the content
	my @cont_arr = split(/\s/, $content);
	$name = shift @cont_arr;
	$name =~ s/^ *//;  # remove leading spaces
	$name =~ s/ *$//;  # remove trailing spaces

	$name =~ s/\&[a-z]*;//g;   # remove entities
	$name =~ s/[^a-zA-Z0-9]*//g;	# remove nonalphanumerics
	# try the second word of the content
	if ((!$name
	    || (defined $self->{__anchors}->{$name}
		&& $self->{__anchors}->{$name}))
	    && @cont_arr)
	{
	    $name .= shift @cont_arr;
	    $name =~ s/\&[a-z]*;//g;
	    $name =~ s/[^a-zA-Z0-9]*//g;
	}
	# now try adding a number
	my $anch_num = 1;
	my $word_name = $name;
	while (defined $self->{__anchors}->{$name}
	    && $self->{__anchors}->{$name})
	{
	    $name = $word_name . "$anch_num";
	    $anch_num++;
	}
    }
    return $name;
} # make_anchor_name

#--------------------------------#
# Name: make_anchors
# Makes the anchors for one file
# Args:
#   $self
#   $file
sub make_anchors ($$) {
    my $self = shift;
    my $infile = shift;

    my $html_str = "";
    my @newhtml = ();

    print STDERR "Making anchors for $infile ...\n" unless $self->quiet();
    open (FILE, $infile) ||
	die "Error: unable to open ", $infile, ": $!\n";

    my $old_slash = $/;
    undef $/;		# Slurps entire file
    $html_str = <FILE>;
    close (FILE);
    $/ = $old_slash;

    # parse the file
    my $hp = new HTML::SimpleParse();
    $hp->text($html_str);
    $hp->parse();

    my $tag;
    my $endtag;
    my $level = 0;
    my $tmp;
    my $content;
    my $adone = 0;
    my $name = '';
    my $is_title;
    # go through the HTML
    my $tok;
    my $next_tok;
    my $i;
    my $notoc = $self->notoc_match();
    my @tree = $hp->tree();
    while (@tree) {
	$tok = shift @tree;
	$next_tok = $tree[0];
	if ($tok->{type} ne 'starttag')
	{
	    push @newhtml, $hp->execute($tok);
	    next;
	}
	$level = 0;
	$is_title = 0;
	# check if tag included in TOC
	foreach my $key (keys %{$self->toc_entry()}) {
	    if ($tok->{content} =~ /$key/i
		&& (!$notoc
		    || $tok->{content} !~ /$notoc/)) {
		$tag = $key;
		# level of significant element
		$level = abs($self->toc_entry()->{$key});
		# End tag of significant element
		$endtag = $self->toc_end()->{$key};
		last;
	    }
	}
	if (!$level) {
	    push @newhtml, $hp->execute($tok);
	    next;
	}

	#
	# Add A element to document
	#
	$content = '';
	$adone = 0;
	$name = '';
	if ($tag =~ /title/i) {		# TITLE tag is a special case
	    $is_title = 1;  $adone = 1;
	}
	push @newhtml, $hp->execute($tok);
	while (@tree) {
	    $tok = shift @tree;
	    $next_tok = $tree[0];
	    # Text
	    if ($tok->{type} eq 'text') {
		$content .= $tok->{content};

		if (!$name) {
		    $name = $self->make_anchor_name($tok->{content});
		}

		if (!$adone && $tok->{content} !~ /^\s*$/) {
		    $self->{__anchors}->{$name} = 1;
		    push(@newhtml, qq|<a name="$name">$tok->{content}</a>|);
		    $adone = 1;
		} else {
		    push @newhtml, $hp->execute($tok);
		}
	    # Anchor
	    } elsif (!$adone && $tok->{type} eq 'starttag'
		&& $tok->{content} =~ /^A/i)
	    {
		# is there an existing NAME anchor?
		if ($tok->{content} =~ /NAME\s*=\s*(['"])/i) {
		    my $q = $1;
		    ($name) = $tok->{content} =~ m/NAME\s*=\s*$q([^$q]*)$q/i;
		    $self->{__anchors}->{$name} = 1;
		    push @newhtml, $hp->execute($tok);
		} else {
		    if (!$name) { # if no anchor name yet, try to get it
			if ($next_tok->{type} eq 'text') {
			    $name = $self->make_anchor_name(
				$next_tok->{content});
			}
			if (!$name) {
			    # make a generic anchor name
			    $name = $self->make_anchor_name("TOC");
			}
		    }
		    # add the current name anchor
		    $tmp = $hp->execute($tok);
		    $tmp =~ s/^(<A)(.*)$/$1 name="$name" $2/i;
		    push @newhtml, $tmp;
		    $self->{__anchors}->{$name} = 1;
		}
		$adone = 1;
	    } elsif ($tok->{type} eq 'starttag'
		    || $tok->{type} eq 'endtag')
	    {	# Tag
		push @newhtml, $hp->execute($tok);
		last if $tok->{content} =~ m|$endtag|i;
		$content .= $hp->execute($tok)
		    unless $self->textonly()
			|| $tok->{content} =~ m%/?(hr|p|a|img)%i;
	    }
	    else {
		push @newhtml, $hp->execute($tok);
	    }

	}
	$self->{__prevlevel} = $level;
    }

    return @newhtml;
} # make_anchors

#---------------------------------------------------------------#
# generate_toc related subroutines

#--------------------------------#
# Name: make_toc
# Makes (a portion of) the ToC from one file
# Args:
#   $self
#   $file
# Returns:
#   $toc_str
sub make_toc ($$) {
    my $self = shift;
    my $infile = shift;

    my $html_str = "";
    my $toc_str = "";
    my @toc = ();

    print STDERR "Making ToC from $infile ...\n" unless $self->quiet();
    open (FILE, $infile) ||
	die "Error: unable to open ", $infile, ": $!\n";

    my $old_slash = $/;
    undef $/;		# Slurps entire file
    $html_str = <FILE>;
    close (FILE);
    $/ = $old_slash;

    # parse the file
    my $hp = new HTML::SimpleParse();
    $hp->text($html_str);
    $hp->parse();

    my $noli;
    my $prevnoli;
    my $before = "";
    my $after = "";
    my $tag;
    my $endtag;
    my $level = 0;
    my $levelopen;
    my $tmp;
    my $content;
    my $adone = 0;
    my $name = "NOTOC"; # if no anchor is found...
    my $is_title;
    my $found_title = 0;
    my $notoc = $self->notoc_match();
    # go through the HTML
    my $tok;
    my @tree = $hp->tree();
    while (@tree) {
	$tok = shift @tree;
	$level = 0;
	$is_title = 0;
	$tag = '';
	if ($tok->{type} eq 'starttag')
	{
	    # check if tag included in TOC
	    foreach my $key (keys %{$self->toc_entry()}) {
		if ($tok->{content} =~ /^$key/i
		    && (!$notoc
			|| $tok->{content} !~ /$notoc/)) {
		    $tag = $key;
		    if ($self->debug()) {
			print STDERR "============\n";
			print STDERR "key = $key ";
			print STDERR "tok->content = '", $tok->{content}, "' ";
			print STDERR "tag = $tag";
			print STDERR "\n============\n";
		    }
		    # level of significant element
		    $level = abs($self->toc_entry()->{$key});
		    # no <li> used in ToC listing
		    $noli = $self->toc_entry()->{$key} < 0;
		    # End tag of significant element
		    $endtag = $self->toc_end()->{$key};
		    if (defined $self->toc_before()->{$key}) {
			$before = $self->toc_before()->{$key};
		    } else {
			$before = "";
		    }
		    if (defined $self->toc_after()->{$key}) {
			$after = $self->toc_after()->{$key};
		    } else {
			$after = "";
		    }
		    last;
		}
	    }
	}
	if (!$level) {
	    next;
	}
	if ($self->debug()) {
	    print STDERR "Chosen tag:$tag\n";
	}

	# get A element from document
	# This assumes that there is one there
	$content = '';
	$adone = 0;
	if ($tag =~ /title/i) {		# TITLE tag is a special case
	    if ($found_title) {
		# don't need to find a title again, we found it
		next;
	    } else {
		$is_title = 1;  $adone = 1;
		$found_title = 1;
	    }
	}
	while (@tree) {
	    $tok = shift @tree;
	    # Text
	    if ($tok->{type} eq 'text') {
		$content .= $tok->{content};
		if ($self->debug()) {
		    print STDERR "tok-content = ", $tok->{content}, "\n";
		    print STDERR "content = $content\n";
		}
	    # Anchor
	    } elsif (!$adone && $tok->{type} eq 'starttag'
		&& $tok->{content} =~ /^A/i)
	    {
		if ($tok->{content} =~ /NAME\s*=\s*(['"])/i) {
		    my $q = $1;
		    ($name) = $tok->{content} =~ m/NAME\s*=\s*$q([^$q]*)$q/i;
		    $adone = 1;
		}
	    } elsif ($tok->{type} eq 'starttag'
		    || $tok->{type} eq 'endtag')
	    {	# Tag
		if ($self->debug()) {
		    print STDERR "file = ", $self->{__file},
			" tag = $tag, endtag = '$endtag",
			"' tok-type = ", $tok->{type},
			" tok-content = '", $tok->{content}, "'\n";
		}
		last if $tok->{content} =~ m#$endtag#i;
		$content .= $hp->execute($tok)
		    unless $self->textonly()
			|| $tok->{content} =~ m#/?(hr|p|a|img)#i;
	    }

	}
	if ($self->debug()) {
	    print STDERR "Chosen content:'$content'\n";
	}

	if ($content =~ /^\s*$/) {	# Check for empty content
	    warn "Warning: A $tag in $infile has no content;  $tag skipped\n";
	    next;
	} else {
	    $content =~ s/^\s+//;	# Strip beginning whitespace
	    $content =~ s/\s+$//;	# Strip end whitespace
	    $content = $before . $content . $after;
	}
	## Update TOC
	##
	my $i;
	if ($level < $self->{__prevlevel}) {
	    # close open levels
	    for ($i=$level; $i < $self->{__prevlevel}; $i++) {
		if ($self->ol() && $i == 1) {
		    $toc_str .= "\n</ol>";
		}
		else {
		    $toc_str .= "\n</ul>";
		}
		if ($i > 0) {
		    $toc_str .= "</li>";
		}
	    }
	} elsif ($level > $self->{__prevlevel}) {
	    # open closed levels
	    for ($i=$level; $i > $self->{__prevlevel}; $i--) {
		if ($self->ol() && $i == $level
		    && $self->{__prevlevel} == 0) {
		    $toc_str .= "\n<ol>";
		}
		else {
		    if (!($self->{__prevlevel} == 0
			&& $i == $level)) {
			$toc_str .= "<li style=\"list-style: none;\">";
		    }
		    $toc_str .= "\n<ul>";
		}
	    }
	    $levelopen = 1;	# Flag for use with $noli
	} else {
	    $levelopen = 0;	# Flag for use with $noli
	}

	# Set anchor string
	$tmp  = '';
	$tmp .= $self->entrysep()  if $noli && !$levelopen;
	$tmp .= "\n<li>"  unless $noli && !$levelopen;
	if ($self->inline() and $self->infile()->[0] eq $self->{__file})
	{
	    $tmp .= join('',
			 qq|<a href="|,
			 !$is_title ? qq|#$name| : '',
			 qq|">$content</a>|);
	}
	else
	{
	    $tmp .= join('',
			 qq|<a href="|,
			 qq|$self->{__file}|,
			 !$is_title ? qq|#$name| : '',
			 qq|">$content</a>|);
	}
	$tmp .= "</li>\n"  unless $noli && !$levelopen;
	$toc_str .= $tmp;

	$name = 'NOTOC';
	$self->{__prevlevel} = $level;
	$prevnoli = $noli;
    }

    return $toc_str;
} # make_toc

#--------------------------------#
# Name: put_toc_inline
# Puts the given toc_str into the given file
# Args:
#   $self
#   $file
sub put_toc_inline ($$$) {
    my $self = shift;
    my $toc_str = shift;
    my $infile = shift;

    my $html_str = "";
    my @newhtml = ();

    print STDERR "Putting ToC in place from $infile ...\n" unless $self->quiet();
    open (FILE, $infile) ||
	die "Error: unable to open ", $infile, ": $!\n";

    my $old_slash = $/;
    undef $/;		# Slurps entire file
    $html_str = <FILE>;
    close (FILE);
    $/ = $old_slash;

    # parse the file
    my $hp = new HTML::SimpleParse();
    $hp->text($html_str);
    $hp->parse();

    my $toc_tag = $self->toc_tag();

    my $toc_done = 0;
    # go through the HTML
    my $tok;
    my $i;
    my @tree = $hp->tree();
    while (@tree) {
	$tok = shift @tree;
	# look for the ToC tag in tags or comments
	if ($tok->{type} eq 'starttag'
	    || $tok->{type} eq 'endtag'
	    || $tok->{type} eq 'comment')
	{
	    if (!$toc_done
		&& $tok->{content} =~ m|$toc_tag|i) {
		# some tags need to be preserved, with the ToC put after,
		# while others need to be replaced
		if (!$self->toc_tag_replace()) {
		    push @newhtml, $hp->execute($tok);
		}
		# put the ToC in
		push @newhtml, $toc_str;
		$toc_done = 1;
	    }
	    else {
		push @newhtml, $hp->execute($tok);
	    }
	}
	else
	{
	    push @newhtml, $hp->execute($tok);
	    next;
	}
    }


    return @newhtml;
}

1;
__DATA__

toc_entry H1=1
toc_entry H2=2

toc_end H1=/H1
toc_end H2=/H2
