use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'HTML::GenToc',
    'VERSION_FROM'	=> 'GenToc.pm', # finds $VERSION
    'PREREQ_PM'		=> {'HTML::SimpleParse' => 0.10,
		'AppConfig' => 1.52,
		'Pod::Usage' => 0,
	}, # e.g., Module::Name => 1.1
);
