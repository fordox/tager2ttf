#!did-you-know-that-you-can-put-anything-here-if-it-has-perl-in-it?

use strict;
#don't use warnings;
use GD;
use Data::Dumper;
use File::Basename;

my $howmanyargvs = @ARGV;

print "This is tagerpng2fon, Version 0.3: ";
#print "(cc) 2015 Kamil J. Dudek\n";

if ( $howmanyargvs != 2)
{
	print "Usage: perl tagerpng2fon.perl pngfile typeface\n";
	print "pngfile    Path to the PNG printer output from TAGer font editor.\n";
	print "typeface   Supported typefaces: Regular, Italics, Bold, Underline\n";
	exit -1;
}
if ( ($ARGV[1] ne "Regular") && ($ARGV[1] ne "Italics") && ($ARGV[1] ne "Bold") && ($ARGV[1] ne "Underline") )
{
	print $ARGV[1]. " is not one of the supported typefaces: Regular, Italics, Bold, Underline\n";
	exit -2;
}
if ( ! (-d "./FON") )
{
	system("mkdir ./FON");
}
if ( ! (-d "./FD") )
{
	system("mkdir ./FD");
}
if ( ! (-d "./TTF") )
{
	system("mkdir ./TTF");
}


my $img = GD::Image->newFromPng( $ARGV[ 0 ] );
my $fontname = basename($ARGV[0]);
$fontname =~ s/^(.*)(\.)(.*)$/$1/;
my $realfontname = $fontname . " " . $ARGV[1];
my $outputname = './FD/'.$realfontname.'.fd';
open(my $filehandler, '>', $outputname) or die "Problem with: '$outputname' $!";
print $filehandler "facename TAG ", $realfontname, "\n";
print $filehandler "copyright 1988-1996 InfoService\n";
print $filehandler "\nheight 48\nascent 11\n\ncharset 255\n\nchar 0\nwidth 36\n";
print "Creating font $realfontname...   ";
my $fjump = 0;
if ($ARGV[ 1 ] eq "Regular")
{
	$fjump = 0;
}
if ($ARGV[ 1 ] eq "Italics")
{
	$fjump = 1;
}
if ($ARGV[ 1 ] eq "Bold")
{
	$fjump = 2;
}
if ($ARGV[ 1 ] eq "Underline")
{
	$fjump = 3;
}

my $alignY = 0 + (360 * $fjump);
my $characterNO = 32;
my @alphabetsoup;
my @inputfont;
$alphabetsoup[256][48][36] = "";
$inputfont[256] = "";

for (my $row = 0; $row < 4; $row = $row + 1 )
{
	my $alignX = 1;
	for (my $column = 0; $column < 64; $column = $column + 1 )
	{
		for( my $i = 0 + $alignY; $i < 48 + $alignY; $i = $i + 1 )
		{
			for( my $j = 0 + $alignX; $j < 36 + $alignX; $j = $j + 1 )
			{
		    		my $ind = $img->getPixel($j,$i);
				if ($ind == 0)
				{
					my $one = 1;
					$alphabetsoup[$characterNO][$i - $alignY][$j - $alignX] = "1";
					$inputfont[$characterNO] = $inputfont[$characterNO] . "1";
				}
				else
				{
					$alphabetsoup[$characterNO][$i - $alignY][$j - $alignX] = "0";
					$inputfont[$characterNO] = $inputfont[$characterNO] . "0";
				}
			}
			$inputfont[$characterNO] = $inputfont[$characterNO] . "\n";
		}
		$alignX = $alignX + 36;
		$characterNO += 1;
		if ($characterNO == 256)
		{
			$characterNO = 0;
		}

	}
	$alignY = $alignY + 72;
}

my @outputfont;
$outputfont[256] = "";

$characterNO = 0;


for (my $column = 0; $column < 256; $column = $column + 1 )
{
	print $filehandler $inputfont[$characterNO];
	$characterNO += 1;
	if ($characterNO < 256)
	{
		print $filehandler "\n", "char ", $characterNO, "\n", "width 36\n";
	}
}

if ( !( -e "./mkwinfont.py") )
{
	print "Getting mkwinfont from Simon Tatham's Fonts Page...\n";
	system("wget www.chiark.greenend.org.uk\/\~sgtatham\/fonts\/mkwinfont -q -O .\/mkwinfont.py");
}

system("python ./mkwinfont.py -fon -o \"./FON/$realfontname.fon\" \"$outputname\" ");
system("fontforge -script ./mkbdf.pe \"./FON/$realfontname.fon\" 2> /dev/null");
my $bidoof = `ls ./FON/*.bdf`;
chomp($bidoof);
system("fontforge -script ./mkttf.pe \"./$bidoof\" 2> /dev/null");
system("rm -f ./FON/*.bdf");
system("mv ./FON/*.ttf ./TTF");
print " Done.\n";
