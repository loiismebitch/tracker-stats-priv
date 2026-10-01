# recovered-luau-rebuild

A repository-ready reconstruction workspace for a virtualized/obfuscated Luau payload.

## Status

This branch contains two distinct layers:

- `src/`: a **Roblox Studio-safe scaffold**. It deliberately does not recreate executor/exploit-only primitives.
- `analysis/`: recovered VM/runtime metadata used to continue reconstructing the original program logic.

The reconstruction is **not yet a byte-for-byte recovery of the original source**. Original local variable names, comments, formatting, and some VM-level semantics were destroyed by virtualization and cannot be recovered verbatim.

## Layout

```text
src/
  RuntimeSafe.lua
  RecoveredMain.client.lua
analysis/
  recovered_runtime_table.lua
  recovered_opcode_map.md
docs/
  BUILD_GUIDE_SAFE.md
  reconstruction_status.tsv
default.project.json
```

## Roblox Studio / Rojo

With Rojo installed:

```bash
rojo serve
```

Then connect the Rojo Studio plugin to the local server.

- `src/RecoveredMain.client.lua` -> `StarterPlayer/StarterPlayerScripts/RecoveredMain`
- `src/RuntimeSafe.lua` -> `StarterPlayer/StarterPlayerScripts/RuntimeSafe`

See `docs/BUILD_GUIDE_SAFE.md` for the current porting/reconstruction workflow.
