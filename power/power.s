.section .data

.section .text
.global _start

_start:
	pushl $2	#Push the second argument to the stack
	pushl $6	#Push the first argument to the stack
	call power	#Call the function

	movl %eax, %ebx

	movl $1, %eax	#exit interupt
	int $0x80

#This function will compute the value of a number raised to a power.

#INPUT:
#	First Argument - the base number
#	Second Argument - the power to raise it to

#OUTPUT: Will give the result as a return value

#Variables:
#	%eax - Holds the base power
#	%ebx - Holds the power
#	%ecx - Hold the temp current result
#	-4(%ebp) - holds the current result
.type power,@function
power:
	pushl %ebp		#Push old EBP to stack
	movl %esp, %ebp		#Move ESP to EBP
	subl $4, %esp		#Local variable

	movl 8(%ebp), %eax	#First Argument
	movl 12(%ebp), %ebx	#Second argument

	movl %eax, -4(%ebp)	#Store the current base in EBP

power_loop:
	cmpl $1, %ebx		#If the power is one, we are done
	je end_power_loop

	movl -4(%ebp), %ecx	#Grab cur result
	imull %eax, %ecx	#Multiply the base by the current result
	movl %ecx, -4(%ebp)	#Move current result back to stack

	decl %ebx		#Deinc the power
	jmp power_loop		#Repeate

end_power_loop:
	movl -4(%ebp), %eax	#Store the result in eax
	movl %ebp, %esp		#Restore the ESP to base
	popl %ebp		#Restore the old ebp
	ret			#Return
