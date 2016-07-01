#!/usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser); 
use lib "/d/user5/bm002/WWW/cgi-bin/lib"; 
use moduleNew;

my $cgi = new CGI;
my $query = $cgi->param('Search');
my $dbh = moduleNew::ConnectToDatabase();

my $gene_identifier = moduleNew::GetGeneIdentifier($query, $dbh);
if (defined $gene_identifier){ 		# if it is found in database, will bring up webPage3.pl
    print $cgi->header();
}
else{ 							# else, will bring up errorReport.pl
    print $cgi->header(-location => "http://student.cryst.bbk.ac.uk/cgi-bin/cgiwrap/bm002/errorReport.pl?search=$query");
}

my $prot_pro_name = moduleNew::GetProteinProductName($query, $dbh);
my $acc_number = moduleNew::GetAccessionID($query, $dbh);
my $chrom_loc = moduleNew::GetChromosomalLocation($query, $dbh);

print <<__EOF;

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
	<head>
		<meta http-equiv="Content-Type" content="text/html"/>
		<title>Our second page</title>
		<meta name="gene description" content="Summary info on gene identifiers"/>
		<meta name="author" content="Maria Boznakova"/>
		<link rel="stylesheet" type="text/css" href="http://student.cryst.bbk.ac.uk/~bm002/stylesheets/ourstyle.css"/>
		
		<style type="text/css">
		 table{
		 width:600px;
		 }
		 th{
		 width:140px;
		 }
		</style>
	</head>

	<body>
    <div id="wrapper">
<div id="header">
		<img src="http://upload.wikimedia.org/wikipedia/commons/c/cf/Chromosome_11.svg" alt="error in displaying" height='600' width='200' style='float:right'/>
	
		<p>You searched on <strong><a href="http://student.cryst.bbk.ac.uk/cgi-bin/cgiwrap/bm002/webPage3.pl?search=$query">$query</a></strong>. The summary information on your gene can be found below. If the information is not available it will be classified as 'not listed'.</p></div><br />

		<table>		
		 <tr>
		  <th colspan="2">Summary</th>		  
		  </tr>
		  
		 <tr>
		  <th>Gene identifiers</th>
		  <td>$gene_identifier</td>
		 </tr>
		 
		 <tr>
		  <th>Protein product names</th>
		  <td>$prot_pro_name</td>
		 </tr>
		 
		 <tr>
		  <th>Genbank accession</th>
		  <td>$acc_number</td>
		 </tr>
		 
		 <tr>
		  <th>Chromosomal location</th>
		  <td>$chrom_loc</td>
		 </tr>		 
		</table><br />

		<!-- images to prove the validation of html and css	-->		
		<p>
		<a href="http://jigsaw.w3.org/css-validator/check/referer">
        <img style="border:0;width:88px;height:31px"
            src="http://jigsaw.w3.org/css-validator/images/vcss"
            alt="Valid CSS!" /></a></p>
		
		<p>
    	<a href="http://validator.w3.org/check?uri=referer"><img
      		src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="31" width="88" /></a></p>
    </div>

	<div id="push"></div>

    <div id="bottom">
    <div id="footer" style="background:#404853; background:linear-gradient(#687587,#404853); color:#fff;">Copyright 2014 © Kayleigh, Maria an Micheal</div></div>



    </body>
</html>

__EOF
