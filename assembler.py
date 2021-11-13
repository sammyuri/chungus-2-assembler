from os import path
from typing import List, Tuple

import formats
from schem import generate_schematic

###############################################################################
# assembler
###############################################################################


class AssemblyError(Exception):
    pass


def get_operands(line: str) -> Tuple[str, List[str]]:
    """Get the opcode and operands of an assembly line"""
    opcode = line.split(" ")[0]
    operands = line[len(opcode) + 1:].replace(",", "")
    operands = operands.split() if operands else []
    return (opcode, operands)


def to_decimal(number: str) -> int:
    """Convert other bases to decimal"""
    if number[0:2] == "0b":  # binary
        return int(number[2:], 2)
    if number[0:2] == "0x":  # hex
        return int(number[2:], 16)
    if number[0:2] == "0o":  # octal
        return int(number[2:], 8)
    if number[0:2] == "0d":  # decimal
        return int(number[2:], 10)
    # default - decimal
    return int(number)


def get_binary(number: int, length: int) -> str:
    """Convert a decimal number to signed binary number of given length"""
    if number < 0:  # use 2's complement
        number = 2 ** length + number
    result = str(bin(number))[2:]
    # result over the maximum allowed size
    if len(result) > length:
        raise AssemblyError(f"Number too long for {length} bits: {number}")
    return result.zfill(length)


def parse_immediate(immediate: str, length: int) -> str:
    """Get the binary representation of an immediate value"""
    # ASCII character
    if immediate[0] == '"':
        return get_binary(ord(immediate[1].replace("@", " ")), length)
    # remove prefix e.g. "M10" (for memory address 10) -> "10"
    if not immediate[0] in "-0123456789":
        immediate = immediate[1:]
    # make sure immediate is an integer
    try:
        immediateindex = to_decimal(immediate)
    except ValueError:
        raise AssemblyError(f"Invalid immediate: {immediate}")
    else:
        # the immediate may be too long (for example in branch instructions)
        # so take it mod 2 ^ length
        return get_binary(immediateindex % (2 ** length), length)


def parse_register(register: str) -> str:
    """Get the binary representation of a register"""
    # make sure it is actually a register
    if not (len(register) == 2 and register[0] in ("$", "R")):
        raise AssemblyError(f"Invalid register: {register}")
    # make sure register is valid
    try:
        registerindex = to_decimal(register[1:])
    except ValueError:
        raise AssemblyError(f"Invalid register: {register}")
    if registerindex > 7:
        raise AssemblyError(f"Invalid register: {register}")
    return get_binary(registerindex, 3)


def parse_line(line: str) -> str:
    """Translate an assembly instruction to machine code"""
    opcode, operands = get_operands(line)
    # get base instruction
    base = formats.ALIAS.get(opcode, opcode)
    if base not in formats.FORMATS:
        raise AssemblyError(f"Invalid opcode: {opcode}")

    result = ""
    for operand in formats.FORMATS[base]:
        if operand == "REG":         # register - assume R0 if not given
            result += parse_register(operands.pop(0)) if operands else "000"
        elif operand[0:3] == "IMM":  # fixed length immediate - default 0
            length = int(operand.split("_")[1])
            if not operands:
                result += "0" * length
            else:
                result += parse_immediate(operands.pop(0), length)
        elif operand == "BITS":      # operand depends on the opcode
            result += formats.BITS[opcode]
        elif operand == "OPERAND":   # control bits (required)
            if not operands:
                raise AssemblyError("Not enough operands")
            if not operands[0] in formats.OPERANDS:
                raise AssemblyError(f"Unknown operand: {operands[0]}")
            result += formats.OPERANDS[operands.pop(0)]
        else:                        # fixed operand for the instruction
            result += operand

    return result


###############################################################################
# cleanup code
###############################################################################


def remove_comments(lines: List[str]) -> List[str]:
    """Remove comments and empty lines"""
    formatlines = []
    for line in lines:
        # comment
        if "//" in line:
            formatlines.append(line[:line.index("//")].strip())
        # ignore blank lines
        elif line:
            formatlines.append(line)
    return formatlines


def parse_pages(lines: List[str]) -> List[str]:
    """Add NOPs between pages to keep size 64"""
    # (prevent 64 NOPs at the start of program)
    if lines[0] == ".PAGE:0":
        lines.pop(0)

    instructioncount = 0
    formatlines = []
    for line in lines:
        # if a new page is found and the last one is not full, fill with NOPs
        # which assemble to 00000000
        if line[0:6] == ".PAGE:":
            formatlines.extend(["NOP" for i in range(64 - instructioncount)])
            instructioncount = 0
        # otherwise add to formatlines
        else:
            formatlines.append(line)
            # ignore labels in instruction count
            if line[0] != ".":
                instructioncount += 1
    return formatlines


def parse_labels(lines: List[str]) -> List[str]:
    """Turn labels into immediate values"""
    def is_label(line):  # check if a given line is a label
        line = line.strip()
        return line and line[0] == "."

    labels = {}
    linenum = 0
    # find all labels and their line numbers
    while linenum < len(lines):
        if is_label(lines[linenum]):
            # add to label dict and remove from lines
            labels[lines[linenum].strip()] = str(linenum)
            lines.pop(linenum)
        else:
            linenum += 1
    # convert labels to immediates
    formatlines = []
    for line in lines:
        if not line:  # blank line (should be cleaned up?)
            continue
        # get operands - NOTE: you cannot just replace labels, because there
        # could be a ".test" label but also a ".test2" label, and the first
        # would overwrite the second.
        opcode, operands = get_operands(line.strip())
        operands = [labels.get(operand, operand) for operand in operands]
        # turn back into a formatted assembly instruction
        formatlines.append(opcode + " " + ", ".join(operands))
    return formatlines


def cleanup(lines: List[str]) -> List[str]:
    """Clean up assembly code and parse labels"""
    lines = remove_comments(lines)
    lines = parse_pages(lines)
    lines = parse_labels(lines)
    return lines


###############################################################################
# file management
###############################################################################


def read_file(filepath: str) -> List[str]:
    """Read an assembly file and remove comments"""
    with open(filepath, "r") as f:
        lines = [line.strip() for line in f]
    lines = remove_comments(lines)
    return lines


def write_file(filepath: str, lines: List[str]) -> None:
    """Write a machine code file"""
    with open(filepath, "w") as f:
        for line in lines:
            f.write(line + "\n")


###############################################################################
# io
###############################################################################


def assemble(lines: List[str]) -> List[str]:
    """Translate a list of assembly instructions to machine code"""
    result = []
    lines = cleanup(lines)
    for linenumber, line in enumerate(lines):
        try:
            machinecode = parse_line(line)
        except AssemblyError as error:
            # format error message
            errorcode = f"Error on line {linenumber}: {error}"
            raise AssemblyError(errorcode) from None
        else:
            result.append(machinecode)
    return format_assembly(result)


def assemble_file(filepath: str) -> None:
    """Assemble an assembly file to a machine code file"""
    lines = read_file(filepath)
    lines = assemble(lines)
    # get resulting file name
    filename = path.splitext(filepath)[0] + ".txt"
    write_file(filename, lines)
    # also create a schematic to run on the Minecraft hardware
    generate_schematic(
        [line[0:8] + line[9:17] for line in lines],
        path.splitext(filepath)[0] + "_CHUNGUS2"
    )


def format_assembly(lines: List[str]) -> List[str]:
    """Split assembly instructions into 2 bytes"""
    return [line[0:8] + " " + line[8:16] for line in lines]


if __name__ == "__main__":
    filepath = input("Enter file path: ")
    assemble_file(filepath)
