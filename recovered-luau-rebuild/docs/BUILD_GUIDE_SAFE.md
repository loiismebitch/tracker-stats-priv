# Build guide: recovered Luraph code -> Roblox Studio-safe Luau

## What is already recovered

The wrapper/payload has been decoded far enough to recover 55 prototypes and 10,413 virtual instructions, plus a runtime/constant table. The semantic reconstruction still contains register-level control flow and therefore is not yet source-equivalent Luau.

The current payload reconstruction still contains:

- 107 unresolved `OP_*` placeholders
- 52 `UP[...]` accesses that need named upvalues
- 35 `WRITE_CAPTURE_BOX(...)` operations that need lexical-variable reconstruction
- 1,537 `goto` statements and 1,102 labels
- 17 references to `RUNTIME_INTERNAL_0`

Roblox Luau source should not be built directly from this IR. It needs control-flow structuring first.

## Do not copy the protector back

`P01` and especially `P02` contain environment bootstrap, integrity checks, VM plumbing and executor/protector probes. A normal Studio rebuild should not reproduce those layers. Port the actual application behaviour instead.

The recovered runtime contains executor/protector-oriented symbols including `identifyexecutor`, `islclosure`, `iscclosure`, `loadstring`, `getfenv`, and `setfenv`. The Studio-safe shim intentionally blocks these rather than emulating them.

## Porting algorithm

For each payload prototype:

1. Start at the first reachable label.
2. Follow unconditional `goto` chains and collapse trampoline blocks.
3. Convert a conditional pair such as `if ... then goto A end; goto B` into `if/else`.
4. Convert recovered `FORPREP/FORLOOP` pairs into `for` loops.
5. Replace register aliases with names based on use.
6. Replace `UP[n]` with a lexical upvalue only after tracing the capture mapping.
7. Replace `WRITE_CAPTURE_BOX(upN, value)` with assignment to that lexical variable.
8. Resolve every remaining `OP_*` from `analysis/recovered_opcode_map.md`.
9. Remove unreachable anti-tamper/dead blocks only after reachability is proven.
10. Run the port in Studio with networking disabled until all `HttpService` call sites have been reviewed.

## Roblox Studio layout

```
StarterPlayer
└─ StarterPlayerScripts
   ├─ RecoveredMain
   └─ RuntimeSafe
```

## Validation sequence

1. Make sure the scaffold loads with no executor/protector code.
2. Port one prototype at a time.
3. Add assertions around inputs/outputs of the newly ported function.
4. Compare its outputs to values visible in the register-level IR.
5. Only then connect it to the next recovered function.
6. Review any `HttpService` method before enabling it.
