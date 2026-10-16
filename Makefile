IVERILOG ?= iverilog
VVP ?= vvp
RTL := $(filter-out tb.sv,$(wildcard *.sv))
.PHONY: test sim clean
test: build/tb_regfile build/tb_alu
	$(VVP) build/tb_regfile
	$(VVP) build/tb_alu
build:
	mkdir -p build
build/tb_regfile: reg.sv tests/tb_regfile.sv | build
	$(IVERILOG) -g2012 -s tb_regfile -o $@ $^
build/tb_alu: ALU.sv tests/tb_alu.sv | build
	$(IVERILOG) -g2012 -s tb_alu -o $@ $^
build/processor: $(RTL) tb.sv | build
	$(IVERILOG) -g2012 -s tb_top_processor -o $@ $^
sim: build/processor
	$(VVP) build/processor
clean:
	rm -rf build
