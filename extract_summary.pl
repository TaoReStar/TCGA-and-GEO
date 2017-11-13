#!/usr/bin/perl
################################################################
#  This tools help user to set link for each gene symbol
#
#  require input files : gene list
#
#        Format:
#        group   gene
#        g1      LASS1
#        g1      OLIG1
#        g2      NEFL
#        g2      TF
#        g2      TFRC
#        g2      SLC11A
#  column one: give each gene a label
#  column two: gene symbol
#  this script will seperate gene by groups
#  copy right 2015  LiangChen  contact: liangliangabc123@163.com
################################################################

# when your perl have install the String::Utill module you could
# uncoment the following code and coment the end function trim
#use String::Util qw(trim);

#use strict;
use HTTP::Tiny;
# set file path for $softfile
# this file contain the paire of probe gene symbol
# using for initialize the hash(probe to symbol)


# !!!!!!!!!!!!!!!!!!!!!
my $path = "/Users/shacao/huiyan/";
my $cachedFilePath =    "/Users/shacao/huiyan/cached2/";

my $id_map_file  = $path."Homo_sapiens.gene_info";
my $inputfile    =  $path."test";
my $outputfile   =  $path.$inputfile."html";
my $prefix_link = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=gene&id=";
my %group2genelist = %{iniHash($inputfile)};

my %symbol2id = %{iniHash_symbol2id($id_map_file)};

my $html_header = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title></title></head><body>';
my $html_tail   = '</body></html>';
#my $content =  getContent($prefix_link."LASS1");
#my $content =  getTestContent();
#print getSummary($content);

open OFILE , ">".$outputfile  or die ("Sorry!\n");
print OFILE $html_header;
foreach my $g (keys %group2genelist){
    my @gene_list = @{$group2genelist{$g}};
    print OFILE "<b>".$g."</b>";
    print OFILE '<table width="1300" border="1">';

    foreach my $gene (@gene_list){
       print "Gnerating $gene! ... \n";
       my $content = "";

       my $id = 0;
       if(defined $symbol2id{$gene}){
          $id = $symbol2id{$gene};
       }
       my $cached_file = $cachedFilePath.$id.".xml";
       my $genecard_link = $prefix_link.$id;

       if(isCached($cached_file)) {
          $content =  getContentFromCachedFile($cached_file);
       }else{
          $content =  getContentFromGenecard($genecard_link);
#          $wait_time = rand(5);
#          print "Sleeping ".$wait_time." seconds!";
#          sleep($wait_time);
          writeCachedHtml($cached_file, $content);
       }

       my $summary =  getSummary($content);
       my $genewithlink = '<a target="_blank" href="'.$genecard_link.'">'.$gene.'</a>';
       print OFILE "<tr><td>".$genewithlink."</td>";
       print OFILE "<td>".$summary."</td></tr>";
    }
    print OFILE '</table>';

}
print OFILE $html_tail;
close OFILE;
print "done!\n";



sub isCached{
    my $file = $_[0];
    if(-e $file){
       return 1;
    }else{
       return 0;
    }
}
sub getContentFromGenecard{
    my $link = $_[0];
    my $http = HTTP::Tiny->new();
    my $response = $http->get($link);
#    die "Failed!\n" unless $response->{success};
    my $contents = "";
    if($response->{success}){
        $contents =  $response->{content}
    } else{
        $contents = "not in genbank!\n";
    }
    return $contents;
}

sub getContentFromCachedFile{
     my $file =  $_[0];
     my $content="";
     open FILE,  "<".$file or die ("Sorry $file!");
     readline(FILE);
     while(<FILE>){
       my $line = $_;
       $content = $content . $line;
     }
     close FILE;
     return $content;
}


sub getSummary{
     my $contents = $_[0];
     my $summary = "";

     $contents =~ s/[\r\n]//g;

     my $pattern = '<Summary>(.*?)</Summary>';

     if($contents =~ /$pattern/){
           $summary = $1;
     }

     return $summary;
}

sub iniHash_symbol2id{
     my $file = $_[0];
     my %symbol2id ;
     open FILE,  "<".$file or die ("Sorry $file!");
     readline(FILE);
     while(<FILE>){
       my $line = trim($_);
       my @temp = split /\t/ , $line;
       my $id = $temp[1];
       my $symbol  = $temp[2];
       my $type = $temp[9];
#       print $id."\t".$symbol."\n";
       if( defined $symbol2id{$symbol} ){
           print "$id is repeated![$type] ; ";
       } else{
          $symbol2id{$symbol} = $id  ;
       }
     }
     close FILE;
     return \%symbol2id;

}

sub  iniHash{
     my $file = $_[0];
     my %group2genelist ;
     open FILE,  "<".$file or die ("Sorry $file!");
     readline(FILE);
     while(<FILE>){
       my $line = trim($_);
       my @temp = split /\t/ , $line;
       my $group = $temp[0];
       my $gene  = $temp[1];
       print $group."\t".$gene."\n";
       if( defined $group2genelist{$group} ){
            my @temp_genes = @{$group2genelist{$group}};
            push  @temp_genes, $gene;
            $group2genelist{$group} =  \@temp_genes;
       } else{
           local @genes;
           push  @genes, $gene;
           $group2genelist{$group} =  \@genes;
       }
     }
     close FILE;
     return \%group2genelist;
}

sub writeCachedHtml{
    my $file = $_[0];
    my $content = $_[1];
    open FILE, ">".$file or die ("Sorry!\n");
    print FILE $content;
    close FILE;
}

sub trim {
   (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;
}
