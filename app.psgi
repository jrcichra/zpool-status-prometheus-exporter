#!/usr/bin/plackup
use strict;
use warnings;
use Prometheus::Tiny;
use Plack::Builder;

my $prom = Prometheus::Tiny->new;

my %statuses = (
    ONLINE   => 0,
    DEGRADED => 1,
    FAULTED  => 2,
    OFFLINE  => 3,
    UNAVAIL  => 4,
    REMOVED  => 5,
);

sub collect {

    # collect stuff
    my $pools_cmd = 'zpool list -H | awk \'{print $1}\'';
    my @pools     = split( '\n', `$pools_cmd` );
    foreach my $pool (@pools) {

        # print "Swimming in $pool\n";

        # run the zpool status command
        my $zpool_status = `zpool status -v $pool`;

        # extract out the config data
        my $zpool_status_config = $zpool_status;

        # trim down the zpool status into a predictable list
        # remove double line breaks
        $zpool_status_config =~ s/\n+/\n/g;

        # convert line breaks into ===
        $zpool_status_config =~ s/\n/===/g;

        # trim extra whitespace
        $zpool_status_config =~ s/\s+/ /g;

        # only grab the config
        ($zpool_status_config) = $zpool_status_config =~ /config:(.*)errors:/;

        # convert into an array
        my @zpool_status_config_arr = split( '===', $zpool_status_config );

        # pop off the header
        shift @zpool_status_config_arr;
        shift @zpool_status_config_arr;

        # loop through each array element
        foreach my $line (@zpool_status_config_arr) {

            # print "Processing $line\n";

            # make an array based on space separation
            my @elements = split( ' ', $line );
            $prom->set(
                "zpool_state",
                $statuses{ $elements[1] },
                {
                    "pool"  => $pool,
                    "name"  => $elements[0],
                    "state" => $elements[1],
                }
            );
            $prom->set( "zpool_read_errors", $elements[2],
                { "pool" => $pool, "name" => $elements[0] } );
            $prom->set( "zpool_write_errors", $elements[3],
                { "pool" => $pool, "name" => $elements[0] } );
            $prom->set( "zpool_checksum_errors", $elements[4],
                { "pool" => $pool, "name" => $elements[0] } );
        }

        # solo stats
        # grab the pool state: ONLINE, DEGRADED, OFFLINE, etc
        my ($zpool_state) = $zpool_status =~ /state: (.*)\n/;
        $prom->set( 'zpool_state', $statuses{$zpool_state},
            { "pool" => $pool, "state" => $zpool_state } );
    }
}

builder {
    # collect stats when metrics is requested
    mount "/metrics" => sub {
        collect();
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ $prom->format ] ];
    }
};
