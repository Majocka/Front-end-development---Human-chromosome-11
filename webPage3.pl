#!/usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser); 
use lib "/d/user5/bm002/WWW/cgi-bin/lib"; 
use moduleNew; 

my $cgi = new CGI;
print $cgi->header();
my $query = $cgi->param('search');
my $dbh = moduleNew::ConnectToDatabase();

# getting the general info
my $gene_name = moduleNew::GetGeneName($query, $dbh);
my $gene_function = moduleNew::GetGeneFunction($query, $dbh);
my $dna_sequence = moduleNew::GetDNAsequence($query, $dbh);
my $aa_sequence = moduleNew::GetAminoAcidSequence($query, $dbh);

# dealing with codon usage frequencies
my $codon_number = moduleNew::GetNumberOfCodonsInSequence($dna_sequence);
my @seq_codons = moduleNew::GetCodonArrayFromSequence($dna_sequence); 
my @all_codons = moduleNew::ComputeAllPossibleCodons();
my ($cod_count, $counts, $all_freq, $freq) = moduleNew::GetArrayOfCodonFrequencies(\@all_codons, \@seq_codons, $codon_number);
my %cod_count = %$cod_count; my @counts = @$counts; my @all_freq = @$all_freq; my %freq = %$freq;
my %distinct_codons = moduleNew::MakeDistictCollectionofCodons(\@seq_codons);

# getting the codon usage ratios
my %codon_aa = moduleNew::MakeHashOfCodonsAndTheirAminoAcids(\@all_codons); 

my @amino_acids = moduleNew::GetAllPossibleAminoAcids();
my %ratios = moduleNew::GetRatiosOfAminoAcids(\@amino_acids, \%codon_aa, \%distinct_codons, \@all_codons, \%freq);

# getting the CDS
my @seq_array = moduleNew::MakeSequeceAnArray($dna_sequence);
my $regions = moduleNew::GetCodingRegionStrings($query, $dbh);
my @coding_regions = moduleNew::GetArrayOfCodingRegions($regions);
my ($posns, $lengths) = moduleNew::GetCodingStartPositionsAndCodingLengths(\@coding_regions);
my @posns = @$posns; my %lengths = %$lengths;


print <<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
	<head>
        <meta http-equiv="Content-Type" content="text/html"/>
		<title>Our third page</title>
		<meta name="gene description" content="Detailed info on gene"/>
		<meta name="author" content="Maria Boznakova"/>
		<link rel="stylesheet" type="text/css" href="http://student.cryst.bbk.ac.uk/~bm002/stylesheets/ourstyle.css"/>

		<style type="text/css"> 
			#pageContent{ 
			margin-left:30px;
			}			
			#div_highlight_site{
    		display:none;
			}
			#dna_seq, #dna, #aa_seq2, #dna_seq3{ 
			word-wrap:break-word;
			border:1px solid black;
			width:750px;
			height:250px;
			overflow:scroll;
			}
			#aa_seq2{ 
			height:100px;
			}
			.highlight{ 
			background:yellow; padding:1px; border:#00CC00 dotted 1px; 
			}  
		    </style> 

		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>

		<script type="text/javascript">
			jQuery(document).ready(function(){
				// to show/hide the content links on the top of page
				jQuery("#button1").click(function(){
					jQuery("#pageContent").slideToggle(1500);
				});	
				// to show/hide the scroll bar with the highlighting of restriction enzyme sites 
				jQuery("#button2").click(function(){
					jQuery("#div_highlight_site").slideToggle("slow");
				});
			});
			function getRestrictionEnzSites(enzyme,site){
				jQuery("#dna_seq3").find(".highlight").removeClass("highlight"); //remove previously highlighted searched sites 
				var filter = new RegExp(site, "igm");
				var match = jQuery("#dna_seq3").text().match(filter);   // matching again so can count number of match occurrences 
    			var count = match ? match.length : 0;
				jQuery("#dna_seq3").each(function(){ 
					jQuery(this).html(jQuery(this).html().replace(filter,"<span class='highlight'>" + site + "</span>")); 
					if (jQuery(this).html().indexOf(site)==-1){ //if the #dna_seq does not contain the site (if index == -1)
						alert("SORRY! There are no sites for " + enzyme);
					}
					else{
						alert("SUCCESS! There is " + count + " of the sites for " + enzyme);
					}
				});																												 
			}	
		</script>
	</head>
	
	<body>
		
		<p>The detailed information on <strong>'$query'</strong> can be found below. If the information is not available it will be again classified as 'not listed'.</p>
		<h3>Content of the page</h3>		
    	<div id="pageContent">
		<h4><a href="#name">Name of the gene</a></h4>
		<h4><a href="#function">Function of the gene</a></h4>
		<h4><a href="#dna_seq2">DNA sequence</a></h4>
		<h4><a href="#aa_seq">Amino acid sequence</a></h4>
		<h4><a href="#codon_usage">Codon usage frequency</a></h4></div>
		<button id="button1">Show/hide the content links</button>
		
		<h3><a id="name"/> Name of the gene:</h3><p>$gene_name</p>
		<h3><a id="function"/>Function of the gene:</h3><p>$gene_function</p>
		<h3><a id="dna_seq2"/>DNA sequence:</h3>
    	<p style="font-size:14px">With coding region sequences being highlighted in yellow.</p>
		<p id="dna_seq">
EOF
    # start of Micheal's code (the only section here, that is not my code)
    my $initial = 0;
	foreach my $postn(@posns){
    	for (my $i=$initial; $i<$postn; $i++){
			print "$seq_array[$i]";
    	}
    	my $sth = $postn + $lengths{$postn};
    	for (my $j=($postn); $j<$sth; $j++){
			print "<span style='background-color: rgb(255,255,0)'>$seq_array[$j]</span>";
    	}
    	$initial = $sth;
	}
	
	for (my $l=($posns[-1]+ $lengths{$posns[-1]}); $l<scalar(@seq_array); $l++){ #print the part of the seq that comes after the last cleavage site
    	print "$seq_array[$l]";
	}
    # end of Micheal's code
print <<EOF;

		</p> 
		
		<button id="button2">Show/hide enzyme restriction sites</button>
		
		<div id="div_highlight_site">
		<p id="dna_seq3">$dna_sequence</p>

		<p style="font-size:14px">To find the site for particular enzyme click below.</p>		
		<button onclick="getRestrictionEnzSites('EcoRI','gaattc')">For EcoRI sites</button>
		<button onclick="getRestrictionEnzSites('BamHI','ggatcc')">For BamHI sites</button>
		<button onclick="getRestrictionEnzSites('BsuMI','ctcgag')">For BsuMI sites</button>
		</div>
		
		<h3><a id="aa_seq"/>Amino acid sequence: </h3>
		<p id="aa_seq2">$aa_sequence</p>
		
		<table width=20% style="font-size:16px">
		 <h3><a id="codon_usage"/>Codon usage frequency</h3>
		 <tr>
		  <th></th>
		  <th>Codon</th>
		  <th>Amino acid</th>
		  <th>%</th>
		  <th>Ratio</th>
		  <th>Codon</th>
		  <th>Amino acid</th>
		  <th>%</th>
		  <th>Ratio</th>
		  <th>Codon</th>
		  <th>Amino acid</th>
		  <th>%</th>
		  <th>Ratio</th>
		  <th>Codon</th>
		  <th>Amino acid</th>
		  <th>%</th>
		  <th>Ratio</th>
		  <th></th>
		  </tr>
		  
		 <tr>
		  <th rowspan="4">U</th>
		  <td>UUU</td>
		  <td>Phe(F)</td>
		  <td>$all_freq[0]</td>
		  <td>$ratios{UUU}</td>
		  <td>UCU</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[1]</td>
		  <td>$ratios{UCU}</td>
		  <td>UAU</td>
		  <td>Tyr(Y)</td>
		  <td>$all_freq[2]</td>
		  <td>$ratios{UAU}</td>
		  <td>UGU</td>
		  <td>Cys(C)</td>
		  <td>$all_freq[3]</td>
		  <td>$ratios{UGU}</td>
		  <th>U</th>
		 </tr>
		 
		 <tr>
		  <td>UUC</td>
		  <td>Phe(F)</td>
		  <td>$all_freq[4]</td>
		  <td>$ratios{UUC}</td>
		  <td>UCC</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[5]</td>
		  <td>$ratios{UCC}</td>
		  <td>UAC</td>
		  <td>Tyr(Y)</td>
		  <td>$all_freq[6]</td>
		  <td>$ratios{UAC}</td>
		  <td>UGC</td>
		  <td>Cys(C)</td>
		  <td>$all_freq[7]</td>
		  <td>$ratios{UGC}</td>
		  <th>C</th>
		 </tr>
		 
		 <tr>
		  <td>UUA</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[8]</td>
		  <td>$ratios{UUA}</td>
		  <td>UCA</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[9]</td>
		  <td>$ratios{UCA}</td>
		  <td>UAA</td>
		  <td style="color:red">STOP</td>
		  <td>$all_freq[10]</td>
		  <td>$ratios{UAA}</td>
		  <td>UGA</td>
		  <td style="color:red">STOP</td>
		  <td>$all_freq[11]</td>
		  <td>$ratios{UGA}</td>
		  <th>A</th>
		 </tr>
		 
		 <tr> 
		  <td>UUG</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[12]</td>
		  <td>$ratios{UUG}</td>
		  <td>UCG</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[13]</td>
		  <td>$ratios{UCG}</td>
		  <td>UAG</td>
		  <td style="color:red">STOP</td>
		  <td>$all_freq[14]</td>
		  <td>$ratios{UAG}</td>
		  <td>UGG</td>
		  <td>Trp(V)</td>
		  <td>$all_freq[15]</td>
		  <td>$ratios{UGG}</td>
		  <th>G</th>
		 </tr>
		 
		 <tr>
		  <th rowspan="4">C</th>
		  <td>CUU</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[16]</td>
		  <td>$ratios{CUU}</td>
		  <td>CCU</td>
		  <td>Pro(P)</td>
		  <td>$all_freq[17]</td>
		  <td>$ratios{CCU}</td>
		  <td>CAU</td>
		  <td>His(H)</td>
		  <td>$all_freq[18]</td>
		  <td>$ratios{CAU}</td>
		  <td>CGU</td>
		  <td>Arg(A)</td>
		  <td>$all_freq[19]</td>
		  <td>$ratios{CGU}</td>
		  <th>U</th>
		 </tr>
		 
		 <tr>
		  <td>CUC</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[20]</td>
		  <td>$ratios{CUC}</td>
		  <td>CCC</td>
		  <td>Pro(P)</td>
		  <td>$all_freq[21]</td>
		  <td>$ratios{CCC}</td>
		  <td>CAC</td>
		  <td>His(H)</td>
		  <td>$all_freq[22]</td>
		  <td>$ratios{CAC}</td>
		  <td>CGC</td>
		  <td>Arg(A)</td>
		  <td>$all_freq[23]</td>
		  <td>$ratios{CGC}</td>
		  <th>C</th>
		 </tr>
		 
		 
		 <tr>
		  <td>CUA</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[24]</td>
		  <td>$ratios{CUA}</td>
		  <td>CCA</td>
		  <td>Pro(P)</td>
		  <td>$all_freq[25]</td>
		  <td>$ratios{CCA}</td>
		  <td>CAA</td>
		  <td>Gln(Q)</td>
		  <td>$all_freq[26]</td>
		  <td>$ratios{CAA}</td>
		  <td>CGA</td>
		  <td>Arg(A)</td>
		  <td>$all_freq[27]</td>
		  <td>$ratios{CGA}</td>
		  <th>A</th>
		 </tr>
		 
		 <tr> 
		  <td>CUG</td>
		  <td>Leu(L)</td>
		  <td>$all_freq[28]</td>
		  <td>$ratios{CUG}</td>
		  <td>CCG</td>
		  <td>Pro(P)</td>
		  <td>$all_freq[29]</td>
		  <td>$ratios{CCG}</td>
		  <td>CAG</td>
		  <td>Gln(Q)</td>
		  <td>$all_freq[30]</td>
		  <td>$ratios{CAG}</td>
		  <td>CGG</td>
		  <td>Arg(A)</td>
		  <td>$all_freq[31]</td>
		  <td>$ratios{CGG}</td>
		  <th>G</th>
		 </tr>
		 
		 <tr>
		  <th rowspan="4">A</th>
		  <td>AUU</td>
		  <td>Ile(I)</td>
		  <td>$all_freq[32]</td>
		  <td>$ratios{AUU}</td>
		  <td>ACU</td>
		  <td>Thr(T)</td>
		  <td>$all_freq[33]</td>
		  <td>$ratios{ACU}</td>
		  <td>AAU</td>
		  <td>Asn(N)</td>
		  <td>$all_freq[34]</td>
		  <td>$ratios{AAU}</td>
		  <td>AGU</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[35]</td>
		  <td>$ratios{AGU}</td>
		  <th>U</th>
		 </tr>
		 
		 <tr>
		  <td>AUC</td>
		  <td>Ile(I)</td>
		  <td>$all_freq[36]</td>
		  <td>$ratios{AUC}</td>
		  <td>ACC</td>
		  <td>Thr(T)</td>
		  <td>$all_freq[37]</td>
		  <td>$ratios{ACC}</td>
		  <td>AAC</td>
		  <td>Asn(N)</td>
		  <td>$all_freq[38]</td>
		  <td>$ratios{AAC}</td>
		  <td>AGC</td>
		  <td>Ser(S)</td>
		  <td>$all_freq[39]</td>
		  <td>$ratios{AGC}</td>
		  <th>C</th>
		 </tr>
		 
		 <tr>
		  <td>AUA</td>
		  <td>Ile(I)</td>
		  <td>$all_freq[40]</td>
		  <td>$ratios{AUA}</td>
		  <td>ACA</td>
		  <td>Thr(T)</td>
		  <td>$all_freq[41]</td>
		  <td>$ratios{ACA}</td>
		  <td>AAA</td>
		  <td>Lys(K)</td>
		  <td>$all_freq[42]</td>
		  <td>$ratios{AAA}</td>
		  <td>AGA</td>
		  <td>Arg(R)</td>
		  <td>$all_freq[43]</td>
		  <td>$ratios{AGA}</td>
		  <th>A</th>
		 </tr>
		 
		 <tr> 
		  <td>AUG</td>
		  <td style="color:green">Met(M)</td>
		  <td>$all_freq[44]</td>
		  <td>$ratios{AUG}</td>
		  <td>ACG</td>
		  <td>Thr(T)</td>
		  <td>$all_freq[45]</td>
		  <td>$ratios{ACG}</td>
		  <td>AAG</td>
		  <td>Lys(K)</td>
		  <td>$all_freq[46]</td>
		  <td>$ratios{AAG}</td>
		  <td>AGG</td>
		  <td>Arg(R)</td>
		  <td>$all_freq[47]</td>
		  <td>$ratios{AGG}</td>
		  <th>G</th>
		 </tr>
		 
		 <tr>
		  <th rowspan="4">G</th>
		  <td>GUU</td>
		  <td>Val(V)</td>
		  <td>$all_freq[48]</td>
		  <td>$ratios{GUU}</td>
		  <td>GCU</td>
		  <td>Ala(A)</td>
		  <td>$all_freq[49]</td>
		  <td>$ratios{GCU}</td>
		  <td>GAU</td>
		  <td>Asp(D)</td>
		  <td>$all_freq[50]</td>
		  <td>$ratios{GAU}</td>
		  <td>GGU</td>
		  <td>Gly(G)</td>
		  <td>$all_freq[51]</td>
		  <td>$ratios{GGU}</td>
		  <th>U</th>
		 </tr>
		 
		 <tr>
		  <td>GUC</td>
		  <td>Val(V)</td>
		  <td>$all_freq[52]</td>
		  <td>$ratios{GUC}</td>
		  <td>GCC</td>
		  <td>Ala(A)</td>
		  <td>$all_freq[53]</td>
		  <td>$ratios{GCC}</td>
		  <td>GAC</td>
		  <td>Asp(D)</td>
		  <td>$all_freq[54]</td>
		  <td>$ratios{GAC}</td>
		  <td>GGC</td>
		  <td>Gly(G)</td>
		  <td>$all_freq[55]</td>
		  <td>$ratios{GGC}</td>
		  <th>C</th>
		 </tr>
		 
		 <tr>
		  <td>GUA</td>
		  <td>Val(V)</td>
		  <td>$all_freq[56]</td>
		  <td>$ratios{GUA}</td>
		  <td>GCA</td>
		  <td>Ala(A)</td>
		  <td>$all_freq[57]</td>
		  <td>$ratios{GCA}</td>
		  <td>GAA</td>
		  <td>Glu(E)</td>
		  <td>$all_freq[58]</td>
		  <td>$ratios{GAA}</td>
		  <td>GGA</td>
		  <td>Gly(G)</td>
		  <td>$all_freq[59]</td>
		  <td>$ratios{GGA}</td>
		  <th>A</th>
		 </tr>
		 
		 <tr> 
		  <td>GUG</td>
		  <td>Val(V)</td>
		  <td>$all_freq[60]</td>
		  <td>$ratios{GUG}</td>
		  <td>GCG</td>
		  <td>Ala(A)</td>
		  <td>$all_freq[61]</td>
		  <td>$ratios{GCG}</td>
		  <td>GAG</td>
		  <td>Glu(E)</td>
		  <td>$all_freq[62]</td>
		  <td>$ratios{GAG}</td>
		  <td>GGG</td>
		  <td>Gly(G)</td>
		  <td>$all_freq[63]</td>
		  <td>$ratios{GGG}</td>
		  <th>G</th>
		 </tr>
		 

    	<tr>
    	 <th></th>
		 <th colspan="4">U</th>
		 <th colspan="4">C</th>
		 <th colspan="4">A</th>
		 <th colspan="4">G</th>
   		 <th></th>
		</tr>	
	</table>
		
		<p style="font-size:12px">% represents the average frequency this codon is used per 100 codons<br />
		Ratio represents the abundance of that codon relative to all of the codons for that particular amino acid</p>
    	
    	<div id="footer" style="background:#404853; background:linear-gradient(#687587,#404853); color:#fff;">
    	<p>Copyright © 2014 Kaileigh, Maria and Micheal</p></div>
	
	</body>

</html>

EOF
