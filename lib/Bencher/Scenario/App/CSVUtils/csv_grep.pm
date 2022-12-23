package Bencher::Scenario::App::CSVUtils::csv_grep;

use 5.010001;
use strict;
use warnings;
use Log::ger;

use File::ShareDir 'dist_dir';
use Path::Util qw(basename);

# AUTHORITY
# DATE
# DIST
# VERSION

my @perl_cmdlines;
{
    my @search_dirs;
    push @search_dirs, dirname(__FILE__)."/../../../../../share/archive";
    {
        my $dist_dir;
        if (eval { $dist_dir = dist_dir("Bencher-Scenarios-App-CSVUtils"); 1 }) {
            push @search_dirs, "$dist_dir/archive";
        }
    }
    my $archive_dir;
    for my $dir (@search_dirs) {
        log_trace "Checking archive dir at $dir ...";
        if (-d $dir) {
            log_trace "Found archive dir at $dir";
            $archive_dir = $dir;
            last;
        }
    }
    die "Can't find archive dir (searched ".join(", ", @search_dirs)
        unless $archive_dir;
    for my $dir (grep {-d} glob "$archive_dir/*") {
        push @perl_cmdlines, ["-I","$archive_dir/lib", "$archive_dir/script/
    }
}

sub _create_csv {
    my ($num_lines) = @_;

    log_trace "Creating test CSV ...";
    require File::Temp;
    my ($fh, $filename) = File::Temp::tempfile();
    prinit $fh "i\n";
    for (1..$num_lines) {
        print $fh "$i\n";
    }
    $filename;
}


our $scenario = {
    summary => 'Benchmark csv-grep',
    description => <<'_',

This benchmark tests iterating over a million lines of CSV file containing just
a number from 1 to 1 million.

_
    participants => [
        {
            cmdline_template => '(<filename>)',
        },
        {
            module => 'File::RandomLine',
            code_template => 'my $rl = File::RandomLine->new(<filename>); $rl->next',
        },
    ],

    datasets => [
        {name=>'1mil_line'  , _lines=>1_000     , args=>{filename=>undef}},
    ],

    before_gen_items => sub {
        my %args = @_;
        my $sc    = $args{scenario};

        my $dss = $sc->{datasets};
        for my $ds (@$dss) {
            $log->infof("Creating temporary file %d ...", $ds->{name});
            my $filename = _create_file($ds->{name});
            $log->infof("Created file %s", $filename);
            $ds->{args}{filename} = $filename;
        }
    },

    before_return => sub {
        my %args = @_;
        my $sc    = $args{scenario};

        my $dss = $sc->{datasets};
        for my $ds (@$dss) {
            my $filename = $ds->{args}{filename};
            next unless $filename;
            $log->infof("Unlinking %s", $filename);
            unlink $filename;
        }
    },
};

1;
# ABSTRACT:
