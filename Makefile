MAKE=make
PYTHON=python
TEST=test
TARGET=default
MINCAML=./min-caml/min-caml
DEPENDENCY_MODULES=.install.txt

$(TARGET):
	@echo "This Makefile is for test. Please use \`make $(TEST)\`."

.PHONY: $(TEST)
$(TEST):
	@echo "--------------------\nresolving test dependecies ...\n--------------------"
	git submodule update
	pip install -r $(DEPENDENCY_MODULES)
	@echo "--------------------\ngenerating min-caml compiler ...\n--------------------"
	@cd min-caml; $(MAKE) clean; ./to_carina; $(MAKE) min-caml; cd ..
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
