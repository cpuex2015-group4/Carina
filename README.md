# Carina

CPUex 2015 1st processor for group 4

# Architecture Information

Carina is 32bit RISC Processor, which is subset of MIPS32.

You can refer to more detail information about Carina [here](https://gist.github.com/levelfour/5cd66a1031b9e24dca42).

# Code Status

[![Build Status](https://travis-ci.org/cpuex2015-group4/Carina.svg)](https://travis-ci.org/cpuex2015-group4/Carina)

## Test

You can run the test using Python unit test tool `nose`.
Test procedure is written in `Makefile`, so all you have to do is execute `make test`.

All tests are written in `run_test.py`. In this Python script, there are a few assertion methods.
_At the moment, the testing module is comparing the content of %v0 (return value of main routine) and the expected value_.
