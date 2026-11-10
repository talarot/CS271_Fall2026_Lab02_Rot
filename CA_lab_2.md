# Lab 2: Armv8-A Instruction Encoding

## 1. Introduction
### 1.1 Lab overview
At the end of this lab, you will be able to:
- Use GNU Toolchain to obtain instruction encodings in a human-readable format.
- Categorize the Armv8-A AArch64 instruction encodings according to respective bit fields.
- Identify what some of the AArch64 instruction encoding fields mean.
- Demonstrate how the Armv8-A instructions encode immediate values.
- Compare Armv8-A instruction alias with their respective base instructions.

## 2. Requirements
Before attempting this lab, ensure that you have already completed the installation instructions in the Getting Started Guide provided with this course.
The prerequisites for this lab are:
- Familiarity with Arm assembly
- Verilog

This lab includes an instructor-provided reference program in `reference-lab01/`; use it for the encoding analysis. It deliberately does not depend on files in your personal Lab 01 repository.

---

## 3. Instruction encodings
The Armv8-A instructions have a fixed width of 32 bits. Each instruction is encoded in terms of 32 bits of 1s and 0s. A processor running these instructions will have to decode these encodings.

### 3.1 Task: Obtaining encodings
In Lab 1, we used the `objcopy` command to obtain these encodings in a Verilog Memory Model hexadecimal format. These encodings are then read into the “instruction memory” in the Arm Education Core testbench file. The processor then decodes these encodings and executes them accordingly.

To obtain the instruction encodings in a more human-readable format, we shall use the `objdump` tool that is provided with the GNU Toolchain. Follow these steps:
1. In the Codespaces terminal, from this repository's root, run:
   ```bash
   make reference
   ```
   This command assembles the reference program and creates `reference-lab01/test_lab01.o`, `reference-lab01/test_lab01.mem`, and `reference-lab01/test_lab01_disassembly.log`.
2. Open `reference-lab01/test_lab01_disassembly.log` and compare its instruction encodings with `reference-lab01/test_lab01.mem`. The `make reference` command has already run `objdump`; you do not need to run a separate `objdump` command.
3. You should see the human-readable disassembly along with the hexadecimal instruction encodings.
4. Notice that the `.mem` file stores instructions in Little-Endian byte order (Least Significant Byte first).

---

### 3.2 Exercise: Interpreting the encodings
The following is an approximation of the counted-loop code in the Lab 01 reference program `reference-lab01/test_lab01.s`:

```asm
.global _start
.text
_start:
    MOVZ    X0, #5
    MOVZ    X1, #1
    MOVZ    X4, #0
    MOVZ    X5, #0
sum_loop:
    ADD     X4, X4, X0
    ADD     X5, X5, X1
    SUBS    X0, X0, X1
    B.NE    sum_loop
    YIELD
```

In this exercise, we will decode some of the Armv8-A instructions used, specifically:
- `MOVZ`
- `ADD`
- `SUBS`
- `B.NE`

Based on the disassembly log generated in *Section 3.1*, answer the following questions in `myAnswers.md`.

**For each question, follow these steps:**
1. Find the 8-digit hex encoding next to the instruction in your disassembly log.
2. Convert it to 32 binary digits (4 bits per hex digit).
3. Map each group of bits to the field diagram provided.
4. Record the hex encoding, the binary string, and the field values in `myAnswers.md`.

A worked example using `MOVZ X1, #1` (encoding `d2800021`) is provided at the top of `myAnswers.md` to show you the process.

---

**1. For the instruction `MOVZ X0, #5`**

The full MOVZ encoding layout:

| 31 | 30-29 | 28-23  | 22-21 | 20-5  | 4-0 |
|----|-------|--------|-------|-------|-----|
| sf | 10    | 100101 | hw    | imm16 | Rd  |

The fields describe how the instruction uses its bits:
- `sf` is the size flag: `0` selects 32-bit `W` registers, and `1` selects 64-bit `X` registers. Because this instruction uses `X0`, its `sf` value is `1`.
- `hw` selects which 16-bit portion of the destination register receives the immediate. For an `X` register, `00`, `01`, `10`, and `11` mean shifts of 0, 16, 32, and 48 bits, respectively. `MOVZ` sets the other bits in the destination register to zero.
- `imm16` is the 16-bit immediate constant supplied in the instruction. Here, `#5` is represented by the 16-bit value five.
- `Rd` is the 5-bit destination-register field. It identifies the register that receives the result; `X0` has register number 0.

- What are the values of `sf`, `hw`, `imm16`, and `Rd`?

**2. For the instruction `ADD X4, X4, X0`**

The ADD (shifted register) encoding layout:

| 31 | 30 | 29 | 28-24 | 23-22 | 21 | 20-16 | 15-10 | 9-5 | 4-0 |
|----|----|----|-------|-------|---|-------|-------|-----|-----|
| sf | op | S  | 01011 | shift | 0  | Rm    | imm6  | Rn  | Rd  |

- Bit 21 is reserved and must be `0`; `Rm` occupies bits 20-16. What are the binary values of `Rm`, `Rn`, and `Rd`?

**3. For the instruction `SUBS X0, X0, X1`**

Use the same ADD layout above and compare the two encodings side by side.
- How does the encoding of `SUBS` differ from `ADD` to signal that condition flags should be updated?

**4. For the instruction `B.NE sum_loop`**

The B.cond encoding layout:

| 31-24    | 23-5  | 4 | 3-0  |
|----------|-------|---|------|
| 01010100 | imm19 | 0 | cond |

- What is the integer (two’s complement) value of `imm19`?
- Does the resulting byte offset match the distance between `B.NE` and the `sum_loop` label in the disassembly?

---

## 4. Encoding immediate values in Armv8-A
The Armv8-A AArch64 instructions are 32 bits wide. Encoding immediate values (constant numbers) is constrained by limited space within the instruction encoding.

### 4.1 Logical and bitfield instructions immediate values
The logical instructions (such as `AND`, `ORR`, `EOR`, and `ANDS`) encode their immediate values using only 13 bits in the instruction encoding, split across three fields: N (1 bit), imms (6 bits), and immr (6 bits). This encodes element sizes (2, 4, 8, 16, 32, or 64 bits) which are replicated across the register.

#### Building wide constants with MOVZ and MOVK

Because every AArch64 instruction is exactly 32 bits wide, a single instruction can only carry a 16-bit immediate. To load a value wider than 16 bits into a register, you combine two instructions. `MOVZ` and `MOVK` each target one of four 16-bit slots in a 64-bit register, selected by the `LSL` shift amount:

| bits 63-48 | bits 47-32 | bits 31-16 | bits 15-0 |
|------------|------------|------------|-----------|
| LSL #48    | LSL #32    | LSL #16    | LSL #0    |

`MOVZ` writes the selected slot and **zeros** all other slots.
`MOVK` writes the selected slot and **keeps** all other bits unchanged.

This means you can build any 64-bit constant by chaining one `MOVZ` followed by up to three `MOVK` instructions.

#### Validating Immediate Encodings
Because of this bit-pattern replication rule, you cannot use *any* arbitrary 64-bit number as an immediate for logical instructions.

**Exercise:**

The provided `test_lab02.s` contains the following code:
```asm
.global _start
.text
_start:
    MOVZ    X5, #0xffff
    MOVK    X5, #0x00ff, LSL #16
    AND     X6, X5, #0x00003ffc00003ffc
    ORR     X7, X5, #0x00003ffc00003ffc
    YIELD
```
1. Build and simulate it using `make sim` from the repo root. If the simulation prints `[EDUCORE LOG]: Apollo has landed`, the code assembled and executed correctly. The simulation does not display register values — the questions below are answered by hand-tracing the instructions.
2. Record your answers in `myAnswers.md` under **Section 4.1**:
   - What is the value loaded into X5 after the `MOVZ` and `MOVK` execute? *(Trace through each instruction: what does MOVZ load, and what does MOVK change?)*
   - What is the resulting hexadecimal value of register `X6`? *(Apply the AND bitmask to your X5 value from above.)*
   - What is the resulting hexadecimal value of register `X7`? *(Apply the ORR bitmask to your X5 value from above.)*

---

## 5. Instruction aliases in Armv8-A
The Armv8-A architecture supports instruction aliases, where some constants are assigned to the encoded fields of the base instruction to make popular operations naturally readable.

### Exercise
In the disassembly log (`reference-lab01/test_lab01_disassembly.log`), find the `SUBS X0, X0, X1` instruction.
If you were to write `CMP X0, X1` instead, it is actually an alias for a `SUBS` instruction.
Arm translates `CMP Xn, Xm` to: `SUBS XZR, Xn, Xm`.
The result of the subtraction is discarded in the Zero Register (`XZR`), but the flags are still set for branching!

Record your answers in `myAnswers.md` under **Section 5**.

## 6. Summary
In this lab, we have learned how encodings are interpreted, how constants fit into a 32-bit instruction, and that there are instruction aliases like `CMP` in the Armv8-A ISA.
