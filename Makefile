MAKE=make
PYTHON=python
TEST=test
TARGET=default
MINCAML_DIR=./min-caml
MINCAML=$(MINCAML_DIR)/min-caml
CSIM_DIR=./simulator/c
DEPENDENCY_MODULES=.install.txt

$(TARGET):
	@echo "This Makefile is for test. Please use \`make $(TEST)\`."

.PHONY: $(TEST)
$(TEST):
	@echo "--------------------\nresolving test dependecies ...\n--------------------"
#	git submodule update
	pip install -r $(DEPENDENCY_MODULES)
	@echo "--------------------\ngenerating min-caml compiler ...\n--------------------"
	@cd $(MINCAML_DIR); $(MAKE) clean; ./to_carina; $(MAKE) min-caml
	@echo "--------------------\ngenerating csim ...\n--------------------"
	@cd $(CSIM_DIR); $(MAKE)
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
	@rm -rf *.pyc tests/*.s tests/*.o assembler/*.pyc simulator/*.pyc
