#!/usr/bin/env perl
# Turn a backticked reference to a markdown file that exists in the repo
# into a link to it: `evals.md` becomes [`evals.md`](evals.md), and
# `design/cli/README.md` becomes a link relative to the referring file.
# Fenced code and references already inside a link are left alone.
use strict;
use warnings;
use File::Basename qw(dirname);
use File::Spec;

my $root = shift or die "usage: link-refs.pl <repo root> <file>...\n";

for my $file (@ARGV) {
  open my $in, '<', $file or die "$file: $!";
  my @lines = <$in>;
  close $in;

  my $dir = dirname($file);
  my $fenced = 0;
  my $changed = 0;

  for my $line (@lines) {
    if ($line =~ /^\s*(```|~~~)/) {
      $fenced = !$fenced;
      next;
    }
    next if $fenced;

    $line =~ s{
      (?<!\[)            # not already the text of a link
      `((?:design/)?[A-Za-z0-9][A-Za-z0-9./-]*\.md)`
      (?!\]\()           # not already followed by a link target
    }{
      my $ref = $1;
      my $target = $ref;
      $target =~ s{^design/}{};
      my $abs = $ref =~ m{^design/}
        ? File::Spec->catfile($root, $target)
        : File::Spec->catfile($dir, $target);
      if (-f $abs) {
        my $rel = File::Spec->abs2rel($abs, $dir);
        $changed++;
        "[`$ref`]($rel)";
      } else {
        "`$ref`";
      }
    }gex;
  }

  if ($changed) {
    open my $out, '>', $file or die "$file: $!";
    print {$out} @lines;
    close $out;
    print "$file: $changed\n";
  }
}
