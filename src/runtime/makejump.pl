#! /usr/bin/env perl -i
#
# This Perl script munges the assembly code output by the compiler to replace
# a subroutine jsr with a jump.
#

$processor = "m68k";		# Changed if we see an Intel instruction

while (<>) {
    if (/^(_[_a-zA-Z][_a-zA-Z0-9]*):$/) {
	$routine_name = $1;	# Read the subroutine name
    }

    $processor = "i386" if /pushl %ebp/;

    if ($processor eq "m68k" && /link a6/ && $routine_name =~ /^__msgS/) {
	#
	# Collect the registers pushed onto the stack so we can pop them
	# off when it comes time to jump to the method we've found.
	#
	print;			# Print the current line
	@reg_stack = ();
	@move_stack = ();
	while (<>) {
	    last if !/sp@-$/;
	    $reg = $_;
	    chop($reg);
	    $move = $reg;
	    $move =~ s/.*move([a-z]*) .*,sp@-/$1/;
	    if ($move eq "ml") {# $reg is actually register mask
		$reg =~ s/.*move[a-z]*\s*#(.*),sp@-/$1/;
	    }
	    else {
		$reg =~ s/.*move[a-z]*\s*(.*),sp@-/$1/;
	    }
	    push(@reg_stack, $reg);
	    push(@move_stack, $move);
	    print;
	}
    }

    if (($processor eq "m68k" && /jbsr a[012]@/) ||
	($processor eq "i386" && /call \*%ebx/)) {
	#
	# Here we go. This is a KLUGE, since I don't really know how to
	# identify *which* jbsr is the one we want.
	#

	if ($processor eq "m68k") {
	    print <<EOF;
#
# What used to be a subroutine call is now turned into a jump
# (after cleaning up the stack).
#
EOF
	}
	if ($processor eq "m68k") {
	    # Collect the register number
	    $addr_reg_num = $_;
	    chop($addr_reg_num);
	    $addr_reg_num =~ s/.*jbsr a([012])@.*/$1/;

	    # Save that register into d0
	    print "\tmovel a$addr_reg_num,d0\t" .
		"# save register into d0\n";

	    if ($routine_name eq "__msgSuper") {
		#
		# Do "context = context->reciever". This replaces one of the
		# arguments on the stack.
		#
		print "\tmovel a6@(8),a$addr_reg_num\t" .
		    "# context = context->reciever\n";
		print "\tmovel a$addr_reg_num@,a6@(8)\n";
	    }

	    #
	    # Pop the registers that were saved at the beginning of the routine
	    #
	    @working_reg_stack = @reg_stack;
	    @working_move_stack = @move_stack;
	    while ($reg = pop(@working_reg_stack)) {
		$move = pop(@working_move_stack);
		if ($move eq "ml") {# reverse bits of register mask
		    $reg = &reverse_bits(oct($reg));
		    printf "\tmove%s sp@+,#0x%x\n", $move, $reg;
		}
		else {
		    print "\tmove$move sp@+,$reg\n";
		}
		print "\t# pop saved registers\n";
	    }

	    print "\tunlk a6\n";
	    print "\tmovel d0,a0\n";# Restore our jump register
	    s/jbsr a([0-9])@/jmp a0@/;# Prepare to jump@!
	}
	else {			# Processor is i386
	    if ($routine_name eq "__msgSuper") {
		#
		# Do "context = context->reciever". This replaces one of the
		# arguments on the stack.
		#
		print <<EOF;
	movl 8(%ebp),%eax
	movl (%eax),%ecx
	movl %ecx,8(%ebp)
EOF
	    }

	    print <<EOF;
	movl %ebx,%eax
	leal -12(%ebp),%esp
	popl %ebx
	popl %esi
	popl %edi
	movl %ebp,%esp
	popl %ebp
EOF
	    s/call \*%ebx/jmp *%eax/;
	}

    }
    print;
}

sub reverse_bits
{
    local($reg) = @_;
    local($result, $power);

    $result = 0;
    $power = 2 ** 15;
    while ($reg) {
	$result += $power if ($reg & 1);
	$reg /= 2;
	$power /= 2;
    }
    return $result;
}
