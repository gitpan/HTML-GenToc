#! /usr/bin/perl

=head1 NAME

HTML::GenToc - Generate/insert anchors and a Table of Contents (ToC) for HTML documents.

=head1 SYNOPSIS

  use HTML::GenToc;

  # create a new object
  my $toc = new HTML::GenToc();

  my $toc = new HTML::GenToc(title=>"Table of Contents",
			  toc=>$my_toc_file,
			  toc_entry=>{
			    H1=>1,
			    H2=>2
			  },
			  toc_end=>{
			    H1=>'/H1',
			    H2=>'/H2'
			  }
    );

  # add further arguments
  $toc->args(toc_tag=>"BODY",
	     toc_tag_replace=>0,
    );

  # generate anchors for a file
  $toc->generate_anchors(infile=>$html_file,
			 overwrite=>0,
    );

  # generate a ToC from a file
  $toc->generate_toc(infile=>$html_file,
		     footer=>$footer_file,
		     header=>$header_file
    );


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

Information on the significant elements and what level they should occur
are passed in to the methods used by this object, or one can use the
defaults.

There are two phases to the ToC generation.  The first phase is to
put suitable anchors into the HTML documents, and the second phase
is to generate the ToC from HTML documents which have anchors
in them for the ToC to link to.

For more information on controlling the contents of the created ToC, see
L</Formatting the ToC>.

HTML::GenToc also supports the ability to incorporate the ToC into the HTML
document itself via the -inline option.  See L</Inlining the ToC> for more
information.

In order for HTML::GenToc to support linking to significant elements,
HTML::GenToc inserts anchors into the significant elements.  One can
use HTML::GenToc as a filter, outputing the result to another file,
or one can overwrite the original file, with the original backed
up with a suffix (default: "org") appended to the filename.

=head1 METHODS

All arguments can be set when the object is created, and further options
can be set on any method (though some may not make sense).  Arguments
to methods can take either a hash of arguments, or a reference to an
array (though the array usage is deprecated and is here for backwards
compatibility only).

The arguments get treated differently depending on whether they are
given in a hash or a reference to an array.  When the arguments are
in a hash, the argument-keys are expected to have values matching
those required for that argument -- whether that be a boolean, a string,
a reference to an array or a reference to a hash.  These will replace
any value for that argument that might have been there before.

When the arguments are in a reference to an array, it is treated as if
it were a command-line: option names are expected to start with '--' or
'-', boolean options are set to true as soon as the option is given (no
value is expected to follow),  boolean options with the word "no"
prepended set the option to false, string options are expected to have a
string value following, and those options which are internally arrays or
hashes are treated as cumulative; that is, the value following the
--option is added to the current set for that option,  to add more, one
just repeats the --option with the next value, and in order to reset
that option to empty, the special value of "CLEAR" must be added to the
list.

(You can see why I want to phase this out -- it makes the code more
complicated and ambiguous and prone to error)

=cut

package HTML::GenToc;

require 5.005_03;
use strict;

use vars qw($VERSION);
BEGIN {
    use Data::Dumper;
    use HTML::SimpleParse;
}

$VERSION = '2.22';

#################################################################

#---------------------------------------------------------------#
# Object interface
#---------------------------------------------------------------#

=head2 Method -- new

    $toc = new HTML::GenToc();

    $toc = new HTML::GenToc(\@args); # deprecated!

    $toc = new HTML::GenToc(toc_entry=>\%my_toc_entry,
	toc_end=>\%my_toc_end,
	bak=>'bak',
    	...
        );

Creates a new HTML::GenToc object.

The arguments can either be a hash, or (deprecated) a reference to
an array of arguments.
These arguments will be used in invocations of other methods.

See the other methods for possible arguments.

=cut
sub new {
    my $invocant = shift;

    my $class = ref($invocant) || $invocant; # Object or class name
    my $self = {};

    init_our_data($self);
    # bless self
    bless($self, $class);

    $self->args(@_);

    return $self;
} # new

=head2 Method -- args

    $toc->args(\@args); # deprecated!

    $toc->args(infile=>['myfile.html', 'thatfile.html']);

Updates the current arguments/options of the HTML::GenToc object.
Takes either a hash, or (deprecated) a reference to an array of
arguments, which will be used in invocations of other methods.

The hash arguments must be just the name of the argument.
The array arguments must have a '-' or '--' in front of them.

B<Common Options>

The following arguments apply to both generating anchors and generating
table-of-contents phases, so they are shown here, rather than repeating
them for each method.

=over 4

=item bak

bak => I<string>

If the input file/files is/are being overwritten (B<overwrite> is on), copy
the original file to "I<filename>.I<string>".  If the value is empty, there
is no backup file written.
(default:org)

=item debug

debug => 1

Enable verbose debugging output.  Used for debugging this module;
in other words, don't bother.
(default:off)

=item file_strings

file_strings => \@content_of_files

If this is set, then the files in the B<infile> array are not read, but
the content of this array is used instead, with the names in the
B<infile> array just used as names.  The B<infile> array and the
B<file_strings> array must be the same size. (see also
B<set_file_strings>)

(this option is not supported in the old array format)

=item infile

infile => \@files

infile => ['index.html']

Input file(s).  This expects a reference to an array of files.

'--infile', $file  (array version, deprecated)

If the arguments are a reference to an array (the old way) then a single
filename is expected; if you want to process more than one file in this
form, just add another C<--infile, $filename> to the array of arguments.
In the arrayref form, use the special name "CLEAR" to clear the current
array of input files, if you want to process a different file.

(see B<in_string> and B<file_strings> also)

(default:undefined)

=item in_string

in_string => $string

Use the given string instead of reading in the content of the first
infile.  Instead, the first infile is taken just to be the filename
to use in referring to this content.  This is useful if one is using
this module as part of other processing; the filename given could be
the name of the final output file which hasn't been written yet.
Note that it is still necessary to give at least one B<infile> name
when using this option.

=item notoc_match

notoc_match => I<string>

If there are certain individual tags you don't wish to include in the
table of contents, even though they match the "significant elements",
then if this pattern matches contents inside the tag (not the body),
then that tag will not be included, either in generating anchors nor in
generating the ToC.  (default: C<class="notoc">)

=item overwrite

overwrite => 1

Overwrite the input file with the output.  If this is in effect,
B<outfile> and B<toc_file> are ignored. Used in
L<generate_anchors|Method -- generate_anchors> for creating the anchors
"in place" and in L<generate_toc|Method -- generate_toc> if the
B<inline> option is in effect.  (default:off)

=item quiet

quiet => 1

Suppress informative messages. (default: off)

=item toc_end

toc_end => \%toc_end_data

%toc_end_data = { I<tag1> => I<endtag1>,
    I<tag2> => I<endtag2>
    };

toc_end => { H1 => '/H1', H2 => '/H2' }

For defining significant elements.  The I<tag> is the HTML tag which
marks the start of the element.  The I<endtag> the HTML tag which marks
the end of the element.  When matching in the input file, case is
ignored (but make sure that all your I<tag> options referring to the
same tag are exactly the same!).

'--toc_end', 'I<tag>=I<endtag>'

For the (deprecated) array-ref form of arguments, this is a cumulative
hash argument; if you wish to clear the default, give
C<'--toc_end', 'CLEAR'> to do so.

(default: H1=/H1  H2=/H2)

=item toc_entry

toc_entry => \%toc_entry_data

%toc_entry_data = { I<tag1> => I<level1>,
    I<tag2> => I<level2>
    };

toc_entry => { H1 => 1, H2 => 2 }

For defining significant elements.  The I<tag> is the HTML tag which marks
the start of the element.  The I<level> is what level the tag is considered
to be.  The value of I<level> must be numeric, and non-zero. If the value
is negative, consective entries represented by the significant_element will
be separated by the value set by B<entrysep> option.

'--toc_entry', 'I<tag>=I<level>'

For the (deprecated) array-ref form of arguments, this is a cumulative
hash argument; if you wish to clear the default, give
C<'--toc_entry', 'CLEAR'> to do so.

(default: H1=1  H2=2)

=item tocmap

tocmap => I<file>

ToC map file defining significant elements.  (This is deprecated, and is
only here for backwards compatibility with htmltoc.)

This overrides any previously set B<toc_entry>, B<toc_end>,
B<toc_before> and B<toc_after> options.  It is inadvisable to use both
B<tocmap> and B<toc_entry>/B<toc_end>/B<toc_before>/B<toc_after> options
in the same call, as it is undefined as to which one will override the
other.

See L</ToC Map File> for further information.

=item to_string

to_string => 1

Return the modified HTML output as a string.  This does I<not> override
other methods of output, except in the case where the user hasn't
specified any other method of output; then the default method (STDOUT)
is overridden to just output to the string.

=back 4

=cut
sub args {
    my $self = shift;
    my %args = ();
    my @arg_array = ();
    if (@_ && @_ == 1
	&& ref $_[0]
	&& ref $_[0] eq 'ARRAY')
    {
	# this is a reference to an array -- use the old style args
	my $aref = shift;
	@arg_array = @{$aref};
    }
    elsif (@_)
    {
	%args = @_;
    }

    if (%args) {
	if ($self->{options}->{debug}) {
	    print STDERR "========args(hash)========\n";
	    print STDERR Dumper(%args);
	}
	foreach my $arg (keys %args) {
	    if (defined $args{$arg}) {
		if ($self->{options}->{debug}) {
		    print STDERR "--", $arg;
		}
		if ($arg eq 'tocmap') {
		    warn "The --tocmap option is deprecated, please do not use it.";
		    $self->read_tocmap($args{$arg});
		} else {
		    $self->{options}->{$arg} = $args{$arg};
		    if ($self->{options}->{debug}) {
			print STDERR " ", $args{$arg}, "\n";
		    }
		}
	    }
	}
    } elsif (@arg_array) {
	warn "Using an array for arguments is deprecated, please change your code.";
	if ($self->{options}->{debug}) {
	    print STDERR "========args(array)========\n";
	    print STDERR Dumper(@arg_array);
	}
	while (@arg_array) {
	    my $arg = shift @arg_array;
	    # check for arguments which are bools,
	    # and thus have no companion value
	    if ($arg =~ /^-/) {
		$arg =~ s/^-//; # get rid of first dash
		$arg =~ s/^-//; # get rid of possible second dash
		if ($self->{options}->{debug}) {
		    print STDERR "--", $arg;
		}
		if ($arg eq 'debug' || $arg eq 'inline'
		    || $arg eq 'ol'
		    || $arg eq 'overwrite'
		    || $arg eq 'quiet'
		    || $arg eq 'textonly'
		    || $arg eq 'toc_tag_replace'
		    || $arg eq 'toc_only'
		    || $arg eq 'to_string'
		    || $arg eq 'useorg'
		) {
		    $self->{options}->{$arg} = 1;
		    if ($self->{options}->{debug}) {
			print STDERR "=true\n";
		    }
		} elsif ($arg eq 'nodebug' || $arg eq 'noinline'
		    || $arg eq 'nool'
		    || $arg eq 'nooverwrite'
		    || $arg eq 'noquiet'
		    || $arg eq 'notextonly'
		    || $arg eq 'notoc_tag_replace'
		    || $arg eq 'notoc_only'
		    || $arg eq 'noto_string'
		    || $arg eq 'nouseorg'
		) {
		    $arg =~ s/^no//;
		    $self->{options}->{$arg} = 0;
		    if ($self->{options}->{debug}) {
			print STDERR " $arg=false\n";
		    }
		} elsif ($arg eq 'verbose') {
		    $self->{options}->{quiet} = 0;
		    if ($self->{options}->{debug}) {
			print STDERR " quiet=false\n";
		    }
		} elsif ($arg eq 'noverbose') {
		    $self->{options}->{quiet} = 1;
		    if ($self->{options}->{debug}) {
			print STDERR " quiet=true\n";
		    }
		} else {
		    my $val = shift @arg_array;
		    if ($self->{options}->{debug}) {
			print STDERR "=", $val, "\n";
		    }
		    # check the types
		    if (defined $arg && defined $val) {
			if ($arg eq 'infile') {	# arrays
			    if ($val eq 'CLEAR') {
				$self->{options}->{$arg} = [];
			    } else {
				push @{$self->{options}->{$arg}}, $val;
			    }
			} elsif ($arg eq 'file') {	# alternate for 'infile'
			    if ($val eq 'CLEAR') {
				$self->{options}->{infile} = [];
			    } else {
				push @{$self->{options}->{infile}}, $val;
			    }
			} elsif ($arg eq 'toc_entry'
			    || $arg eq 'toc_end'
			    || $arg eq 'toc_before'
			    || $arg eq 'toc_after') {	# hashes
			    if ($val eq 'CLEAR') {
				$self->{options}->{$arg} = {};
			    } else {
				my ($k1, $v1) = split(/=/, $val);
				$self->{options}->{$arg}->{$k1} = $v1;
			    }
			} elsif ($arg eq 'tocmap') {
			    warn "The --tocmap option is deprecated, please do not use it.";
			    self->read_tocmap($val);
			} else {
			    $self->{options}->{$arg} = $val;
			}
		    }
		}
	    }
	}
    }
    if ($self->{options}->{debug})
    {
    	print STDERR Dumper($self);
    }

    return 1;
} # args

=head2 Method -- setting

    my $of = $toc->setting('outfile');

Get the value of a given option.

=cut
sub setting ($$) {
    my $self = shift;
    my $option = shift;

    if (exists $self->{options}->{$option})
    {
	return $self->{options}->{$option};
    }
    else
    {
	return undef;
    }
} # option

=head2 Method -- generate_anchors

    $toc->generate_anchors(outfile=>"index2.html");

    my $result_str = $toc->generate_anchors(to_string=>1);

Generates anchors for the significant elements in the HTML documents.
Takes either a hash, or (deprecated) a reference to an array of
arguments.  These arguments will be used to influence this method's
behavour (and if arguments have already been set earlier, they also will
be taken into account).

See L</Method -- args> for the common options which can be passed into this
method.

The following arguments apply only to generating anchors.

=over 4

=item outfile

outfile => I<file>

File to write the output to.  This is where the modified be-anchored HTML
output goes to.  Note that it doesn't make sense to use this option if you
are processing more than one file.  If you give '-' as the filename, then
output will go to STDOUT.
(default: STDOUT)

=item set_file_strings

set_file_strings => 1

If B<set_file_strings> is set (even if B<file_strings> is not set) then
the transformed output of each file is placed in
$toc->setting('file_strings'), replacing any previous content there.
Note that if this is set, it has the effect of quietly setting
B<file_strings> for a subsequent call to generate_anchors or
generate_toc.

(this option is not supported in the old array format)

=item useorg

useorg => 1

Use pre-existing backup files as the input source; that is, files of the
form I<infile>.I<bak>  (see B<infile> and B<bak>).

=back 4

=cut
sub generate_anchors ($;%) {
    my $self = shift;
    $self->args(@_);

    # Either read in all the files, or use the passed-in strings
    my @file_content = $self->set_file_content();

    # go through the content, updating it
    %{$self->{__anchors}} = ();
    my $i = 0;
    foreach my $fn (@{$self->{options}->{infile}}) {
	my $html_str = $file_content[$i];
	$file_content[$i] = $self->make_anchors(filename=>$fn,
	    input=>$html_str);
	$i++;
    }

    # write the output, if need be
    my $outhandle = *STDOUT;
    if ($self->{options}->{overwrite}) {
	$i = 0;
	foreach my $fn (@{$self->{options}->{infile}}) {
	    my $bakfile = $fn . "." . $self->{options}->{bak};
	    if ($self->{options}->{bak}
		&& !($self->{options}->{useorg} && -e $bakfile))
	    {
		# copy the file to a backup
		print STDERR "Backing up ", $fn, " to ",
		    $bakfile, "\n"
		    unless $self->{options}->{quiet};
		cp($fn, $bakfile);
	    }
	    open(FILEOUT, "> $fn")
		|| die "Error: unable to open ", $fn, ": $!\n";
	    $outhandle = *FILEOUT;
	    print STDERR "Overwriting Anchors to ", $fn, "\n"
		unless $self->{options}->{quiet};
	    print $outhandle $file_content[$i];
	    close(FILEOUT);
	    $i++;
	}
    }
    elsif ($self->{options}->{outfile}
	    && $self->{options}->{outfile} ne "-") {
	open(FILEOUT, "> " . $self->{options}->{outfile})
	    || die "Error: unable to open ", $self->{options}->{outfile}, ": $!\n";
	$outhandle = *FILEOUT;
	print STDERR "Writing Anchors to ", $self->{options}->{outfile}, "\n"
	    unless $self->{options}->{quiet};
	print $outhandle @file_content;
	close($outhandle);
    }
    elsif ($self->{options}->{to_string} && !$self->{options}->{outfile})
    {
	# don't print to anything
    }
    elsif ($self->{options}->{outfile})
    {
	print $outhandle @file_content;
    }

    # always set file strings if the option is on
    if ($self->{options}->{set_file_strings})
    {
	$self->{options}->{file_strings} = \@file_content;
    }
    print STDERR "$i files processed.\n"
	unless $self->{options}->{quiet};

    if ($self->{options}->{to_string}) {
	return join('', @file_content);
    }
    return 1;
} # generate_anchors

=head2 Method -- generate_toc

    $toc->generate_toc(title=>"Contents",
	toc_file=>'toc.html');

    my $result_str = $toc->generate_toc(title=>"The Contents",
	to_string=>1);

Generates a Table of Contents (ToC) for the significant elements in the
HTML documents.  Takes either a hash, or (deprecated) a reference to an
array of arguments, which will be used in invocations of other methods.
These arguments will be used to influence this method's behavour (and if
arguments have already been set earlier, they also will be taken into
account).

See L</Method -- args> for the common options which can be passed into this
method.

The following arguments apply only to generating a table-of-contents.

=over 4

=item entrysep

entrysep => I<string>

Separator string for non-<li> item entries
(default: ", ")

=item footer

footer => I<file>

File containing footer text for ToC.

=item header

header => I<file>

File containing header text for ToC.

=item inline

inline => 1

Put ToC in document at a given point.
See L</Inlining the ToC> for more information.

=item ol

ol => 1

Use an ordered list for level 1 ToC entries.

=item ol_num_levels

ol_num_levels => 2

The number of levels deep the OL listing will go if B<ol> is true.
If set to zero, will use an ordered list for all levels.
(default:1)

(this option is not supported in the old array format)

=item textonly

textonly => 1

Use only text content in significant elements.

=item title

title => I<string>

Title for ToC page (if not using B<header> or B<inline> or B<toc_only>)
(default: "Table of Contents")

=item toc_after

toc_after => \%toc_after_data

%toc_after_data = { I<tag1> => I<suffix1>,
    I<tag2> => I<suffix2>
    };

toc_after => { H2=>'</em>' }

For defining layout of significant elements in the ToC.

If the arguments are in hash form, this expects a reference to a hash of
tag=>suffix pairs.

The I<tag> is the HTML tag which marks the start of the element.  The
I<suffix> is what is required to be appended to the Table of Contents
entry generated for that tag.

'--toc_after', 'I<tag>=I<suffix>' (array version, deprecated)

If the arguments are in arrayref form, this is a cumulative argument;
each instance of --toc_after, I<value> in the array adds another pair to
the internal hash; if you wish to clear it, give
C<'--toc_after', 'CLEAR'> to do so.

(default: undefined)

=item toc_before

toc_before => \%toc_before_data

%toc_before_data = { I<tag1> => I<prefix1>,
    I<tag2> => I<prefix2>
    };

toc_before=>{ H2=>'<em>' }

For defining the layout of significant elements in the ToC.  The I<tag>
is the HTML tag which marks the start of the element.  The I<prefix> is
what is required to be prepended to the Table of Contents entry
generated for that tag.

'--toc_before', 'I<tag>=I<prefix>' (array version, deprecated)

For the array-ref form of arguments, this is a cumulative hash argument;
if you wish to clear it, give
C<'--toc_before', 'CLEAR'> to do so.

(default: undefined)

=item toc_file

toc_file => I<file>

File to write the table-of-contents output to.
If you give '-' as the filename, then output will go to STDOUT.
(default: STDOUT)

=item toclabel

toclabel => I<string>

HTML text that labels the ToC.  Always used.
(default: "<H1>Table of Contents</H1>")

=item toc_tag

toc_tag => I<string>

If a ToC is to be included inline, this is the pattern which is used to
match the tag where the ToC should be put.  This can be a start-tag, an
end-tag or a comment, but the E<lt> should be left out; that is, if you
want the ToC to be placed after the BODY tag, then give "BODY".  If you
want a special comment tag to make where the ToC should go, then include
the comment marks, for example: "!--toc--" (default:BODY)

=item toc_tag_replace

toc_tag_replace => 1

In conjunction with B<toc_tag>, this is a flag to say whether the given tag
should be replaced, or if the ToC should be put after the tag.
This can be useful if your toc_tag is a comment and you don't need it
after you have the ToC in place.
(default:false)

=item toc_only

toc_only => 1

Output only the Table of Contents, that is, the Table of Contents plus
the toclabel.  If there is a B<header> or a B<footer>, these will also be
output.

If B<toc_only> is false then if there is no B<header>, and B<inline> is
not true, then a suitable HTML page header will be output, and if there
is no B<footer> and B<inline> is not true, then a HTML page footer will
be output.

(default:false)

=back 4

=cut
sub generate_toc ($;$) {
    my $self = shift;
    $self->args(@_);

    # Either read in all the files, or use the passed-in strings
    my @file_content = $self->set_file_content();

    my @toc = ();
    # put the header at the start of the ToC if there is one
    if ($self->{options}->{header}) {
	open(HEADER, $self->{options}->{header})
	    || die "Error: unable to open ", $self->{options}->{header}, ": $!\n";
	push @toc, <HEADER>;
	close (HEADER);
    }
    # if we are outputing a standalone page,
    # then make sure it can stand
    elsif (!$self->{options}->{toc_only}
	&& !$self->{options}->{inline}) {

	push @toc, qq|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML//EN">\n|,
			 "<html>\n",
			 "<head>\n";
	push @toc, "<title>", $self->{options}->{title}, "</title>\n"  if $self->{options}->{title};
	push @toc, "</head>\n",
	"<body>\n";
    }

    # start the ToC with the ToC label
    if ($self->{options}->{toclabel}) {
	push @toc, $self->{options}->{toclabel};
    }
    $self->{__prevlevel} = 0;
    $self->{__tags} = [];
    $self->{__tag_level} = [];
    my $i = 0;
    my $bakfile;
    foreach my $fn (@{$self->{options}->{infile}}) {
	$self->{__cur_file} = $fn;
	my $infn = $fn;
	$bakfile = $fn . "." . $self->{options}->{bak};
	my $html_str = $file_content[$i];
	push @toc, $self->make_toc(input=>$html_str,
	    filename=>$infn);
	$i++;
    }
    print STDERR "$i files processed.\n"
	unless $self->{options}->{quiet};

    ## Close up open elements in ToC
    while (@{$self->{__tags}})
    {
	push @toc, $self->close_tag('');
    }

    # add the footer, if there is one
    if ($self->{options}->{footer}) {
	open(FOOTER, $self->{options}->{footer})
	    || die "Error: unable to open ", $self->{options}->{footer}, ": $!\n";
	push @toc, <FOOTER>;
	close (FOOTER);
    }
    # if we are outputing a standalone page,
    # then make sure it can stand
    elsif (!$self->{options}->{toc_only}
	&& !$self->{options}->{inline}) {

	push @toc, "</body>\n", "</html>\n";
    }

    my $toc_str = join '', @toc;

    #
    #  Sent the full ToC to its final destination
    #
    my $file_needs_closing = 0;
    my $tochandle = *STDOUT;
    if ($self->{options}->{toc_file} && $self->{options}->{toc_file} ne "-") {
	open(TOCOUT, "> " . $self->{options}->{toc_file})
	    || die "Error: unable to open ", $self->{options}->{toc_file}, ": $!\n";
	$tochandle = *TOCOUT;
	$file_needs_closing = 1;
    }
    if ($self->{options}->{inline}) {
	# either make a new output which is a modified copy
	# of the first file, or overwrite the first file.
	my $first_file = $self->{options}->{infile}->[0];
	$bakfile = $first_file . "." . $self->{options}->{bak};
	my @new_html;
	if ($self->{options}->{useorg} && $self->{options}->{bak} && -e $bakfile) {
	    @new_html = $self->put_toc_inline(toc_str=>$toc_str,
		filename=>$bakfile,
		in_string=>$self->{options}->{in_string});
	} else {
	    @new_html = $self->put_toc_inline(toc_str=>$toc_str,
		filename=>$first_file,
		in_string=>$self->{options}->{in_string});
	}
	$toc_str = join '', @new_html;
	if ($self->{options}->{overwrite}) {
	    if ($self->{options}->{bak}
		&& !($self->{options}->{useorg} && -e $bakfile))
	    {
		# copy the file to a backup
		print STDERR "Backing up ", $first_file, " to ",
		    $bakfile, "\n"
		    unless $self->{options}->{quiet};
		cp($first_file, $bakfile);
	    }
	    open(TOCOUT, "> $first_file")
		|| die "Error: unable to open ", $first_file, ": $!\n";
	    $tochandle = *TOCOUT;
	    $file_needs_closing = 1;
	    print STDERR "Overwriting ToC to ", $first_file, "\n"
		unless $self->{options}->{quiet};
	    print $tochandle $toc_str;
	}
	elsif ($self->{options}->{toc_file}
	    && $self->{options}->{toc_file} ne "-") {
	    print STDERR "Writing Inline ToC to ", $self->{options}->{toc_file}, "\n"
		unless $self->{options}->{quiet};
	    print $tochandle $toc_str;
	}
	elsif ($self->{options}->{to_string} && !$self->{options}->{toc_file})
	{
	    # just send to string, don't print anything
	}
	elsif ($self->{options}->{toc_file})
	{
	    print $tochandle $toc_str;
	}
    } else {
	if ($self->{options}->{toc_file} && $self->{options}->{toc_file} ne "-") {
	    print STDERR "Writing ToC to ", $self->{options}->{toc_file}, "\n"
		unless $self->{options}->{quiet};
	    print $tochandle $toc_str;
	}
	elsif ($self->{options}->{to_string} && !$self->{options}->{toc_file})
	{
	    # just send to string, don't print anything
	}
	else
	{
	    print $tochandle $toc_str;
	}
    }
    if ($file_needs_closing) {
	close($tochandle);
    }

    if ($self->{options}->{to_string}) {
	return $toc_str;
    }
    return 1;
} # generate_toc

#---------------------------------------------------------------#

#--------------------------------#
# Name: init_our_data
# Args:
#   $self
sub init_our_data ($) {
    my $self = shift;

    $self->{options} = {};
    $self->{options}->{debug} = 0;
    #
    # All the options (alphabetical)
    #
    $self->{options}->{bak} = 'org';
    $self->{options}->{entrysep} = ', ';
    $self->{options}->{footer} = '';
    $self->{options}->{inline} = 0;
    $self->{options}->{header} = '';
    $self->{options}->{infile} = [];	# names of files to be processed
    $self->{options}->{notoc_match} = 'class="notoc"';
    $self->{options}->{ol} = 0;
    $self->{options}->{ol_num_levels} = 1;
    $self->{options}->{overwrite} = 0;
    $self->{options}->{outfile} = '-';
    $self->{options}->{quiet} = 0;
    $self->{options}->{textonly} = 0;
    $self->{options}->{title} = 'Table of Contents';
    $self->{options}->{toclabel} = '<h1>Table of Contents</h1>';
    $self->{options}->{tocmap} = '';
    $self->{options}->{toc_file} = '-';
    $self->{options}->{toc_tag} = '^BODY';
    $self->{options}->{toc_tag_replace} = 0;
    $self->{options}->{toc_only} = 0;
    # define TOC entry elements
    $self->{options}->{toc_entry} = {
    	'H1'=>1,
	'H2'=>2,
    };
    # TOC entry element terminators
    $self->{options}->{toc_end} = {
    	'H1'=>'/H1',
	'H2'=>'/H2',
    };
    # before text for TOC entries
    $self->{options}->{toc_before} = {};
    # after text for TOC entries
    $self->{options}->{toc_after} = {};

    $self->{options}->{useorg} = 0;

    if ($self->{options}->{debug})
    {
    	print STDERR Dumper($self);
    }

    # accumulation variables
    $self->{__cur_file} = "";	    # Current file being processed
    $self->{__prevlevel} = 0; # Previous ToC entry level
    my %anchors = ();
    $self->{__anchors} = \%anchors;

} # init_our_data

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

    open(TOCMAP, $tocmap)
	|| die "Error: unable to open ", $tocmap, ": $!\n";

    # clear the old values of toc_entry, toc_end, toc_before and toc_after
    %{$self->{options}->{"toc_entry"}} = ();
    %{$self->{options}->{"toc_end"}} = ();
    %{$self->{options}->{"toc_before"}} = ();
    %{$self->{options}->{"toc_after"}} = ();
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
	# store ToC tag and level
	$self->{options}->{toc_entry}->{$array[0]} = $array[1];
	if ($array[2]) {		# Store end delimiter
	    $self->{options}->{toc_end}->{$array[0]} = $array[2];
	} else {
	    $self->{options}->{toc_end}->{$array[0]} = "/" . $array[0];
	}
	if ($array[3]) {		# Store before/after text
	    @befaft = split(/,/, $array[3]);
	    $self->{options}->{toc_before}->{$array[0]} = $befaft[0];
	    $self->{options}->{toc_after}->{$array[0]} = $befaft[1];
	}
    }
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

sub set_file_content {
    my $self = shift;

    # Either read in all the files, or use the passed-in strings
    my @file_content;
    my $i = 0;
    if (exists $self->{options}->{file_strings}
	&& defined $self->{options}->{file_strings}
	&& @{$self->{options}->{file_strings}})
    {
	@file_content = @{$self->{options}->{file_strings}};
    }
    else
    {	# read in the files
	$i = 0;
	foreach my $fn (@{$self->{options}->{infile}}) {
	    my $infn = $fn;
	    my $bakfile = $fn . "." . $self->{options}->{bak};
	    if ($self->{options}->{useorg}
		&& $self->{options}->{bak}
		&& -e $bakfile) {
		# use the old backup files as source
		$infn = $bakfile;
	    }
	    # if we have an in_string, use it for the
	    # content of the first file
	    my $content = '';
	    if ($self->{options}->{in_string} && $i == 0)
	    {
		$content = $self->{options}->{in_string};
	    }
	    else
	    {
		open (FILE, $infn) ||
		    die "Error: unable to open ", $infn, ": $!\n";
		{
		    local $/;   # slurp entire file
		    $content = <FILE>;
		    close (FILE);
		}
	    }
	    push @file_content, $content;
	}
    }
    return @file_content;
} # set_file_content

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
# returns a string
sub make_anchors ($%) {
    my $self = shift;
    my %args = (
	input=>'',
	filename=>'',
	@_
    );
    my $html_str = $args{input};
    my $infile = $args{filename};

    my @newhtml = ();

    print STDERR "Making anchors for $infile ...\n" unless $self->{options}->{quiet};

    # parse the HTML
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
    my $notoc = $self->{options}->{notoc_match};
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
	foreach my $key (keys %{$self->{options}->{toc_entry}}) {
	    if ($tok->{content} =~ /$key/i
		&& (!$notoc
		    || $tok->{content} !~ /$notoc/)) {
		$tag = $key;
		# level of significant element
		$level = abs($self->{options}->{toc_entry}->{$key});
		# End tag of significant element
		$endtag = $self->{options}->{toc_end}->{$key};
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
		    unless $self->{options}->{textonly}
			|| $tok->{content} =~ m%/?(hr|p|a|img)%i;
	    }
	    else {
		push @newhtml, $hp->execute($tok);
	    }

	}
	$self->{__prevlevel} = $level;
    }

    return join('', @newhtml);
} # make_anchors

#---------------------------------------------------------------#
# generate_toc related subroutines

#--------------------------------#
# Name: make_toc
# Makes (a portion of) the ToC from one file
# Returns:
#   $toc_str
sub make_toc ($%) {
    my $self = shift;
    my %args = (
	input=>'',
	filename=>'',
	@_
    );
    my $html_str = $args{input};
    my $infile = $args{filename};

    my $toc_str = "";
    my @toc = ();

    print STDERR "Making ToC from $infile ...\n" unless $self->{options}->{quiet};

    # parse the HTML
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
    my $notoc = $self->{options}->{notoc_match};
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
	    foreach my $key (keys %{$self->{options}->{toc_entry}}) {
		if ($tok->{content} =~ /^$key/i
		    && (!$notoc
			|| $tok->{content} !~ /$notoc/)) {
		    $tag = $key;
		    if ($self->{options}->{debug}) {
			print STDERR "============\n";
			print STDERR "key = $key ";
			print STDERR "tok->content = '", $tok->{content}, "' ";
			print STDERR "tag = $tag";
			print STDERR "\n============\n";
		    }
		    # level of significant element
		    $level = abs($self->{options}->{toc_entry}->{$key});
		    # no <li> used in ToC listing
		    $noli = $self->{options}->{toc_entry}->{$key} < 0;
		    # End tag of significant element
		    $endtag = $self->{options}->{toc_end}->{$key};
		    if (defined $self->{options}->{toc_before}->{$key}) {
			$before = $self->{options}->{toc_before}->{$key};
		    } else {
			$before = "";
		    }
		    if (defined $self->{options}->{toc_after}->{$key}) {
			$after = $self->{options}->{toc_after}->{$key};
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
	if ($self->{options}->{debug}) {
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
		if ($self->{options}->{debug}) {
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
		if ($self->{options}->{debug}) {
		    print STDERR "file = ", $self->{options}->{__cur_file},
			" tag = $tag, endtag = '$endtag",
			"' tok-type = ", $tok->{type},
			" tok-content = '", $tok->{content}, "'\n";
		}
		last if $tok->{content} =~ m#$endtag#i;
		$content .= $hp->execute($tok)
		    unless $self->{options}->{textonly}
			|| $tok->{content} =~ m#/?(hr|p|a|img)#i;
	    }

	}
	if ($self->{options}->{debug}) {
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
	    my $open_level = @{$self->{__tag_level}}[$#{$self->{__tag_level}}];
	    my $open_tag = @{$self->{__tags}}[$#{$self->{__tags}}];
	    while (defined $open_tag && $open_level > $level)
	    {
		$toc_str .= "\n";
		$toc_str .= $self->get_tag($open_tag, level=>$level, tag_type=>'end');
		$open_level = @{$self->{__tag_level}}[$#{$self->{__tag_level}}];
		$open_tag = @{$self->{__tags}}[$#{$self->{__tags}}];
	    }
	} elsif ($level > $self->{__prevlevel}) {
	    # open closed levels
	    for ($i = ($self->{__prevlevel} + 1); $i <= $level; $i++) {
		my $open_tag = @{$self->{__tags}}[$#{$self->{__tags}}];
# if we've already just opened a ul/ol
# then insert an "invisible" list item to correctly
# nest the lists
		if ($i > 1
		    && defined $open_tag
		    && ($open_tag eq 'ul' || $open_tag eq 'ol')) {
		    $toc_str .= "\n";
		    $toc_str .= $self->get_tag('li', level=>$i - 1, inside_tag=>' style="list-style: none;"');
		}
		if ($self->{options}->{ol}
		    && ($i <= $self->{options}->{ol_num_levels}
			|| $self->{options}->{ol_num_levels} == 0)
		    ) {
		    # ordered list for this level
		    $toc_str .= "\n";
		    $toc_str .= $self->get_tag('ol', level=>$i);
		}
		else {
		    $toc_str .= "\n";
		    $toc_str .= $self->get_tag('ul', level=>$i);
		}
	    }
	    $levelopen = 1;	# Flag for use with $noli
	} else {
	    $levelopen = 0;	# Flag for use with $noli
	}

	# Set anchor string
	$tmp  = '';
	$tmp .= $self->{options}->{entrysep}  if $noli && !$levelopen;
#	$tmp .= "\n<li>"  unless $noli && !$levelopen;
	$tmp .= "\n" . $self->get_tag('li', level=>$level)  unless $noli && !$levelopen;
	if ($self->{options}->{inline} and $self->{options}->{infile}->[0] eq $self->{__cur_file})
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
			 qq|$self->{__cur_file}|,
			 !$is_title ? qq|#$name| : '',
			 qq|">$content</a>|);
	}
#	$tmp .= "</li>\n"  unless $noli && !$levelopen;
	$toc_str .= $tmp;

	$name = 'NOTOC';
	$self->{__prevlevel} = $level;
	$prevnoli = $noli;
    }

    return $toc_str;
} # make_toc

# Get the tags for the TOC (that is, li, ul, ol)
#
# output the tag wanted (add the <> and the / if necessary)
# - output in lower or upper case
# - do tag-related processing
# options:
#   tag_type=>'start' | tag_type=>'end' | tag_type=>'empty'
#   (default start)
#   inside_tag=>string (default empty)
#   tag_level=>num (what level of the TOC list we're on)
#
# (code derived from txt2html)
sub get_tag ($$;%) {
    my $self	    = shift;
    my $in_tag	    = shift;
    my %args = (
	level=>0,
	tag_type=>'start',
	inside_tag=>'',
	@_
    );
    my $inside_tag  = $args{inside_tag};
    my $level  = $args{level};

    my $open_tag = @{$self->{__tags}}[$#{$self->{__tags}}];
    if (!defined $open_tag)
    {
	$open_tag = '';
    }
    # close any open tags that need closing
    # Note that we only have to check for the structural tags we make,
    # not every possible HTML tag
    my $tag_prefix = '';
    if ($open_tag eq 'li' and $in_tag eq 'li'
	and $args{tag_type} ne 'end')
    {
	# close a li before the next li
	$tag_prefix = $self->close_tag('li');
    }
    elsif ($open_tag eq 'li' and $in_tag =~ /(ul|ol)/
	and $args{tag_type} eq 'end')
    {
	# close the li before the list closes
	$tag_prefix = $self->close_tag('li');
    }

    my $out_tag = $in_tag;
    if ($args{tag_type} eq 'end')
    {
	$out_tag = $self->close_tag($in_tag);
    }
    else
    {
	if ($args{tag_type} eq 'empty')
	{
	    $out_tag = "<${out_tag}${inside_tag}/>";
	}
	else
	{
	    push @{$self->{__tags}}, $in_tag;
	    push @{$self->{__tag_level}}, $level;
	    $out_tag = "<${out_tag}${inside_tag}>";
	}
    }
    $out_tag = $tag_prefix . $out_tag;
    if ($self->{options}->{debug})
    {
	print STDERR "get_tag: open_tag = '${open_tag}', in_tag = '${in_tag}', tag_type = ", $args{tag_type}, ", inside_tag = '${inside_tag}', out_tag = '$out_tag'\n";
    }

    return $out_tag;
} # get_tag

# close the open tag
#
# (code derived from txt2html)
sub close_tag ($$) {
    my $self	    = shift;
    my $in_tag	    = shift;

    my $open_tag = @{$self->{__tags}}[$#{$self->{__tags}}];
    if (!$in_tag)
    {
	$in_tag = $open_tag;
    }
    my $out_tag = $in_tag;
    $out_tag = "<\/${out_tag}>";
    if (defined $open_tag
	&& $open_tag eq $in_tag)
    {
	pop @{$self->{__tags}};
	pop @{$self->{__tag_level}};
    }
    if ($self->{options}->{debug})
    {
	print STDERR "close_tag: open_tag = '${open_tag}', in_tag = '${in_tag}', out_tag = '$out_tag'\n";
    }

    return $out_tag . "\n";
}

#--------------------------------#
# Name: put_toc_inline
# Puts the given toc_str into the given file
# Args:
#   $self
#   $file
sub put_toc_inline ($) {
    my $self = shift;
    my %args = (
	toc_str=>'',
	filename=>'',
	in_string=>'',
	@_
    );
    my $toc_str = $args{toc_str};
    my $infile = $args{filename};

    my $html_str = "";
    my @newhtml = ();

    print STDERR "Putting ToC in place from $infile ...\n"
	unless $self->{options}->{quiet};
    if ($args{in_string}) # use input string, not file
    {
	$html_str = $args{in_string};
    }
    else
    {
	local $/;
	open (FILE, $infile) ||
	    die "Error: unable to open ", $infile, ": $!\n";

	$html_str = <FILE>;
	close (FILE);
    }

    # parse the file
    my $hp = new HTML::SimpleParse();
    $hp->text($html_str);
    $hp->parse();

    my $toc_tag = $self->{options}->{toc_tag};

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
		if (!$self->{options}->{toc_tag_replace}) {
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

=head1 FILE FORMATS

=head2 ToC Map File

For backwards compatibility with htmltoc, this method of specifying
significant elements for the ToC is retained.  It is, however,
deprecated and will be removed in a future version.

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
    H3:3                          # Make level 3 entries as is

B<EXAMPLE 3>

The following map file tries to index definition terms:

    # A ToC map file that can work for Glossary type documents
    H1:1
    H2:2
    DT:3:DD:<EM>,</EM>    # Assumes document has a DD for each DT, otherwise ToC
                       # will get entries with alot of text.

=head1 DETAILS

=head2 Formatting the ToC

The B<toc_entry> and other related options give you control on how the
ToC entries may look, but there are other options to affect the final
appearance of the ToC file created.

With the B<header> option, the contents of the given file will be
prepended before the generated ToC. This allows you to have introductory
text, or any other text, before the ToC.

=over 4

=item Note:

If you use the B<header> option, make sure the file specified
contains the opening HTML tag, the HEAD element (containing the
TITLE element), and the opening BODY tag. However, these
tags/elements should not be in the header file if the B<inline>
option is used. See L</Inlining the ToC> for information on what
the header file should contain for inlining the ToC.

=back 4

With the B<toclabel> option, the contents of the given string will be
prepended before the generated ToC (but after any text taken from a
B<header> file).

With the B<footer> option, the contents of the file will be appended
after the generated ToC.

=over 4

=item Note:

If you use the B<footer>, make sure it includes the closing BODY
and HTML tags (unless, of course, you are using the B<inline> option).

=back 4

If the B<header> option is not specified, the appropriate starting
HTML markup will be added, unless the B<toc_only> option is specified.
If the B<footer> option is not specified, the appropriate closing
HTML markup will be added, unless the B<toc_only> option is specified.

If you do not want/need to deal with header, and footer, files, then
you are allowed to specify the title, B<title> option, of the ToC file;
and it allows you to specify a heading, or label, to put before ToC
entries' list, the B<toclabel> option. Both options have default values.

If you do not want HTML page tags to be supplied, and just want
the ToC itself, then specify the B<toc_only> option.
If there are no B<header> or B<footer> files, then this will simply
output the contents of B<toclabel> and the ToC itself.

=head2 Inlining the ToC

The ability to incorporate the ToC directly into an HTML document
is supported via the B<inline> option.

Inlining will be done on the first file in the list of files processed,
and will only be done if that file contains an opening tag matching the
B<toc_tag> value.

If B<overwrite> is true, then the first file in the list will be
overwritten, with the generated ToC inserted at the appropriate spot.
Otherwise a modified version of the first file is output to either STDOUT
or to the output file defined by the B<toc_file> option.

The options B<toc_tag> and B<toc_tag_replace> are used to determine where
and how the ToC is inserted into the output.

B<Example 1>

    # this is the default
    $toc->args(toc_tag => 'BODY',
	toc_tag_replace => 0);

This will put the generated ToC after the BODY tag of the first file.
If the B<header> option is specified, then the contents of the specified
file are inserted after the BODY tag.  If the B<toclabel> option is not
empty, then the text specified by the B<toclabel> option is inserted.
Then the ToC is inserted, and finally, if the B<footer> option is
specified, it inserts the footer.  Then the rest of the input file
follows as it was before.

B<Example 2>

    $toc->args(toc_tag => '!--toc--',
	toc_tag_replace => 1);

This will put the generated ToC after the first comment of the form
<!--toc-->, and that comment will be replaced by the ToC
(in the order
    B<header>
    B<toclabel>
    ToC
    B<footer>)
followed by the rest of the input file.

=over 4

=item Note:

The header file should not contain the beginning HTML tag
and HEAD element since the HTML file being processed should
already contain these tags/elements.

=back 4

=head1 NOTES

=over 4

=item *

HTML::GenToc is smart enough to detect anchors inside significant
elements. If the anchor defines the NAME attribute, HTML::GenToc uses
the value. Else, it adds its own NAME attribute to the anchor.

=item *

The TITLE element is treated specially if specified in the B<toc_entry>
option. It is illegal to insert anchors (A) into TITLE elements.
Therefore, HTML::GenToc will actually link to the filename itself
instead of the TITLE element of the document.

=item *

HTML::GenToc will ignore a significant element if it does not contain
any non-whitespace characters. A warning message is generated if
such a condition exists.

=item *

If you have a sequence of significant elements that change in a slightly
disordered fashion, such as H1 -> H3 -> H2 or even H2 -> H1, though
HTML::GenToc deals with this to create a list which is still good HTML, if
you are using an ordered list to that depth, then you will get strange
numbering, as an extra list element will have been inserted to nest the
elements at the correct level.

For example (H2 -> H1 with ol_num_levels=1):

    1. 
	* My H2 Header
    2. My H1 Header

For example (H1 -> H3 -> H2 with ol_num_levels=0 and H3 also being
significant):

    1. My H1 Header
	1. 
	    1. My H3 Header
	2. My H2 Header
    2. My Second H1 Header

In cases such as this it may be better not to use the B<ol> option.

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

    <A NAME="foo"><H1><A NAME="The">The</A> FOO command</H1></A>

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

    HTML::SimpleParse
    Data::Dumper (only for debugging purposes)

=head1 EXPORT

None by default.

=head1 SEE ALSO

perl(1)
htmltoc(1)
hypertoc(1)

=head1 AUTHOR

Kathryn Andersen      http://www.katspace.com
based on htmltoc by
Earl Hood       ehood AT medusa.acs.uci.edu

=head1 COPYRIGHT

Copyright (C) 1994-1997  Earl Hood, ehood AT medusa.acs.uci.edu
Copyright (C) 2002-2004 Kathryn Andersen

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

