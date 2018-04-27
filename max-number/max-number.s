#Variables:
# %edi - index for loop
# %ebx - Largest data found (Storage)
# %eax - Current data

.section .data

data_items:
	.long 3,67,34,222,45,75,54,34,44,33,22,11,66,0 #Zero at the end of list to terminate

.section .text
.global _start

_start:
	movl $0, %edi			#Initialize position with 0
	movl data_items(,%edi,4), %eax	#Move dataitems at %edi with size 4 (First byte)
	movl %eax, %ebx			#First item is always the largest to start

start_loop:
	cmpl $0, %eax			#Check eax for 0, Yes?
	je loop_exit			#Jump to loopend

	incl %edi 			#move edi l+1
	movl data_items(,%edi,4), %eax 	#Move next byte to eax
	cmpl %ebx, %eax			#Compare largest number to cur
	jle start_loop			#Jump to loop if not larger
	
	movl %eax, %ebx			#Move to largest number
	jmp start_loop
loop_exit:
	movl $1, %eax			#OS Signal 1
	int $0x80			#Interrupt
