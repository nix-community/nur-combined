package SeoWebChecker::SeoAudit;

use 5.010;
use strict;
use warnings;
use JSON::PP;

our $VERSION = '1.0.0';

sub new {
    my ($class, %args) = @_;
    my $self = {
        user_agent => $args{user_agent} || 'SEOWebChecker-PerlBot/1.0 (+https://seowebchecker.com/)',
        timeout    => $args{timeout} || 15,
    };
    return bless $self, $class;
}

sub audit_html {
    my ($self, $html, $url) = @_;
    $url //= 'https://seowebchecker.com/';

    my @issues;

    # 1. Title
    my ($title) = $html =~ m{<title[^>]*>(.*?)</title>}is;
    if (defined $title) {
        $title =~ s/\s+/ /g;
        $title =~ s/^\s+|\s+$//g;
        my $len = length($title);

        if ($len < 30) {
            push @issues, { id => 'meta-title-short', category => 'meta', severity => 'warning', title => 'Title Too Short', message => "Title has $len characters.", recommendation => 'Expand to 30-60 characters.' };
        } elsif ($len > 65) {
            push @issues, { id => 'meta-title-long', category => 'meta', severity => 'warning', title => 'Title Too Long', message => "Title has $len characters.", recommendation => 'Shorten to under 60 characters.' };
        } else {
            push @issues, { id => 'meta-title-pass', category => 'meta', severity => 'pass', title => 'Optimal Title Length', message => "Title has $len characters.", recommendation => 'Maintain clear title.' };
        }
    } else {
        push @issues, { id => 'meta-title-missing', category => 'meta', severity => 'error', title => 'Missing Title Tag', message => 'No title tag found.', recommendation => 'Add a descriptive title tag.' };
    }

    # 2. Viewport
    if ($html =~ m{<meta[^>]*name=["']viewport["']}i) {
        push @issues, { id => 'meta-viewport-pass', category => 'meta', severity => 'pass', title => 'Mobile Viewport Present', message => 'Viewport configured.', recommendation => 'Mobile responsive.' };
    } else {
        push @issues, { id => 'meta-viewport-missing', category => 'meta', severity => 'error', title => 'Missing Viewport', message => 'No viewport tag.', recommendation => 'Add mobile viewport tag.' };
    }

    # 3. Headings
    my @h1s = ($html =~ m{<h1[^>]*>(.*?)</h1>}gis);
    my $h1_count = scalar @h1s;
    if ($h1_count == 0) {
        push @issues, { id => 'content-h1-missing', category => 'content', severity => 'error', title => 'Missing <h1> Tag', message => 'No <h1> heading found.', recommendation => 'Add a single <h1> heading.' };
    } elsif ($h1_count == 1) {
        push @issues, { id => 'content-h1-pass', category => 'content', severity => 'pass', title => 'Single <h1> Tag Configured', message => 'Single H1 found.', recommendation => 'Good hierarchy.' };
    } else {
        push @issues, { id => 'content-h1-multiple', category => 'content', severity => 'warning', title => "Multiple <h1> Tags ($h1_count)", message => "Found $h1_count <h1> tags.", recommendation => 'Consolidate to a single <h1>.' };
    }

    # 4. HTTPS
    if ($url =~ m{^https://}i) {
        push @issues, { id => 'tech-https-pass', category => 'technical', severity => 'pass', title => 'Secure HTTPS Active', message => 'Connection secured with SSL.', recommendation => 'Keep certificate valid.' };
    } else {
        push @issues, { id => 'tech-not-https', category => 'technical', severity => 'error', title => 'Insecure HTTP Protocol', message => 'URL uses plain HTTP.', recommendation => 'Install SSL certificate.' };
    }

    # Scoring
    my $passed   = scalar grep { $_->{severity} eq 'pass' } @issues;
    my $warnings = scalar grep { $_->{severity} eq 'warning' } @issues;
    my $errors   = scalar grep { $_->{severity} eq 'error' } @issues;

    my $total = scalar @issues;
    my $raw_score = $total > 0 ? int(($passed / $total) * 100) : 80;
    $raw_score -= ($errors * 10) + ($warnings * 3);
    my $final_score = $raw_score < 0 ? 0 : ($raw_score > 100 ? 100 : $raw_score);

    my $grade = $final_score >= 95 ? 'A+' :
                $final_score >= 90 ? 'A' :
                $final_score >= 80 ? 'B' :
                $final_score >= 70 ? 'C' :
                $final_score >= 60 ? 'D' : 'F';

    return {
        url          => $url,
        score        => { overall => $final_score, grade => $grade },
        stats        => { total => $total, passed => $passed, warnings => $warnings, errors => $errors },
        meta         => { title => $title },
        issues       => \@issues,
    };
}

1;
__END__

=head1 NAME

SeoWebChecker::SeoAudit - Lightweight open-source client SDK for website SEO audits

=head1 SYNOPSIS

  use SeoWebChecker::SeoAudit;

  my $auditor = SeoWebChecker::SeoAudit->new();
  my $result  = $auditor->audit_html($html, 'https://example.com');
  print "Score: " . $result->{score}{overall} . "/100\n";

=head1 AUTHOR

SEOWebChecker Team, L<https://seowebchecker.com/>

=cut
