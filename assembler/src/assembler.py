from enum import Enum
REG_DICT = {"$zero" : 0, "$at" : 1,\
    "$v0" : 2, "$v1" : 3,\
    "$a0" : 4, "$a1" : 5, "$a2" : 6, "$a3" : 7,\
    "$t0" : 8, "$t1" : 9, "$t2" : 10, "$t3" : 11, "$t4" : 12, "$t5" : 13, "$t6" : 14, "$t7" : 15,\
    "$s0" : 16, "$s1" : 17, "$s2" : 18, "$s3" : 19, "$s4" : 20, "$s5" : 21, "$s6" : 22, "$s7" : 23,\
    "$t8" : 24, "$t9" : 25,\
    "$k0" : 26, "$k1" : 27,\
    "$gp" : 28, "$sp" : 29, "$fp" : 30, "$ra" : 31}

def binary_inc(binary):
  i = len(binary)
  lst = list(binary)
  while(True):
    if lst[i - 1] == "0":
      lst[i - 1] = "1"
      break
    else:
      lst[i - 1] = "0"
      i -= 1
  return "".join(lst)

def disolute_minus(binary):
  new_binary = ""
  binary = binary.replace("-", "")
  while(len(binary) > 0):
    if binary[0] == '1':
      new_binary += '0'
    else:
      new_binary += '1'
    binary = binary[1:]
  return binary_inc(new_binary)

def bin2hex(binary):
  hex_len = len(binary) / 4
  return format(int(binary, 2), '0' + str(hex_len) + 'x')

def hex2bin(hex):
  return format(int(hex, 16), "032b")

def imm2bin(immediate):
  if immediate < 0:
    binary = format(immediate, '017b')
    binary = disolute_minus(binary)
  else:
    binary = format(immediate, '016b')
  return binary 

def shamt2bin(shamt):
  if shamt < 0:
    binary = format(shamt, '06b')
    binary = disolute_minus(binary)
  else:
    binary = format(shamt, '05b')
  return binary 

def address2bin(address):
  if address < 0:
    binary = format(address, '027b')
    binary = disolute_minus(binary)
  else:
    binary = format(address, '026b')
  return binary

def offset2bin(offset):
  if offset < 0:
    binary = format(offset, '017b')
    binary = disolute_minus(binary)
  else:
    binary = format(offset, '016b')
  return binary

def reg2bin(register):
  reg_num = REG_DICT[register]
  binary = format(reg_num, '05b')
  return binary

def bin2bytes(binary):
  byte1 = chr(int(binary[0:8], 2))
  byte2 = chr(int(binary[8:16], 2))
  byte3 = chr(int(binary[16:24], 2))
  byte4 = chr(int(binary[24:32], 2))
  return (byte1 + byte2 + byte3 + byte4)


#read all assembly and make dictionary s.t.
#{label(string) : line_num(int)}
def label_dict(lines):
  dict = {}
  for i,line in enumerate(lines):
    if ":" in line:
      label = line.split(":")[0].strip()
      dict[label] = i - 1
  return dict

def remove_label(lines):
  new_lines = []
  for line in lines:
    if ":" in line:
      new_lines.append(line.split(":")[1].strip() + "\n")
    else:
      new_lines.append(line)
  return new_lines

#operand type
#1 : $hoge
#2 : immediate($hoge)
#3 : immediate
#4 : shamt 
#5 : address
#6 : label(PC relative)
#7 : label(absolute)
#return : (register_code, immediate_code)
class Operandtype(Enum):
  REGISTER_DIRECT = 1
  REGISTER_INDIRECT = 2
  IMMEDIATE = 3
  SHAMT = 4
  ADDRESS = 5
  LABEL_RELATIVE = 6
  LABEL_ABSOLUTE = 7
    
class Parser:
#return (operation, operands[])
#line does not contain label
  @staticmethod
  def parse_line(line):
    line = line.strip()
    tmp = line.split(" ", 1)
    operation = tmp[0]
    operands = tmp[1].replace(" ", "").split(",")
    return (operation, operands)


  @staticmethod
  def parse_operand(operand, operand_type, label_dict=None, line_num=0):
    if operand_type == Operandtype.REGISTER_DIRECT:
      register_bin = reg2bin(operand)
      return (register_bin, None)
    elif operand_type == Operandtype.REGISTER_INDIRECT:
      tmp = operand.split("(")
      immediate_bin = imm2bin(int(tmp[0]))
      register_bin = reg2bin(tmp[1][0:-1])
      return (register_bin, immediate_bin)
    elif operand_type == Operandtype.IMMEDIATE:
      immediate_bin = imm2bin(int(operand))
      return (None, immediate_bin)
    elif operand_type == Operandtype.SHAMT:
      shamt_bin = shamt2bin(int(operand))
      return (None, shamt_bin)
    elif operand_type == Operandtype.ADDRESS:
      address_bin = address2bin(int(operand))
      return (None, address_bin)
    elif operand_type == Operandtype.LABEL_RELATIVE:
      target_line_num = label_dict[operand]
      offset = target_line_num - line_num + 1
      offset_bin = offset2bin(offset)
      return (None, offset_bin)
    elif operand_type == Operandtype.LABEL_ABSOLUTE:
      target_line_num = label_dict[operand]
      return (None, format(4 * (target_line_num - 1), "026b"))
      


class Assembler:
#all class method take line as arg and return binary
  @staticmethod
  def add(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("20", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)
    
  @staticmethod
  def addi(operands, label_dict, line_num):
    opecode_bin = format(int("8", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def and_(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("24", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(bin2hex(inst_bin))
    print(inst_bin),
    return bin2bytes(inst_bin)

  @staticmethod
  def andi(operands, label_dict, line_num):
    opecode_bin = format(int("c", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
    print(inst_bin)
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def beq(operands, label_dict, line_num):
    opecode_bin = format(int("4", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def bne(operands, label_dict, line_num):
    opecode_bin = format(int("5", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def j(operands, label_dict, line_num):
    opecode_bin = format(int("2", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[0], Operandtype.LABEL_ABSOLUTE, label_dict)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def jal(operands, label_dict, line_num):
    opecode_bin = format(int("3", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[0], Operandtype.LABEL_ABSOLUTE, label_dict)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def jr(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("08", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        format(0, "05b") +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)
        
  @staticmethod
  def lw(operands, label_dict, line_num):
    opecode_bin = format(int("23", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin) 

  @staticmethod
  def nor(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("27", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def or_(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("25", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def ori(operands, label_dict, line_num):
    opecode_bin = format(int("d", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def slt(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("2a", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def slti(operands, label_dict, line_num):
    opecode_bin = format(int("a", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  #####according to henepata, R[rd] = R[rs] << shamt
  ###but to web assembler, R[rd] = R[rt] << shamt
  @staticmethod
  def sll(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("00", 16), "06b")
    inst_bin = opecode_bin +\
        format(0, "05b") +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.SHAMT)[1] +\
        format(0, "06b")
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def srl(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("02", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.SHAMT)[1] +\
        format(0, "06b")
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def sw(operands, label_dict, line_num):
    opecode_bin = format(int("2b", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[1]
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def sub(operands, label_dict, line_num):
    opecode_bin = format(int("0", 16), "06b")
    funct_bin = format(int("22", 16), "06b")
    inst_bin = opecode_bin +\
        Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
        Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
        format(0, "05b") +\
        funct_bin
    print(inst_bin),
    print(bin2hex(inst_bin))
    return bin2bytes(inst_bin)

  @staticmethod
  def move(operands, label_dict, line_num):
    return Assembler.add([operands[0], "$zero", operands[1]], label_dict, line_num) 

FUNC_DICT = {\
    "add" : Assembler.add,\
    "addi" : Assembler.addi,\
    "and" : Assembler.and_,\
    "andi" : Assembler.andi,\
    "beq" : Assembler.beq,\
    "bne" : Assembler.bne,\
    "j" : Assembler.j,\
    "jal" : Assembler.jal,\
    "jr" : Assembler.jr,\
    "lw" : Assembler.lw,\
    "nor" : Assembler.nor,\
    "or" : Assembler.or_,\
    "ori" : Assembler.ori,\
    "slt" : Assembler.slt,\
    "slti" : Assembler.slti,\
    "sll" : Assembler.sll,\
    "srl" : Assembler.srl,\
    "sw" : Assembler.sw,\
    "sub" : Assembler.sub,\
    "move" : Assembler.move,\
    }

