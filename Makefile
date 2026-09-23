# Vertex Stage Makefile
# Based on the ECE 437 SystemVerilog/Vivado flow.
# Adapted for the GPU Vertex Stage project.

# ==============================================================================
# Grid forwarding
# ==============================================================================
GRIDHOSTS = ecegrid-lnx

ifneq (,$(findstring $(GRIDHOSTS),$(HOST)))
%:
	@$(if \
		$(findstring $@,$(word 1,$(MAKECMDGOALS))), \
		grid $(MAKE) $(MAKECMDGOALS) -$(MAKEFLAGS), \
		echo "do nothing" > /dev/null)
else

# ==============================================================================
# Project configuration
# ==============================================================================

# Default top-level module and target timing frequency.
# Override from the command line if needed, e.g.:
#   make vertex_stage_top.syntp TARGET_FREQ=125
TOP             ?= vertex_stage_top
TARGET_FREQ     ?= 100
SIMTIME         ?= -all

# Course/tool libraries used by the ECE 437 environment.
COURSELIBS       = ${LIBS437}

# Directories
SRCDIR           = source
INCDIR           = include
TBDIR            = testbench
MAPDIR           = mapped
FPGADIR          = fpga
SCRDIR           = scripts
LIBDIR           = work
DEPDIR           = .deps

# Commands
SYN              = synthesize
SYNX             = synthesize_xilinx
MAKEDEP          = hdldep
VSIM             = vsim -coverage -suppress 12110
VLOG             = vlog
VCOM             = vcom
LINT             = svlint

# Compiler flags
VERFLAGS         = +acc -sv12compat -mfcu -lint +incdir+$(INCDIR) -suppress 12110
VHDFLAGS         = -93 +acc -lint

# ==============================================================================
# ModelSim / Questa waveform setup
# ==============================================================================

ifneq (0,$(words $(filter %.wav %.wavx,$(MAKECMDGOALS))))
DOFILES          = $(notdir $(basename $(wildcard $(SCRDIR)/*.do)))
DOFILE           = $(filter $(MAKECMDGOALS:%.wav=%) \
					$(MAKECMDGOALS:%_tb.wav=%) \
					$(MAKECMDGOALS:%.wavx=%) \
					$(MAKECMDGOALS:%_tb.wavx=%),$(DOFILES))

ifeq (1,$(words $(DOFILE)))
WAVDO            = do $(SCRDIR)/$(DOFILE).do
else
WAVDO            = add wave *
endif

SIMDO            = "view objects; $(WAVDO); run $(SIMTIME);" -onfinish stop
else
SIMTERM          = -c
SIMDO            = "run $(SIMTIME); exit;"
endif

# ==============================================================================
# Mapped netlist detection
# ==============================================================================

# Quartus mapped files
SYNTH            = $(filter $(MAKECMDGOALS:%.wav=%) \
					$(MAKECMDGOALS:%.sim=%) \
					$(MAKECMDGOALS:%_tb.sim=%) \
					$(MAKECMDGOALS:%_tb.wav=%) \
					$(MAKECMDGOALS:%_tb=%), \
					$(notdir $(basename $(wildcard $(MAPDIR)/*.sv $(MAPDIR)/*.v $(MAPDIR)/*.vhd))))

ifneq (,$(filter $(SYNTH), \
	$(MAKECMDGOALS:%_tb=%) $(MAKECMDGOALS:%_tb.sim=%) \
	$(MAKECMDGOALS:%_tb.wav=%) $(MAKECMDGOALS:%.wav=%) $(MAKECMDGOALS:%.sim=%)))
SYNDEF           = +define+MAPPED
endif

# Xilinx mapped files
SYNTHX           = $(filter $(MAKECMDGOALS:%.wavx=%) \
					$(MAKECMDGOALS:%.simx=%) \
					$(MAKECMDGOALS:%_tb.simx=%) \
					$(MAKECMDGOALS:%_tb.wavx=%) \
					$(MAKECMDGOALS:%_tb=%), \
					$(notdir $(basename $(wildcard $(MAPDIR)/*.sv $(MAPDIR)/*.v $(MAPDIR)/*.vhd))))

# ==============================================================================
# Vivado library setup
# ==============================================================================

VIVADO_EXECUTABLE := $(shell which vivado)
ifeq ($(VIVADO_EXECUTABLE),)
$(warning "Could not find 'vivado' in PATH. Using default VIVADO_ROOT_PATH.")
VIVADO_ROOT_PATH ?= /package/eda/xilinx/Vivado/2023.2
else
VIVADO_ROOT_PATH := $(shell dirname $(shell dirname $(VIVADO_EXECUTABLE)))
endif

GLBL_PATH := $(VIVADO_ROOT_PATH)/data/verilog/src/glbl.v

UNISIM_PATH = /home/ecegrid/a/ece437l/tools/vivado_libraries/unisim
VIVADO_LIB_MAP = vmap unisim $(UNISIM_PATH)

ifneq (0,$(words $(filter %.sim %.wav %_tb.sim %_tb.wav,$(MAKECMDGOALS))))
VIVADO_SIM_FLAGS += +define+USE_VIVADO
VIVADO_SIM_FLAGS += -L unisim

ifneq (,$(filter $(SYNTHX), \
	$(MAKECMDGOALS:%_tb=%) $(MAKECMDGOALS:%_tb.sim=%) \
	$(MAKECMDGOALS:%_tb.wav=%) $(MAKECMDGOALS:%.wav=%) $(MAKECMDGOALS:%.sim=%)))
VIVADO_SIM_FLAGS += +define+VIVADO_MAPPED
endif
endif

# ==============================================================================
# Source discovery
# ==============================================================================

VLSTEM           = $(notdir $(basename $(wildcard $(SRCDIR)/*.v $(TBDIR)/*.v)))
SVSTEM           = $(notdir $(basename $(wildcard $(SRCDIR)/*.sv $(TBDIR)/*.sv)))
VHSTEM           = $(notdir $(basename $(wildcard $(SRCDIR)/*.vhd $(TBDIR)/*.vhd)))
HDSTEM           = $(notdir $(basename $(wildcard $(INCDIR)/*.vh)))

SRCSTEM          = $(VLSTEM) $(SVSTEM) $(VHSTEM)
SRCS             = $(addsuffix .v,$(VLSTEM)) \
					$(addsuffix .sv,$(SVSTEM)) \
					$(addsuffix .vhd,$(VHSTEM))
HDRS             = $(addsuffix .vh,$(HDSTEM))
DEPS             = $(addsuffix .d,$(VLSTEM) $(SVSTEM) $(VHSTEM) $(HDSTEM))

# Targets that should not trigger dependency generation
NODEPS           = help clean clean_sim clean_map clean_deps clean_fpga \
					all sim wav syn synt syntp lint_all dirs

# ==============================================================================
# Make configuration
# ==============================================================================

.PHONY: $(NODEPS)

.SUFFIXES:
.SUFFIXES: .vh .sv .vhd .d .v

vpath %.vh  $(INCDIR)/
vpath %.v   $(MAPDIR)/ $(SRCDIR)/ $(TBDIR)/
vpath %.sv  $(MAPDIR)/ $(SRCDIR)/ $(TBDIR)/
vpath %.vhd $(SRCDIR)/ $(TBDIR)/
vpath %.d   $(DEPDIR)/
vpath %     $(DEPDIR)/

default: help

ifneq (0,$(words $(VLSTEM) $(SVSTEM)))
SIMLIBS = $(addprefix -L ,$(filter %_ver,$(shell ls $(COURSELIBS) 2>/dev/null)))
endif

ifeq (0,$(words $(findstring $(MAKECMDGOALS),$(NODEPS))))
-include $(addprefix $(DEPDIR)/,$(DEPS))
endif

# ==============================================================================
# Convenience targets for the Vertex Stage top
# ==============================================================================

dirs:
	@mkdir -p $(INCDIR) $(SCRDIR) $(MAPDIR) $(FPGADIR)

sim: dirs
	@$(MAKE) $(TOP).sim

wav: dirs
	@$(MAKE) $(TOP).wav

syn: dirs
	@$(MAKE) $(TOP).syn

synt: dirs
	@$(MAKE) $(TOP).synt TARGET_FREQ=$(TARGET_FREQ)

syntp: dirs
	@$(MAKE) $(TOP).syntp TARGET_FREQ=$(TARGET_FREQ)

all: dirs
	@echo "=== Vertex Stage: simulation ==="
	@$(MAKE) $(TOP).sim
	@echo "=== Vertex Stage: timing synthesis ($(TARGET_FREQ) MHz) ==="
	@$(MAKE) $(TOP).syntp TARGET_FREQ=$(TARGET_FREQ)

lint_all:
	@for f in $(wildcard $(SRCDIR)/*.sv $(TBDIR)/*.sv); do \
		$(MAKE) -s $$(basename $$f .sv).lint || exit $$?; \
	done

# ==============================================================================
# Linter support
# ==============================================================================

lint:
	@echo "+incdir+$(INCDIR)/" > filelist.f
	@echo "$(SOURCE_FILE)" >> filelist.f
	@-$(LINT) -f filelist.f \
		| sed -r 'w /dev/stderr' \
		| sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]|\x1B\(B//g' \
		>> lint.log
	@rm -f filelist.f

%.lint: %.sv | $(LIBDIR)
	@$(MAKE) -s lint SOURCE_FILE=$<

# ==============================================================================
# Dependency and compile rules
# ==============================================================================

$(DEPDIR):
	@test -d $(DEPDIR) || mkdir $(DEPDIR)

$(LIBDIR):
	@test -d $(LIBDIR) || vlib $(LIBDIR)

%.d: | $(DEPDIR)
	@$(SHELL) -ec '$(MAKEDEP) ${*F} $(SRCDIR) $(TBDIR) $(INCDIR) \
		| sed \
		-e "s/$$/ $(filter ${*F}.v ${*F}.sv ${*F}.vhd ${*F}.vh,$(SRCS) $(HDRS))/" \
		-e "s/\.[a-z]\+/&o/g" \
		-e "s/^/${*F}: /" \
		> $@'

%.vho: %.vh | $(LIBDIR)
	@$(MAKE) SOURCE_FILE=$<
	$(VLOG) $(VERFLAGS) $(SYNDEF) $(VIVADO_SIM_FLAGS) $<
	@touch $(DEPDIR)/$@

%.vo: %.v | $(LIBDIR)
	@$(MAKE) SOURCE_FILE=$<
	$(VLOG) $(VERFLAGS) $(SYNDEF) $(VIVADO_SIM_FLAGS) $<
	@touch $(DEPDIR)/$@

%.svo: %.sv | $(LIBDIR)
	@$(MAKE) SOURCE_FILE=$<
	$(VLOG) $(VERFLAGS) $(SYNDEF) $(VIVADO_SIM_FLAGS) $<
	@touch $(DEPDIR)/$@

%.vhdo: %.vhd | $(LIBDIR)
	@$(MAKE) SOURCE_FILE=$<
	$(VCOM) $(VHDFLAGS) $<
	@touch $(DEPDIR)/$@

# ==============================================================================
# Simulation rules
# ==============================================================================

# Quartus mapped simulation
%_tb.simq %_tb.wavq %.simq %.wavq: %_tb
	@$(VSIM) $(SIMTERM) -do $(SIMDO) $(SIMLIBS) $(SIMSYN) \
		-wlf $(addsuffix _tb,$*).wlf \
		$(LIBDIR).$(addsuffix _tb,$*)

# Xilinx/Vivado simulation
%_tb.sim %_tb.wav %.sim %.wav: %_tb
	@$(VIVADO_LIB_MAP)
	@$(VLOG) -work $(LIBDIR) $(VERFLAGS) $(VIVADO_SIM_FLAGS) $(GLBL_PATH)
	@$(VSIM) $(SIMTERM) -do $(SIMDO) \
		$(VIVADO_SIM_FLAGS) \
		-wlf $(addsuffix _tb,$*).wlf \
		$(LIBDIR).$(addsuffix _tb,$*) \
		glbl

# ==============================================================================
# Synthesis rules
# ==============================================================================

# Quartus synthesis
%_tb.synfq %.synfq %_tb.syntq %.syntq %_tb.synq %.synq:
	@$(SYN) $(if $(filter %.syntq,$@),-t) $*
	-@rm -f $(DEPDIR)/${*F}_tb.svo

# Xilinx functional synthesis
%_tb.syn %.syn:
	@mkdir -p $(MAPDIR) $(FPGADIR)
	@echo "--- Running Xilinx functional synthesis for '$*' ---"
	@$(SYNX) -c $*
	@sed -i 's|\.EN_ECC_READ("FALSE")|\.EN_ECC_READ(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_READ("TRUE")|\.EN_ECC_READ(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("FALSE")|\.EN_ECC_WRITE(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("TRUE")|\.EN_ECC_WRITE(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	-@rm -f $(DEPDIR)/${*F}_tb.svo

# Xilinx timing synthesis
%_tb.synt %.synt:
	@mkdir -p $(MAPDIR) $(FPGADIR)
	@echo "--- Running Xilinx timing synthesis for '$*' ($(TARGET_FREQ) MHz) ---"
	@$(SYNX) -t -c -f $(TARGET_FREQ) $*
	@sed -i 's|\.EN_ECC_READ("FALSE")|\.EN_ECC_READ(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_READ("TRUE")|\.EN_ECC_READ(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("FALSE")|\.EN_ECC_WRITE(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("TRUE")|\.EN_ECC_WRITE(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	-@rm -f $(DEPDIR)/${*F}_tb.svo

# Xilinx project-mode timing synthesis / implementation
%_tb.syntp %.syntp:
	@mkdir -p $(MAPDIR) $(FPGADIR)
	@echo "--- Running Xilinx project-mode timing synthesis for '$*' ($(TARGET_FREQ) MHz) ---"
	@$(SYNX) -p -t -c -f $(TARGET_FREQ) $*
	@sed -i 's|\.EN_ECC_READ("FALSE")|\.EN_ECC_READ(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_READ("TRUE")|\.EN_ECC_READ(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("FALSE")|\.EN_ECC_WRITE(0)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	@sed -i 's|\.EN_ECC_WRITE("TRUE")|\.EN_ECC_WRITE(1)|g' mapped/$*.sv mapped/$*_tb.sv 2>/dev/null || true
	-@rm -f $(DEPDIR)/${*F}_tb.svo

# ==============================================================================
# Cleaning
# ==============================================================================

clean: clean_sim clean_map clean_deps clean_fpga

clean_sim: clean_deps
	@rm -rf $(LIBDIR) *.log *.wlf transcript coverage.ucdb

clean_map:
	@rm -rf $(MAPDIR)/* ._* *.summary *.log

clean_fpga:
	@rm -rf $(FPGADIR)/* ._*

clean_deps:
	@rm -rf $(DEPDIR) *.d

# ==============================================================================
# Help
# ==============================================================================

help:
	@echo ""
	@echo "Vertex Stage build flow"
	@echo ""
	@echo "Default top       : $(TOP)"
	@echo "Target frequency  : $(TARGET_FREQ) MHz"
	@echo ""
	@echo "--- Convenience targets ---"
	@echo "  make sim                    simulate $(TOP) on command line"
	@echo "  make wav                    simulate $(TOP) with GUI/waveform"
	@echo "  make syn                    functional synthesis of $(TOP)"
	@echo "  make synt                   timing synthesis of $(TOP)"
	@echo "  make syntp                  project-mode timing synthesis of $(TOP)"
	@echo "  make all                    run top simulation, then project timing synthesis"
	@echo ""
	@echo "--- Per-module Xilinx/Vivado flow ---"
	@echo "  make <module>.sim           simulate module testbench on command line"
	@echo "  make <module>.wav           simulate module testbench with GUI"
	@echo "  make <module>.syn           synthesize functional netlist"
	@echo "  make <module>.synt          synthesize timing netlist at TARGET_FREQ"
	@echo "  make <module>.syntp         project-mode timing synthesis at TARGET_FREQ"
	@echo ""
	@echo "Examples:"
	@echo "  make row_mac.sim"
	@echo "  make matrix_vector_mul.wav"
	@echo "  make perspective_divide.syntp"
	@echo "  make vertex_stage_top.syntp"
	@echo "  make vertex_stage_top.syntp TARGET_FREQ=125"
	@echo ""
	@echo "--- Lint ---"
	@echo "  make <module>.lint"
	@echo "  make lint_all"
	@echo ""
	@echo "--- Clean ---"
	@echo "  make clean"
	@echo "  make clean_sim"
	@echo "  make clean_map"
	@echo "  make clean_fpga"
	@echo ""

endif
