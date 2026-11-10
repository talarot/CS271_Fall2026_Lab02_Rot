AS := aarch64-linux-gnu-gcc
OBJCOPY := aarch64-linux-gnu-objcopy
OBJDUMP := aarch64-linux-gnu-objdump
IVERILOG := iverilog
VVP := vvp
ASFLAGS := -c -march=armv8-a

.PHONY: build sim reference clean

build:
	$(AS) $(ASFLAGS) -o test_lab02.o test_lab02.s
	$(OBJCOPY) -O verilog test_lab02.o test_lab02.mem
	$(IVERILOG) -g2012 -Wall -I runtime/head -y runtime/src -s test_Educore runtime/src/*.v runtime/tests/*.v -o test_Educore.vvp

reference:
	$(AS) $(ASFLAGS) -o reference-lab01/test_lab01.o reference-lab01/test_lab01.s
	$(OBJCOPY) -O verilog reference-lab01/test_lab01.o reference-lab01/test_lab01.mem
	$(OBJDUMP) -d reference-lab01/test_lab01.o > reference-lab01/test_lab01_disassembly.log

sim: build
	$(VVP) test_Educore.vvp +TEST_CASE=test_lab02.mem

clean:
	rm -f *.o *.mem *.vvp *.vcd reference-lab01/*.o reference-lab01/*.mem reference-lab01/*.log
