#!/usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser); 

my $cgi = new CGI;
print $cgi->header();
my $query = $cgi->param('search');


print <<EOF;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
	<head>
        <meta http-equiv="Content-Type" content="text/html"/>
		<title>Our error page</title>
		<meta name="gene description" content="Error reporting"/>
		<meta name="author" content="Maria Boznakova"/>
		<link rel="stylesheet" type="text/css" href="http://student.cryst.bbk.ac.uk/~bm002/stylesheets/ourstyle.css"/>		
	</head>
	
<body>
    <div id="wrapper">
    <div id="header">
    <h3>Error message</h3></div>
    <p><strong>'$query'</strong> is not found in our database</p>
<p>
    <a href="http://validator.w3.org/check?uri=referer"><img
      src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Transitional" height="31" width="88" /></a>
  </p>
<p>
    <a href="http://jigsaw.w3.org/css-validator/check/referer">
        <img style="border:0;width:88px;height:31px"
            src="http://jigsaw.w3.org/css-validator/images/vcss"
            alt="Valid CSS!" />
        </a></p>




    <div id="push"></div></div>

    <div id="bottom">
    <div id="footer">


</div></div>

    </body>

</html>

EOF
