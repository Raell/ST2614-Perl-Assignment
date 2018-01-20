#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;

#Name: Cheong Ren Hann
#Admin No: 1230068
#Class: DISM/FT/2A/02

my $currDirectory = getcwd(); #set default directory
my $output = "t"; #sets default output
my $sort = "n"; #sets default sorting

if(($#ARGV + 1)) { #check for any switches
    switchhandle();
}

my @readfiles;

directorycheck($currDirectory);

my @email;

foreach my $file(@readfiles) {
    readfile($file);
}

emailduplicate();

output();

sub directorycheck { #recursive function to check for html files in directories

    my $directory = shift; #receive argument
    opendir(DIR, $directory) or die "Unable to open directory.\n";

    my @files = grep {!/^\.{1,2}$/} readdir (DIR); #saves directory contents
                                                   #to array while removing
                                                   #filenames '.' and '..'
    
    closedir (DIR);
    
    foreach my $file(@files) {

	my $filepath = "$directory/$file";
	
	if(-d $filepath) { #check if file is a directory
	    directorycheck ($filepath);
	}

	elsif($filepath =~ m/\.html?$/) {
	    push (@readfiles, $filepath);
	}
	
    }
    
}

sub switchhandle {

    my $d = 1; #use to check if switches were previously declared
    my $f = 1;
    my $s = 1;
    
    for(my $i = 0; $i <= $#ARGV; $i++) {
	
	if($ARGV[$i] eq "-h") { #-h switch prints usage help
	    print "Usage: {file name} [switches]\n";
	    print "\t-dpath    directory to search for html files (default: .)\n";
	    print "\t-f[th]    output in text or html mode (default: text)\n";
	    print "\t-h        print this message and exit\n";
	    print "\t-s[adn]   sort in ascending, descending or none (default: none)\n";
	    print "\t-v        print version and exit\n";
	    exit;
	}

	elsif($ARGV[$i] eq "-v") { #-v switch prints version info
	    print "**************************************************************************\n";
	    print "ST2614 Assignment 1, Ver. 1.0 done by Cheong Ren Hann p1230068 class 2A/02\n";
	    print "**************************************************************************\n";
	    exit;
	}

	elsif($ARGV[$i] =~ /^-d/) { #checks for -d switch in front  
	    unless($d) { #prevents duplicate switches
		duplicate();
	    }
	    
	    $d = 0;
	    
	    my $dir = $ARGV[$i]; #saves the switch
	    $dir =~ s/^-d//; #removes the -d from pathname

	    if($dir eq "") { #if no path was specified, exit
		print "No directory path specified.\n";
		exit;
	    }
	    elsif($dir !~ /^\//) { #checks if path is relative
		$currDirectory = getcwd(). "/$dir";
	    }
	    else { #saves absolute path to open
		$currDirectory = $dir;
	    }
	}

	elsif($ARGV[$i] =~ /^-f[th]?$/) { #checks for -f switch
	    unless($f) { #prevents duplicate switches
		duplicate();
	    }
	    
	    $f = 0;
	    
	    if($ARGV[$i] =~ /h/) { #checks for -fh switch
		$output = "h"; #sets output to html
	    }
		
	}

	elsif($ARGV[$i] =~ /^-s[adn]?$/) { #checks for -s switch
	    unless($s) { #prevents duplicate switches
		duplicate();
	    }
	    
	    $s = 0;

	    if($ARGV[$i] =~ /a/) { #checks for -sa switch
		$sort = "a"; #sets sorting to ascending
	    }

	    elsif($ARGV[$i] =~ /d/) { #checks for -sd switch
		$sort = "d"; #sets sorting to descending
	    }
	    
	}
	
	else {
	    print "Unrecognized switch, enter -h for usage.\n";
	    exit;
	}
	
    }

}

sub duplicate { #executes when duplicate switches detected
    print "Duplicate switch.\n";
    exit;
}

sub readfile { #read the file from the argument given

    my $filename = shift;
    open FILE, $filename or die "Unable to read file.\n";

    #regex to match email address
    my $emailregex = qr/[a-zA-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;

    while(<FILE>) { #view the file line by line

	while($_ =~ /($emailregex)/g) {
	    push(@email, $1); #pushes the email string from the line to an array
	}
       
    }

    close(FILE); #close the file
   
}

sub emailduplicate { #checks for duplicate emails
    
    my %hash = map { $_ => 1 } @email;
    @email = keys %hash;
    
}

sub output { #handles output of program

    if($output eq "h") { #exports to html file
	sorting();

	my $htmlfile = "output.html";

	open FILE, ">$htmlfile" or die "Unable to output file";

	print FILE "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html><head><title>Emails</title></head><body><h3>Emails</h3><table>";
	print "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n<html>\n<head>\n<title>Emails</title>\n</head>\n<body>\n<h3>Emails</h3>\n<table>\n";
	foreach my $line (@email) { #writes email to the file line by line

	    print FILE "<tr><td><a href='mailto:$line'>$line</a><br /></td></tr>";
	    print "<tr>\n<td><a href='mailto:$line'>$line</a><br /></td>\n</tr>\n";
	    
	}
	print FILE "</table></body></html>";
	print "</table>\n</body>\n</html>\n";
	close(FILE);
	
    }

    else { #exports to text
	sorting();
	foreach my $line (@email) {
	    print "$line\n";
	}
	
    }

}

sub sorting { #sorts the email array

    if($sort ne "n") {
	
	@email = sort @email;

	if($sort eq "d") {
	    @email = reverse (@email);
	}
		
    }
    
}
