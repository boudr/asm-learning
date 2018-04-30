.section .data

.section .text
.global _start
_start:
	pushl $5	#Argument
	call factorial	#Fun call

	movl %eax, %ebx

	movl $1, %eax
	int $0x80

#Fucntion: Get the factorial of givin number
#Arguments:
#	8(%ebp) - Number to get the factorials

#Variables
#	-4(%ebp)- Local variable for the result
#	eax- Recursive call to function and return value
#	ebx- Temporary use for muliplication 
.type factorial,@function
factorial:
	pushl %ebp		#Push EBP to stack
	movl %esp, %ebp		#Make base pointer current stack pointer
	
	movl 8(%ebp), %eax	#Move the argument into Result

	cmpl $1, %eax		#Is it one?
	je factorial_end	#Yes then end

	decl %eax		#Move the factor number down. Example:
				#Factorial = (Factorial - 1) * Factorial
	pushl %eax		#Push (Factorial - 1)
	call factorial		#Call (Factorial - 1)
	movl 8(%ebp), %ebx	#Move Calling argument to ebx as eax holds the return of the call

	imull %ebx, %eax	#(Factorial - 1) * Factorial

#Cleaning
factorial_end:
	movl %ebp, %esp
	pop %ebp
	ret
