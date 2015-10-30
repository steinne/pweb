#! /usr/bin/perl -w
use strict;
use Digest::MD5 qw(md5_base64);
my $digest = Digest::MD5->new;
my $file_drop_down = "<option value='.'>This</option>" ;

     print  "HTTP/1.1 200 OK\n";
     print  "Content-type: text/html\n\n";
     print  "<html><title>$ENV{SERVER_SOFTWARE}</title><body>";
     print  " <h3>Please select the directory to obtain file checksums.</h3><form method='POST' action=checksum.pl>
     <select name='directory'>$file_drop_down</select></select> &nbsp;&nbsp; <input type='submit' name='submit' value='checksum' /></form>";

my ($buffer,@pairs,$pair,$name, $value,%FORM);
if ($ENV{REQUEST_METHOD} eq "POST"){
           read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
           @pairs = split(/&/, $buffer);
           foreach $pair (@pairs) {
               ($name, $value) = split(/=/, $pair);
               $value =~ tr/+/ /;
               $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
               $FORM{$name} = $value;
           }
	foreach my $dirname ($FORM{"directory"}) {
    	chomp ($dirname);
    	$dirname = trimall($dirname);
    	if (! -d $dirname) {
    		print "$dirname is not directory \n";
    		next;
    	} elsif (! -r $dirname) {
    	print "$dirname is not readable. \n";
    	next;
    	}
    	processfiles($dirname);
	}
}
print "</body</html>";

sub processfiles
{
    use Cwd 'abs_path';
    #my $dirname = $_[0];
    my $dirname = abs_path($_[0]);
    chomp ($dirname);
    opendir(DIRH, $dirname);

    my @files = sort (grep { !/^\.|\.\.}$/ } readdir (DIRH));
    closedir(DIRH);
    my $file;
    foreach $file (@files) {
    my $fullpath = $dirname . "/" . $file;
    print "\n<br> $fullpath" unless(-d $fullpath);
    if (-d "$fullpath") {
        processfiles("$fullpath");
    } else {
        print "\t&nbsp&nbsp&nbsp" . getmd5checksum ("$fullpath");
    }
    }
    return 0;
}


sub getmd5checksum
{
    my $file = shift;
    if (! -r $file) {
    return "Not readable";
    } else {
    open (FILE, $file) or return"";
    $digest->reset();
    $digest->addfile(*FILE);
    close (FILE);
    return $digest->hexdigest;
    }
}

sub trimall
{
    my $arg = shift;
    $arg =~ s/^\s+|\s+$//g;
    return $arg;
}
