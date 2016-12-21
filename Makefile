Author= "Pose Fernando Ezequiel"
Curse= "R5055"
TP= "Trabajo Practico obligatorio"

.PHONY : help
help:
	@echo	''
	@echo	'Help: '
	@echo	'  make help:		Help'
	@echo   '  make clean_s:	Remove *.o *.elf *.out *.lst'
	@echo	'  make go:		Clean-Compile-Debuger'
	@echo   '  make all:		Clean-Compile'
	@echo   '  make bochs:		Run Bochs ( - No funciona - )'
	@echo	'  make generate:	Compile bootloader+aplication'
	@echo	'  make clean:		Clean'	
	@echo	''
	
##########################
#     Boot Load          #
##########################

KERNEL_MEMORY=0x8000
KERNEL_SIZE_SECTORS=17
BOOTLOADER_DEFINES=-DKERNEL_SIZE_SECTORS=$(KERNEL_SIZE_SECTORS) -DKERNEL_MEMORY=$(KERNEL_MEMORY)

##########################
#     Aplication         #
##########################

init_catedra.bin: init_catedra.asm
	nasm -f bin init_catedra.asm -o init_catedra.bin -DROM_LOCATION=0xF0000

TrabajoPractico.out: TrabajoPractico.asm linker.lds 
	nasm -f elf32 TrabajoPractico.asm -o TrabajoPractico.elf -l TrabajoPractico.lst 
	
	ld -z max-page-size=0x01000 -m elf_i386 -T linker.lds -e Entry TrabajoPractico.elf -o $@
	
	readelf -a TrabajoPractico.out > main_readelf.txt
	
	ld -z max-page-size=0x01000 --oformat=binary -m elf_i386 -T linker.lds -e Entry TrabajoPractico.elf -o $@
	
	
##########################
#     Bochs      #
##########################

.PHONY : bochs
bochs:
	/opt/bochs-2.6.2-int/bin/bochs -f bochsrc

.PHONY : clean_bochs
clean_bochs:
	rm -f *.log

##########################
#     General            #
##########################

.PHONY : clean_s
clean_s:
	rm -f *.o *.elf *.out *.lst none
	
.PHONY : clean_gen
clean_gen:
	rm -f generate/out/*.lds generate/out/*.asm
	
.PHONY : clean
clean:  clean_s clean_bochs clean_gen

.PHONY : generate
generate: init_catedra.bin TrabajoPractico.out

.PHONY : all
all: clean generate

.PHONY : go
go: all bochs
