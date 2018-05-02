#Reader
.include "linux.s"
.include "record-def.s"

.equ READ_BUFFER, 8
.equ FIELDS, 12

.section .text
.global read_record
.type read_record,@function

read_record:
	push %ebp
	movl %esp, %ebp

	pushl %ebx

	movl FIELDS(%ebp), %ebx
	movl READ_BUFFER(%ebp), %ecx
	movl $RECORD_SIZE, %edx
	movl $SYS_READ, %eax
	int $LINUX_SYSCALL

	popl %ebx
	
	movl %ebp, %esp
	popl %ebp
	ret
