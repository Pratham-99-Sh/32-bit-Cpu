import re

#––– condition codes –––
COND_CODES = {
    "EQ": 0b0000, "NE": 0b0001, "CS": 0b0010, "HS": 0b0010,
    "CC": 0b0011, "LO": 0b0011, "MI": 0b0100, "PL": 0b0101,
    "VS": 0b0110, "VC": 0b0111, "HI": 0b1000, "LS": 0b1001,
    "GE": 0b1010, "LT": 0b1011, "GT": 0b1100, "LE": 0b1101,
    "AL": 0b1110, "":  0b1110
}

#––– data-processing opcodes –––
CMD_CODES = {
    "AND": 0b0000, "SUB": 0b0010, "ADD": 0b0100, "ORR": 0b1100
}

#––– memory ops: (L, B) –––
MEM_CODES = {
    "STR":  (0, 0), "STRB": (0, 1),
    "LDR":  (1, 0), "LDRB": (1, 1)
}

def parse_register(tok):
    if not tok.upper().startswith('R'):
        raise ValueError(f"Invalid register '{tok}'")
    return int(tok[1:])

def parse_immediate(tok):
    # allow decimal or hex (#10 or #0xA)
    if not tok.startswith('#'):
        raise ValueError(f"Invalid immediate '{tok}'")
    return int(tok[1:], 0)

def encode_dp(cond, opcode, S, Rn, Rd, I, Src):
    instr = (cond << 28) \
          | (0b00  << 26) \
          | (I     << 25) \
          | (opcode<< 21) \
          | (S     << 20) \
          | (Rn    << 16) \
          | (Rd    << 12) \
          | (Src     & 0xFFF)
    return instr

def encode_mem(cond, L, B, Rn, Rd, offset):
    # I=0 (imm), P=1, U=1, W=0, B, L
    instr = (cond << 28) \
          | (0b01 << 26) \
          | (0    << 25) \
          | (1    << 24) \
          | (1    << 23) \
          | (B    << 22) \
          | (0    << 21) \
          | (L    << 20) \
          | (Rn   << 16) \
          | (Rd   << 12) \
          | (offset & 0xFFF)
    return instr

def encode_branch(cond, L, imm24):
    instr = (cond << 28) \
          | (0b10 << 26) \
          | (1    << 25) \
          | (L    << 24) \
          | (imm24 & 0xFFFFFF)
    return instr


def assemble_line(line, addr, labels):
    # strip comments
    line = line.split(';',1)[0].strip()
    if not line:
        return None

    parts = line.split(None, 1)
    mnem  = parts[0].upper()
    rest  = parts[1] if len(parts)>1 else ""

    # --- 1) strip two-letter condition suffix ---
    cond_suffix = ""
    base = mnem
    for code in sorted((c for c in COND_CODES if c), key=lambda x: -len(x)):
        if base.endswith(code):
            cond_suffix = code
            base = base[:-len(code)]
            break
    cond = COND_CODES.get(cond_suffix, 0)

    # --- 1.a) strip an S-suffix for data-processing ops ---
    S = 0
    if base.endswith('S') and base[:-1] in CMD_CODES:
        S = 1
        base = base[:-1]

    # --- 2) Branch / BL ---
    if base in ("B", "BL"):
        L = 1 if base=="BL" else 0
        label = rest.strip()
        if label not in labels:
            raise ValueError(f"Unknown label '{label}'")
        target = labels[label]
        imm24  = ((target - (addr + 8)) // 4) & 0xFFFFFF
        return encode_branch(cond, L, imm24)

    # --- 3) Data-processing ---
    if base in CMD_CODES:
        # operands: Rd, Rn, Src
        ops = [o.strip() for o in rest.split(',')]
        if len(ops)!=3:
            raise ValueError(f"DP needs 3 operands: '{line}'")
        Rd_tok, Rn_tok, Src_tok = ops
        Rd = parse_register(Rd_tok)
        Rn = parse_register(Rn_tok)

        if Src_tok.startswith('#'):
            I   = 1
            imm = parse_immediate(Src_tok)
            if not 0 <= imm <= 0xFF:
                raise ValueError("Immediate must fit in 8 bits")
            Src = imm
        else:
            I   = 0
            Src = parse_register(Src_tok)

        return encode_dp(cond, CMD_CODES[base], S, Rn, Rd, I, Src)

    # --- 4) Memory, etc. (unchanged) ---
    if base in MEM_CODES:
        L, B = MEM_CODES[base]
        # rest should be "Rd, [Rn, #imm]"
        rd_str, mem_str = [p.strip() for p in rest.split(',',1)]
        Rd = parse_register(rd_str)
        m = re.match(r'^\[(R\d+)\s*,\s*#(0x[0-9A-Fa-f]+|\d+)\]$', mem_str)
        if not m:
            raise ValueError(f"Bad mem syntax: '{mem_str}'")
        Rn = parse_register(m.group(1))
        off = int(m.group(2), 0)
        if not (0 <= off <= 0xFFF):
            raise ValueError("Mem offset must fit in 12 bits")
        return encode_mem(cond, L, B, Rn, Rd, off)

    # nothing matched
    raise ValueError(f"Unknown instruction '{line}'")


def assemble(source_code):
    lines = [l.strip() for l in source_code.splitlines()]
    labels = {}
    prog = []
    addr = 0

    # first pass: collect labels
    for l in lines:
        if not l or l.startswith(';'):
            continue
        if ':' in l:
            lbl, rest = l.split(':',1)
            labels[lbl.strip()] = addr
            l = rest.strip()
        if l:
            prog.append((addr, l))
            addr += 4

    # second pass: encode
    mc = []
    for addr, line in prog:
        instr = assemble_line(line, addr, labels)
        if instr is not None:
            mc.append(instr)
    return mc

def save_hex(machine_code, filename):
    with open(filename, 'w') as f:
        for instr in machine_code:
            f.write(f"{instr:08X}\n")
