# Lab 02 My Answers
**Student Name:** TALA ROT

---

## How to decode an instruction encoding

For each question below, find the hex encoding in your disassembly log, convert it to 32-bit binary, then fill in each field using the bit layout diagram.

**Worked Example: `MOVZ X1, #1` (encoding: `d2800021`)**

Step 1 — Convert hex to binary (4 bits per digit):
```
d    2    8    0    0    0    2    1
1101 0010 1000 0000 0000 0000 0010 0001
```

Step 2 — Map bits to the MOVZ field layout:

| 31 | 30-29 | 28-23  | 22-21 | 20-5             | 4-0   |
|----|-------|--------|-------|------------------|-------|
| sf | 10    | 100101 | hw    | imm16            | Rd    |
| 1  | 10    | 100101 | 00    | 0000000000000001 | 00001 |

The fields describe how the instruction uses its bits:
- `sf` is the size flag: `0` selects 32-bit `W` registers, and `1` selects 64-bit `X` registers. Because this instruction uses `X1`, its `sf` value is `1`.
- `hw` selects which 16-bit portion of the destination register receives the immediate. For an `X` register, `00`, `01`, `10`, and `11` mean shifts of 0, 16, 32, and 48 bits, respectively. `MOVZ` sets the other bits in the destination register to zero.
- `imm16` is the 16-bit immediate constant supplied in the instruction. Here, `#1` is represented by the 16-bit value one.
- `Rd` is the 5-bit destination-register field. It identifies the register that receives the result; `X1` has register number 1, encoded as `00001`.

Step 3 — Identify each field:
- `sf` = 1 → 64-bit register
- `hw` = 00 → no shift (LSL #0)
- `imm16` = 0000000000000001 = 1
- `Rd` = 00001 = X1

---

## Section 3.2 — Interpreting Instruction Encodings

---

**1. `MOVZ X0, #5`**
d28000a0
Hex encoding (from disassembly log): `0x`

Binary (32-bit):
```
_D    _2    _8    _0    _0    _0   _A    _0
1101  0010  1000  0000  0000  0000 1010 0000
```

| 31 | 30-29 | 28-23  | 22-21 | 20-5  | 4-0 |
|----|-------|--------|-------|-------|-----|
| sf | 10    | 100101 | hw    | imm16 | Rd  |
| 1  |  10   | 100101 | 00    | 000 0000 0000 101 | 00000 |

- `sf` = 1
- `hw` = 10
- `imm16` = 00000000000101
- `Rd` = 00000

---

**2. `ADD X4, X4, X0`**

Hex encoding (from disassembly log): `0x`

Binary (32-bit):
```
8b000084
8    B    0    0    0    0    8    4
1000 1011 0000 0000 0000 0000 1000 0100
```

| 31 | 30 | 29 | 28-24 | 23-22 | 21 | 20-16 | 15-10 | 9-5 | 4-0 |
|----|----|----|-------|-------|---|-------|-------|-----|-----|
| sf | op | S  | 01011 | shift | 0  | Rm    | imm6  | Rn  | Rd  |
|  1 | 0  | 0  |       | 00    |    | 0000 | 00000 | 00100 | 00100 |
   1   0    0            00          0000.    00000. 00100.  00100
- `Rm` (binary) = 00000
- `Rn` (binary) = 00100
- `Rd` (binary) = 00100

---

**3. `SUBS X0, X0, X1`**

Hex encoding (from disassembly log): `0x`

Binary (32-bit):
```
eb010000
E    B    0    1    0    0    0    0
1110 1011 0000 0001 0000 0000 0000 0000
```

| 31 | 30 | 29 | 28-24 | 23-22 | 21 | 20-16 | 15-10 | 9-5 | 4-0 |
|----|----|----|-------|-------|---|-------|-------|-----|-----|
| sf | op | S  | 01011 | shift | 0  | Rm    | imm6  | Rn  | Rd  |
|  1 |  1 | 1  | 01011 | 00    | 0  | 00001 | 000000| 00000|00000|

Compare the `op` and `S` bits to `ADD` above:
- How does the encoding differ to signal that condition flags should be updated?
Converting the S to 1 indicate that the condition flag should be updated. 
---

**4. `B.NE sum_loop`**

Hex encoding (from disassembly log): `0x`

Binary (32-bit):
```
_    _    _    _    _    _    _    _
____ ____ ____ ____ ____ ____ ____ ____
```

| 31-24    | 23-5  | 4 | 3-0  |
|----------|-------|---|------|
| 01010100 | imm19 | 0 | cond |
|          |       |   |      |

- `imm19` (binary) =
- `imm19` as a two's complement integer =
- Byte offset (imm19 × 4) =
- `B.NE` address (from disassembly) =
- `sum_loop` address (from disassembly) =
- Do they match?

---

## Section 4.1 — Logical Immediate Values

`MOVZ` and `MOVK` each write a 16-bit immediate into one of four slots in a 64-bit register. The `LSL` shift selects which slot:

| bits 63-48 | bits 47-32 | bits 31-16 | bits 15-0 |
|------------|------------|------------|-----------|
| LSL #48    | LSL #32    | LSL #16    | LSL #0    |

`MOVZ` writes the selected slot and **zeros** all others.
`MOVK` writes the selected slot and **keeps** all other bits unchanged.

Use this layout to trace the value of X5 step by step before answering.

---

**X5** (after `MOVZ` + `MOVK`):
`X5 = 0x`

**X6** (after `AND X6, X5, #0x00003ffc00003ffc`):
`X6 = 0x`

**X7** (after `ORR X7, X5, #0x00003ffc00003ffc`):
`X7 = 0x`

---

## Section 5 — Instruction Aliases

- What is the base instruction that `CMP X0, X1` translates to?
- What is the full expanded form (including all operands)?
