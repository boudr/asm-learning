#PURPOSE:	This program will convert lowercase to uppercase in a file

#PROCESSING:	1) Open the input file
#		2) Open the output file
#		3) While we're not at the end of the input file:
#			a) read part of file into memory buffer
#			b) go through each byte of memory
#				if the byte is a lower-case letter,
#				convert it to upppercase
#			c) wrtie the memory buffer to output file
.section .data

########CONSTANTS########

#System call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

#Operations for open (look at /usr/include/asm/fcntl.h
#for various values. You can combine them
#by addint them or ORing them)
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

#Standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

#System call intterupt
.equ LINUX_SYSCALL, 0x80

.equ END_OF_FILE, 0 	#This is the return value of read 
			#which means we've hit the end of the file

.equ NUM_ARGUMENTS, 2

.section .bss
#Buffer - this is where the data is loaded into
#	from the data file and written from
#	into the output file. This should
#	never exceed 16,000 for various reasons.
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
#Stack positions
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0		#Number of arguments
.equ ST_ARGV_0, 4	#Name of program
.equ ST_ARGV_1, 8	#Input file name
.equ ST_ARGV_2, 12	#Output file name

.global _start
_start:
	#Save the stack pointer
	movl %esp, %ebp

	#Allocate space for out file descriptors on the stack
	subl $ST_SIZE_RESERVE, %esp

open_files:
open_fd_in:
	#Open Input Files
	#Open syscall
	movl $SYS_OPEN, %eax

	#Input filename into ebx
	movl ST_ARGV_1(%ebp), %ebx

	#Read only flag
	movl $O_RDONLY, %ecx

	#Permissions, doesn't matter for reading..
	movl $0666, %edx

	int $LINUX_SYSCALL
store_fd_in:
	#Save the given file descriptor
	movl %eax, ST_FD_IN(%ebp)

open_fd_out:
	#Open output file
	movl $SYS_OPEN, %eax

	#Output filename
	movl ST_ARGV_2(%ebp), %ebx

	#Flags for writing to the file
	movl $O_CREAT_WRONLY_TRUNC, %ecx

	#Mode for new file
	movl $0666, %edx

	int $LINUX_SYSCALL
store_fd_out:
	#Store the file descriptor here
	movl %eax, ST_FD_OUT(%ebp)

read_loop_begin:
	#Read in a block from the input file
	movl $SYS_READ, %eax

	#Get the input file descriptor
	movl ST_FD_IN(%ebp), %ebx

	#Location of buffer to read into
	movl $BUFFER_DATA, %ecx

	#Buffer size
	movl $BUFFER_SIZE, %edx

	#syscall
	int $LINUX_SYSCALL

	cmpl $END_OF_FILE, %eax
	jle end_loop

cont_read_loop:
	#Convert the block to uppercase
	pushl $BUFFER_DATA
	pushl %eax
	call convert_to_upper
	popl %eax
	addl $4, %esp

	#Size of the buffer
	movl %eax, %edx
	movl $SYS_WRITE, %eax

	#File to use
	movl ST_FD_OUT(%ebp), %ebx

	#Location of the buffer
	movl $BUFFER_DATA, %ecx
	int $LINUX_SYSCALL

	jmp read_loop_begin

end_loop:
	#Close the files
	movl $SYS_CLOSE, %eax
	movl ST_FD_OUT(%ebp), %ebx
	int $LINUX_SYSCALL

	movl $SYS_CLOSE, %eax
	movl ST_FD_IN(%ebp), %ebx
	int $LINUX_SYSCALL

	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL

#This function does the conversion
###Constants###
.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'

#Conversion between upper and lower.
.equ UPPER_CONVERSION, 'A' - 'a'

###Stack Stuffs###
.equ ST_BUFFER_LEN, 8	#Length of buffer
.equ ST_BUFFER, 12	#Buffer

convert_to_upper:
	pushl %ebp
	movl %esp, %ebp

	movl ST_BUFFER(%ebp), %eax
	movl ST_BUFFER_LEN(%ebp), %ebx
	movl $0, %edi			#Current buffer offset

	cmpl $0, %ebx
	je end_convert_loop

convert_loop:
	#Get the current byte
	movb (%eax,%edi,1), %cl

	#Go to the next byte unless it is between 'a' and 'z'
	cmpb $LOWERCASE_A, %cl
	jl next_byte
	cmpb $LOWERCASE_Z, %cl
	jg next_byte

	#Otherwise convert the byte to uppercase
	addb $UPPER_CONVERSION, %cl

	#Store it back where it belongs.
	movb %cl, (%eax,%edi,1)

next_byte:
	incl %edi
	cmpl %edi, %ebx
	
	jne convert_loop

end_convert_loop:
	#No return value
	movl %ebp, %esp
	popl %ebp
	ret
