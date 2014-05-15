#!/usr/bin/env perl

use strict;

sub main {
    my $input = do { local $/; <> };
    $input =~ s/.*?\n= Commands\n//s;
    $input =~ s/(.*?\n== Configuration Commands\n.*?\n)==? .*/$1/s;
    my @list;
    while ($input =~ s/.*?^- (.*?)(?=\n- |\n== |\z)//ms) {
        my $text = $1;
        $text =~ /\A(.*)\n((?s:.*?))\n*\z/
            or die "Bad text '$text'";
        my ($usage, $desc) = ($1, $2);
        $usage =~ s/\A`(.*)`\z/$1/
            or die "Bad usage: '$text' '$usage' '$desc'";
        (my $name = $usage) =~ s/ .*//;
        push @list, [$name, $usage, $desc];
    }
    @list = sort { $a->[0] cmp $b->[0] } @list;
    write_start();
    write_all_function(@list);
    for my $item (@list) {
        write_usage_function(@$item);
    }
    write_finish();
}

sub write_start {
    print <<'...';
#!/usr/bin/env bash

# DO NOT EDIT. This file generated by tool/generate-help-functions.pl.

set -e
...
}

sub write_all_function {
    my (@list) = @_;
    my $out = '';
    for my $item (@list) {
        $out .= sprintf "%-20s %s\n", $item->[0], $item->[1];
    }
    chomp $out;
    print <<"....";

help:all() {
    cat <<'...'
$out
...
}
....
}

sub write_usage_function {
    my ($name, $usage, $desc) = @_;
    print <<"....";

help:$name() {
    cat <<'...'

  Usage: git hub $usage

$desc
...
}
....
}

sub write_help_function {
    my ($name, $usage, $desc) = @_;
}

sub write_finish {
    print <<'...';

# vim: set sw=2 lisp:
...
}

main;

__END__
Bad usage: '`help`
  Show this manpage.
' '' '  Show this manpage.' at tool/gerate-help-functions.pl line 15, <> line 1.

