use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'HTML::GenToc',
    'VERSION_FROM'	=> 'GenToc.pm', # finds $VERSION
    'PREREQ_PM'		=> {'HTML::SimpleParse' => 0.10,
		'AppConfig' => 1.52,
		'AppConfig::Args' => 0,
		'AppConfig::File' => 0,
		'AppConfig::State' => 0,
		'AppConfig::Sys' => 0,
		'Pod::Usage' => 0,
		'Data::Dumper' => 0,
		'Test::Simple' => 0,
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'GenToc.pm', # retrieve abstract from module
       AUTHOR     => 'Kathryn Andersen <rubykat@katspace.com>') : ()),

);
