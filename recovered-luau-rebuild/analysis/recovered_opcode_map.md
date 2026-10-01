# Recovered Luraph VM opcode map

High-frequency recovered dispatcher semantics:

| Opcode | Uses | Recovered semantic |
|---:|---:|---|
| 12 | 102 | `FORLOOP` |
| 14 | 103 | `FORPREP` |
| 24 | 25 | function call with multiret/top update |
| 51 | 52 | conditional jump on false |
| 58 | 30 | close upvalues + return |
| 61 | 50 | load global from ENV |
| 62 | 222 | read upvalue |
| 65 | 101 | zero-arg call |
| 66 | 157 | two-arg call |
| 90 | 130 | vararg-range call |
| 100 | 955 | load constant |
| 107 | 73 | one-arg call |
| 115 | 139 | table field write |
| 124 | 289 | inequality conditional jump |
| 128 | 186 | <= conditional jump |
| 135 | 2719 | unconditional jump |
| 173 | 173 | table field write from register |
| 181 | 188 | indexed upvalue read |
| 187 | 666 | table field read |
| 188 | 36 | capture-box write |
| 194 | 155 | >= conditional jump |
| 195 | 824 | register move |
| 197 | 43 | method/self load |
| 198 | 45 | addition |
| 199 | 153 | indexed table read |
| 202 | 53 | closure creation |
| 209 | 52 | two-argument function call |

Raw jumps land at operand+1 because the dispatcher increments `PC` after each instruction.
