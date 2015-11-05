MAKE=make
PYTHON=python
TEST=test
TARGET=min-rt
MINCAML_DIR=./min-caml
MINCAML=$(MINCAML_DIR)/min-caml
LIBMINCAML=$(MINCAML_DIR)/libmincaml.S
AS=$(PYTHON) ./assembler/main.py
CSIM_DIR=./simulator/c
FSIM_DIR=./simulator/fpu
DEPENDENCY_MODULES=.install.txt
MINRT=raytracer/raytracer

$(TARGET): $(MINCAML) $(MINRT).s
	$(AS) $(MINRT).s

$(MINRT).s: $(MINRT).ml
	$(MINCAML) $(MINRT)
	if [ $$? -eq 0 ]; then \
		cat $(LIBMINCAML) >> $(MINRT).s; \
	else \
		rm $(MINRT).s; \
	fi

# the rule to make binary (compile -> cat with library -> assemble)
%.o: %.ml $(LIBMINCAML)
	$(MINCAML) $*
	if [ $$? -eq 0 ]; then \
		cat $(LIBMINCAML) >> $*.s; \
		$(AS) $*.s; \
	fi

.PHONY: $(TEST)
$(TEST):
	@echo "--------------------\nresolving test dependecies ...\n--------------------"
	git submodule update
	pip install -r $(DEPENDENCY_MODULES)
	@echo "--------------------\ngenerating min-caml compiler ...\n--------------------"
	@cd $(MINCAML_DIR); ./to_carina; $(MAKE) min-caml
	@echo "--------------------\ngenerating csim ...\n--------------------"
	@cd $(CSIM_DIR); $(MAKE)
	@echo "--------------------\ngenerating fpu sim ...\n--------------------"
	@cd $(FSIM_DIR); $(MAKE)
	@echo "--------------------\ntest begin ...\n--------------------"
	@nosetests -v
	@$(MAKE) clean
	@exit 0

$(MINCAML):
	@cd min-caml
	@$(MAKE) min-caml
	@cd ..

.PHONY: clean
clean:
	@rm -rf *.pyc tests/*.s tests/*.o assembler/*.pyc simulator/*.pyc raytracer/*.s raytracer/*.o
