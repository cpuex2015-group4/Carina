MAKE=make
PYTHON=python
TEST=test
TARGET=default
DEPENDENCY_MODULES=.install.txt

$(TARGET):
	@echo "This Makefile is for test. Please use \`make $(TEST)\`."

.PHONY: $(TEST)
$(TEST):
	@pip install -r $(DEPENDENCY_MODULES)
	@nosetests -v
	@$(MAKE) clean
	@exit 0

.PHONY: clean
clean:
	@rm -rf *.pyc tests/*.o
