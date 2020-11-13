#!/usr/bin/env perl
use v5.24;
use Text::Template;
use Opt::Imistic;

my $t = shift;

my $template = Text::Template->new(TYPE => 'FILE', SOURCE => $t);

open my $t_in, '<', $t;

$T::TOC = '';
while (<$t_in>) {
    chomp;
    next if /---/../---/;

    next unless s/^(#+) //;

    my $level = length $1;
    my $link = lc;
    # Hugo just sort of removes these...
    $link =~ s{[/.=]}{}g;

    # And replaces these
    my $not_alnum = qr/[^[:alnum:]]+/;
    $link =~ s/^$not_alnum|$not_alnum$//g;
    $link =~ s/$not_alnum/-/g;

    $T::TOC .= ('  ' x ($level - 1)) . '* ' . "[$_](#$link)\n";
}

my $fixed = $template->fill_in(PACKAGE => 'T');

close $t_in;

if ($ARGV{i}) {
    open my $t_out, '>', $t;
    $t_out->print($fixed);
}
else {
    print $fixed;
}
