// Instructor-provided Lab 01 counted-loop reference for Lab 02 encoding analysis.
// This reference is not a student submission.
    .text
    .global _start
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
