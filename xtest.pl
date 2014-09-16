#!/usr/bin/perl
# Small X11 script and wrapper for a coupld of things
# JayGe

use X11::Protocol;
use Getopt::Std;
getopts("d:k:s:f:iml");

use vars qw($opt_d $opt_f $opt_k $opt_s $opt_i $opt_m $opt_l);

my $display = $opt_d || $ENV{"DISPLAY"} || ":0.0"; 

my $x = X11::Protocol->new($display) || die "No authority: ";

if ($opt_i) # Server Information option
{
sleep 2;
	print "Vendor: " . $x->vendor . "\n";
	print "Version: " . $x->release_number . "\n";
	print "Res: " . $x->width_in_pixels . " x " .  $x->height_in_pixels . "\n\n"; 
	my ($mode, @hosts) = $x->ListHosts;
	foreach (@hosts)
	{
	    print "Allowed Hosts: $_->[0] ", join(".", unpack("C4", $_->[1])), "\n";
	}
	
	printf ("\nCurrently focused Window: 0x%x (%s)\n\n", $x->GetInputFocus, $x->GetInputFocus);
}

elsif ($opt_m) # Move pointer option
{
	while ()
	{
		printf ("Currently focused Window: 0x%x\n", $x->GetInputFocus);

		printf("X-shift: ");
		my $xco = <STDIN>;
		printf("Y-shift: ");
		my $yco = <STDIN>;

		$x->req('WarpPointer', 'None', 0, 0, 0, 0, 0, $xco, $yco);
	}
}

elsif ($opt_s) # Screen shot option, wrapper to xwd
{
	print("Screenshot using xwd\n");
	system("/usr/bin/xwd -display $display -root > $opt_s");
}

elsif ($opt_l) # List windows option
{
	print "Listing Parent Windows: \n";
	pre_walk($x->root);
}

elsif ($opt_k) # Kill the window
{
	print("Killing $opt_k\n");
	$x->SetInputFocus(hex($opt_k));
	$x->DestroyWindow(hex($opt_k));
}

elsif ($opt_f) # Focus the window
{
	print("Setting input focus to $opt_k\n");
	$x->SetInputFocus(hex($opt_k));
}

else
{
	print("xtest.pl 0.1 usage:\n\n");
	print("  -d <displayname> Uses \$DISPLAY or :0.0 if none specified\n");
	print("  -k <windowid> In hex to kill\n");
	print("  -l List Windows\n");
	print("  -f <windowid> In hex to focus input on\n");
	print("  -i Server Information\n");
	print("  -m Move Pointer\n");
	print("  -s <tofilename> Take Screencapture using xwd\n");
	exit(0);
}

sub pre_walk { # list windows taken from wintree.pl example
	my $win = shift;
	my($root, $dad, @kids) = $x->QueryTree($win);

	my $xxx= ($x->GetProperty($win, $x->atom("WM_COMMAND"),
                            $x->atom("STRING"), 0, 65535, 0))[0];

	my @argv = split(/\0/, $xxx);
	my $cmd = $argv[0];
	printf ("0x%x %s\n", $win, $cmd) if $cmd ne "";

	map(pre_walk($_), @kids);
}

