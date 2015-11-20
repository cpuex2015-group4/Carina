MAKE=make
PYTHON=python
TEST=test
MINRT=raytracer/raytracer
TARGET=$(MINRT)
MINCAML_DIR=./min-caml
MINCAML=$(MINCAML_DIR)/min-caml
MLFLAGS=-inline 50
LIBMINCAML=$(MINCAML_DIR)/libmincaml.S
AS=$(PYTHON) ./assembler/main.py
PC_EMITTER=$(PYTHON) ./assembler/emit.py
CSIM_DIR=./simulator/c
FSIM_DIR=./simulator/fpu
PYSIM=$(PYTHON) ./simulator/python/main.py
CSIM=$(CSIM_DIR)/csim
DEPENDENCY_MODULES=.install.txt
SLD=./raytracer/contest.sld

$(TARGET): $(MINCAML) $(MINRT).s
	$(AS) $(MINRT).s
	$(PC_EMITTER) $(MINRT).s
	mv $(MINRT).o $(MINRT)

$(MINRT).s: $(MINRT).ml
	$(MINCAML) $(MLFLAGS) $(MINRT)
	if [ $$? = 0 ]; then \
		cat $(LIBMINCAML) >> $(MINRT).s; \
	else \
		rm $(MINRT).s; \
	fi

# the rule to make binary (compile -> cat with library -> assemble)
%.o: %.ml $(LIBMINCAML) $(MINCAML)
	$(MINCAML) $(MLFLAGS) $*
	if [ $$? = 0 ]; then \
		cat $(LIBMINCAML) >> $*.s; \
		$(AS) $*.s; \
	fi

.PHONY: run
run: $(TARGET) $(CSIM)
	@echo "begin running raytracer ... " 1>&2
	@time cat $(SLD) | $(CSIM) -f $(TARGET) 1> output.ppm
	convert output.ppm output.jpg

.PHONY: debug
debug: $(TARGET)
	@echo "begin running raytracer ... " 1>&2
	@cat $(SLD) | $(PYSIM) -v $(TARGET) 2> log-trace

.PHONY: sim
sim:
	@cd $(CSIM_DIR); $(MAKE)

$(CSIM):
	@cd $(CSIM_DIR); $(MAKE)

.PHONY: $(TEST)
$(TEST):
	@echo "--------------------\nresolving test dependecies ...\n--------------------"
	pip install -r $(DEPENDENCY_MODULES)
	@echo "--------------------\ngenerating min-caml compiler ...\n--------------------"
	@cd $(MINCAML_DIR); ./to_carina; $(MAKE) min-caml
	@echo "--------------------\ngenerating csim ...\n--------------------"
	@cd $(CSIM_DIR); $(MAKE)
	@echo "--------------------\ngenerating fpu sim ...\n--------------------"
	@cd $(FSIM_DIR); $(MAKE)
	@echo "--------------------\ntest begin ...\n--------------------"
	@nosetests -v
	@exit 0

$(MINCAML):
	@cd min-caml; $(MAKE) min-caml

.PHONY: clean
clean:
	@rm -rf *.pyc tests/*.s tests/*.o \
		assembler/*.pyc simulator/*.pyc \
		raytracer/*.s raytracer/*.o raytracer/raytracer \
		.mem-dump output.png output.ppm
	@cd $(MINCAML_DIR); $(MAKE) clean
	@cd $(CSIM_DIR); $(MAKE) clean
	@cd $(FSIM_DIR); $(MAKE) clean
