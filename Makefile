PYTHON=python
TEST=test
TARGET=default

$(TARGET):
	@echo "This Makefile is for test. Please use \`make $(TEST)\`."

$(TEST):
	@exit 0
