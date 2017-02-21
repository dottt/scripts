#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Net::Twitter::Lite::WithAPIv1_1;
use Config::Pit;
use Pod::Usage;
$| = 1;

sub usage {
    pod2usage(2);
    die;
}

my $config = pit_get("twitter");
my $nt;
eval {
    $nt = Net::Twitter::Lite::WithAPIv1_1->new(
        consumer_key        => $config->{consumer_key},
        consumer_secret     => $config->{consumer_secret},
        access_token        => $config->{access_token},
        access_token_secret => $config->{access_token_secret},
        ssl                 => 1,
    );
};
if ($@) {
    print $@;
}
my $max_id = undef;
my %max_id;

my $twt;
print "ARE YOU REALLY WANT TO REMOVE ALL TWEETS FROM \" ${$nt->user_timeline}[0]->{user}->{screen_name} \"? (y/n) \n";
my $str = <STDIN>;
chomp $str;
exit unless $str eq 'y';

print "THEN AFTER 10 SECONDS, START\n";
sleep 10;

while (1) {
    %max_id = (max_id => $max_id) if defined $max_id;
    eval {
        $twt = $nt->user_timeline({
            count => 200,
            include_rts => 0,
            %max_id,
        });
    };
    last if (scalar @$twt == 0);
    $max_id = @$twt[scalar @$twt-1]->{id} -1;
    foreach (@$twt) {
        $nt->destroy_status($_->{id});
    }

    if($@){
        print Dumper $@;
        exit;
    }
}

__END__

=head1 NAME

$0 -- remove all tweets

=head1 SYNOPSIS

$0

API keys information are required by Config::Pit format.
$ cat ~/.pit/default.yaml
---
"twitter":
  "consumer_key": 'hogehoge'
  "consumer_secret": 'hogehoge'
  "access_token": 'hogehoge'
  "access_token_secret': 'hogehoge'

Use this program at your own risk.
