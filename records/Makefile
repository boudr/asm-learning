all:
	as write-records.s -32 -o write-records.o
	as writer.s -32 -o writer.o
	ld -m elf_i386 write-records.o writer.o -o write-records
clean:
	rm write-records *.o
