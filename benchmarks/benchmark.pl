#!/usr/bin/env perl

use warnings;
use strict;
use IO::Socket;
use IO::Socket::INET;

$| = 1; # autoflush

sub send_benchmark {
	my ($lib, $addr, $port, $logname, $iter) = @_;
	my ($socket, $remote, $data);

	$socket = IO::Socket::INET->new(
		PeerAddr  => $addr,
		PeerPort  => $port,
		LocalAddr => "127.0.0.1",
		LocalPort => $port,
		Proto     => "tcp",
		Type      => SOCK_STREAM,
		Listen    => 1,
	) or die "Couldn't connect to $addr:$port : $@\n";

	$remote = $socket->accept();

	for ((1 .. $iter)) {
		$remote->recv($data, 16);
		system ("time ./$lib/sender >> $lib/results/$logname 2>&1");
	}
}

sub recv_benchmark {
	my ($lib, $addr, $port, $logname, $iter) = @_;

	my $socket = IO::Socket::INET->new(
		PeerAddr  => $addr,
		PeerPort  => $port,
		Proto     => "tcp",
		Type      => SOCK_STREAM,
		Timeout   => 1,
	) or die "Couldn't connect to $addr:$port : $@\n";

	for ((1 .. $iter)) {
		$socket->send("start");
		system ("time ./$lib/receiver >> $lib/results/$logname 2>&1");
	}
}

if ($#ARGV + 1 != 6) {
	print "usage: perl benchmarks.pl"
	. "\n\t<kvzrtp|ffmpeg|gstreamer>"
	. "\n\t<send|recv>"
	. "\n\t<ip>"
	. "\n\t<port>"
	. "\n\t<log_name>"
	. "\n\t<# of iterations>\n" and exit;
}

if ($ARGV[1] eq "send") {
	system ("make $ARGV[0]_sender");
	send_benchmark($ARGV[0], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5]);
} elsif ($ARGV[1] eq "recv" ){
	system ("make $ARGV[0]_receiver");
	recv_benchmark($ARGV[0], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5]);
} else {
	print "invalid role: '$ARGV[1]'\n" and exit;
}