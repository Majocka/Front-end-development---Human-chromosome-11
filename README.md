# Front-end-development---Human-chromosome-11

I wrote this website for the Biocomputing II project whilst doing my MSc Bioninformatics. The website lives on http://student.cryst.bbk.ac.uk/~bm002/webPage1.html

Unfortunately, it is not functional anymore as files on the server have been moved around and I do not have permission for the access anymore. Therefore, I set up this repository here to show at least the coding that I as the front-end-developer did behind this website. All the files present here are all my and only my work (except a small section that was writen by my friend Micheal in webPage3.pl as indicated within the file).

The website was built to view and search around the genetic content of human chromosome 11. It shows the DNA and amino acid sequences of the coding or non-coding regions. One can also view the codon usage frequency within the coding regions and to identify the sticky-end restriction enzyme sites for three different enzymes.

Whilst doing it I learned implementation of cgi and dbi; and especially enjoyed incorporating JQuery within my html file.

For more detail on what the website was doing:
It enables the user to search for a gene on the chromosome. The submit button will trigger opening either of the two pages:
webPage2.pl that shows the gene summary; or errorReport.pl that brings up an error message if the search term cannot be found in our database. On webpage2.pl there is a link to webPage3.pl, which will brings up more detailed information about the particular gene.
There also is ourstyle.css file with all the formatting necessary for the website. Both css and html file were validated as shown by the link on the webpage.
