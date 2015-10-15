PYTHON=python
TEST=test
TARGET=default
DEPENDENCY_MODULES=.install.txt

$(TARGET):
	@echo "This Makefile is for test. Please use \`make $(TEST)\`."

$(TEST):
	@pip install -r $(DEPENDENCY_MODULES)
	@nosetests -v
	@exit 0
