.include "linux.s"
.include "record-def.s"

.section .data

record1:
	.ascii "Fredrick\0"
	.rept 31
	.byte 0
	.endr

	.ascii "Bartlett\0"
	.rept 31
	.byte 0
	.endr

	.ascii "4242 S Prairie\nTulsa, OK 74008\0"
	.rept 209
	.byte 0
	.endr

	.long 45

file_name:
.ascii "test.dat\0"

.equ FILE_DESCRIPTOR, -4

.global _start

_start:
	movl %esp, %ebp
	
	subl $4, %esp

	movl $SYS_OPEN, %eax
	movl $file_name, %ebx
	movl $0101, %ecx	#Create if doesn't exist and open for writing

	movl $0666, %edx

	int $LINUX_SYSCALL

	#EAX result: Files descriptor
	movl %eax, FILE_DESCRIPTOR(%ebp)

	pushl FILE_DESCRIPTOR(%ebp)
	pushl $record1
	call write_record
	addl $8, %esp

	movl $SYS_EXIT, %eax
	movl $0, %ebx
	int $LINUX_SYSCALL
