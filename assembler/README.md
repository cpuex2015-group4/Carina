## Carina assembler

### Usage

` python /path/to/this/dir/main.py [asm-file] `

In the same directory, {[asm-file]%.s}.o will be generated.

### Features

* support FPU
* support multiple ` .text ` sections and ` .data ` sections

### Assembly Format

#### text section

* at least one ` .text ` section
* % is prefix for registers
* $ is prefix for immediates
* no prefix for labels
* both (%reg), disp(%reg) are valid addressing mode (NOT $disp(%reg) !!)
* entry point is ` _min_caml_start `

#### data section

* floating point value is located by ` .long ` pseudo-instruction

### Known Issues

* have not supported overflow yet (for too large immediate)
