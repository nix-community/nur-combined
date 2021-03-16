#!/usr/bin/env perl
#
# OpenBox Applications (Pipe)Menu (C) Biffidus 2008
#
# (only kidding, it's not copyrighted. Do whatever you like with it)
#
# This pipe menu creates an application menu from the .desktop files
# found in many linux distributions. The desktop file must be of type
# Application and specify their Categories.
#
# One or more paths to search may be provided on the command line or
# specified below. The menu structure is derived from the Categories
# attribute and may be customised below with the following keywords:
#
# hide:     menu will not be displayed
# collapse: the submenus will be used instead
#
# Any item starting with X- is automatically hidden

my @APPDIRLIST = split /:/, %ENV{'XDG_DATA_DIRS'};
my $APPSDIR = "";
for (@APPDIRLIST) {
    $APPSDIR = $APPSDIR . " " . $_ . "/applications/";
}

my %CFG =
    (
     "Application" => "collapse",
     "GTK"         => "collapse",
     "KDE"         => "collapse",
     "Qt"          => "collapse",
    );

###############################################################################

# Hash of hashes
# $Hash{x}->{y} = z
# $Hash{x}{y}

my %menu; # application details

# Hash of arrays
# $Hash{$key} = \@Array
# @Array = @{$Hash{$key}}

my %cat;  # apps in each category (hashed lists)

################################################### Search for Applications ###

if ($#ARGV != -1) { $APPSDIR = join(" ", @ARGV); }

print STDERR "Searching $APPSDIR\n";

open (APPS, "find ".$APPSDIR." -name '*.desktop' |") || do
{
    print qq|<openbox_pipe_menu><item label="Error!" /></openbox_pipe_menu>\n|;
    die "could not open $APPSDIR";
};
@FILES = <APPS>;
close APPS;

######################################################## Parse Applications ###

print STDERR "\n### Scanning applications ###\n";

foreach $entry (@FILES)
{
    if (open(DE,$entry) && $entry =~ s|^.*/(.*?)\.desktop|$1|)
    {
        while (<DE>)
        {
            chomp;
            if (/^(\w+)=([^%]+)/)
            {
                # populate application details
                $menu{$entry}->{$1} = $2;

                # determine category
                if ($1 eq "Categories")
                {
                    print STDERR $2 . $entry;
                    my @tmp = split(/;/,$2);

                    while ($CFG{$tmp[0]} eq "collapse")
                    {
                        shift @tmp;
                    }
                    if ($CFG{$tmp[0]} ne "hide" && $tmp[0] !~ /^X-/)
                    {
                        push @{$cat{$tmp[0]}},$entry;
                    }
                }
            }
        }
    }
}

############################################################# Generate Menu ###

print STDERR "\n### Generating menu ###\n";

print "<openbox_pipe_menu>\n";

foreach $key (sort keys %cat)
{
    print qq| <menu id="obam-$key" label="$key">\n|;

    foreach $app (sort @{$cat{$key}})
    {
        if ($menu{$app}{Type} eq "Application")
        {
            my $Name = $menu{$app}{Name};
            my $Exec = $menu{$app}{Exec};
            print qq|  <item label="$Name"><action name="Execute"><execute>$Exec</execute></action></item>\n|;
        }
    }
    print " </menu>";
}
print "</openbox_pipe_menu>\n";

print STDERR "Done\n";

###############################################################################
