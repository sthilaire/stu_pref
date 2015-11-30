#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp qw/ read_file append_file /;

# Script used to combine code files into a smaller number of
# installation files.

print "Hello.  Let's start creating installation scripts...\n";
print "\n";

# return all files in current directory
# my @files = glob '*.pl'  # explicit glob
# The other is to use angle brackets in the style of the readline  operator:
# my @files = <*.*>;       # angle-bracket glob
# to use a variable for file spec
#@files = <$filespec>;     # ERROR: attempts to read lines
#@files = <${filespec}>;   # ok, but algebraic
#@files = glob $filespec;  # better

# Values used that need to be customized
my $fileSpec = "
../tbl/*_table.sql 
../pkg/*.pks 
../tbl/*_trigger.sql 
../pkg/*.pkb
../data/*.sql
";
# my @files = < ../tbl/*.sql ../pkg/*.pks ../pkg/*.pkb >;
my $fileTargetPrefix = 'z_install_combined_';
my $fileTargetSuffix = '.sql';
my $sizeMAX = 32767;     # MAX size of file


## Parameters used for logic
my @files = glob $fileSpec;
my $file;
my $fileTarget;  #name of target file
my $sizeA;     # size of file
my $sizeB = 0;     # size of file
my @filedata; # details of file
my $counter = 0;  # file name change counter

# foreach $file (@files) {
#     #print "$_ is not a textfile!\n" if !-T;
# 	print $file . "\n";
# };



## remove the first file
$fileTarget = $fileTargetPrefix.$counter.$fileTargetSuffix;
unlink $fileTarget;
print "New Target File: $fileTarget \n";


#@files = <*>;
foreach $file (@files) {
    if (-f $file) {
        # print "This is a file: " . $file . "\n";
        
        $sizeA = -s $file;
        print "Size of $file = $sizeA\n";

        # @filedata = stat $file;
        # print "size of $file by stat is $filedata[7]\n";

        if ($sizeA + $sizeB > $sizeMAX){
          $counter++;	
          $fileTarget = $fileTargetPrefix.$counter.$fileTargetSuffix;
          unlink $fileTarget;
          print "New Target File: $fileTarget \n";
        }

        # File Name
        $fileTarget = $fileTargetPrefix.$counter.$fileTargetSuffix;

        # Append File wo new file name
        append_file($fileTarget, read_file($file));
        
        $sizeB = -s $fileTarget;
        print "Size of $fileTarget = $sizeB\n";        
    }
    if (-d $file) {
        print "This is a directory: " . $file . "\n";
    }
}


print "\n";
print "Last File: $fileTarget\n";
print "OK. Done...\n";