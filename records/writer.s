#Writer.s
.include "linux.s"
.include "record-def.s"

#Stack locals
.equ WRITE_BUFFER, 8
.equ FIELDS, 12

.section .text
.global write_record
.type write_record,@function
write_record:
	pushl %ebp
	movl %esp, %ebp

	pushl %ebx

	movl $SYS_WRITE, %eax
	movl FIELDS(%ebp), %ebx
	movl WRITE_BUFFER(%ebp), %ecx
	movl $RECORD_SIZE, %edx

	int $LINUX_SYSCALL

	popl %ebx

	movl %ebp, %esp
	popl %ebp
	ret
