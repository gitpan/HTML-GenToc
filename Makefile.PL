use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'HTML::GenToc',
    'VERSION_FROM'	=> 'GenToc.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'ExtUtils::configPL' => 0,
    		'HTML::SimpleParse' => 0.10,
		'Getopt::Long' => 0,
		'Pod::Usage' => 0,
		'Data::Dumper' => 0,
		'Test::Simple' => 0,
	}, 
    'PL_FILES' => { 'hypertoc.PL' => 'hypertoc'},
    'EXE_FILES' => ['hypertoc'],
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'GenToc.pm', # retrieve abstract from module
       AUTHOR     => 'Kathryn Andersen') : ()),

);
