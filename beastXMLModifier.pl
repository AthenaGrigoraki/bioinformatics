#!/usr/bin/perl -w
use strict;

my $usage = "./beastXMLModifier.pl -in <BEAST XML> -fasta <FASTA FILE> -newick <NEWICK FILE>\n\n";

if($#ARGV<0){
    die "$usage";
}

my $beastxml = "";
my $fastafile = "";
my $newickfile = "";

while(my $args = shift @ARGV){
    if($args =~ /^-in/i){ $beastxml = shift @ARGV; next; }
    if($args =~ /^-fasta/i){ $fastafile = shift @ARGV; next; }
    if($args =~ /^-newick/i){ $newickfile = shift @ARGV; next; }
    die "Argument $args is invalid\n$usage";
}


open(FASTA, $fastafile) or die $!;

# my @names = ();
my %seq = ();
my $name = "";
my $cnt = 0;
while( defined(my $ln = <FASTA>) ){
    if( $ln =~ /^\s*$/){ next; }
    chomp($ln);

    if($ln =~/^>([^\s]+)/){
	$name = $1;
	$cnt = $cnt + 1;
	##print STDERR $cnt, "\t", $name, "\n";
	if(defined( $seq{$name} )){
	    die "Name $name is already defined\n";
	}
	$seq{$name} = "";
    }else{
	$seq{$name} = $seq{$name}.$ln;
    }
}

# foreach my $key (keys %seq){
#     print $key, "\t", $seq{$key}, "\n";
# }

open(TREE, $newickfile) or die $!;
my $tree = <TREE>;
chomp($tree);

## print $tree, "\n";

my $firstReplacement = "";

open(BEAST, $beastxml) or die $!;
while(defined(my $ln = <BEAST>)){
    chomp($ln);
    if($ln !~ /name="alignment">/ && $ln !~ /input\s+name="newick">/){
	print $ln, "\n";
    }elsif($ln =~ /name="alignment">/){
	$firstReplacement  = "name=\"alignment\">\n";
	foreach my $key(keys %seq){
	    $firstReplacement .= "<sequence id=\"".$key."\" spec=\"Sequence\" taxon=\"".$key."\" totalcount=\"4\" value=\"".$seq{$key}."\"\/>\n";
	}
	print $firstReplacement;
    }elsif($ln =~ /(^\s*<init.*input\s+name="newick">\s+)(\([^;]+;)\s*(<.*)/){
	my $prefix = $1;
	my $newick = $tree;
	my $suffix = $3;
	print $prefix, $newick, $suffix, "\n";
    }
    
}
