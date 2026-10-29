use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'SeoWebChecker::SeoAudit',
    AUTHOR           => 'SEOWebChecker Team <support@seowebchecker.com>',
    VERSION_FROM     => 'lib/SeoWebChecker/SeoAudit.pm',
    ABSTRACT         => 'Lightweight open-source client SDK for website SEO audits by SEOWebChecker',
    LICENSE          => 'mit',
    MIN_PERL_VERSION => '5.010',
    EXE_FILES        => ['bin/seowebchecker-audit'],
    PREREQ_PM        => {
        'JSON::PP' => '0',
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            homepage   => 'https://seowebchecker.com/',
            repository => {
                type => 'git',
                url  => 'https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk.git',
                web  => 'https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk',
            },
            bugtracker => {
                web => 'https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues',
            },
        },
    },
);
