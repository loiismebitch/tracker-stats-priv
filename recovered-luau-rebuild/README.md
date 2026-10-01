# Senz Hub

Roblox Studio-safe rebuild of the recovered Luau project.

## Run

1. Open Roblox Studio.
2. Go to `StarterPlayer > StarterPlayerScripts`.
3. Add a `LocalScript` named `SenzHub`.
4. Paste `src/SenzHub.client.lua`.
5. Press **Play**.

Press **RightShift** to toggle the menu.

## Menu

- Dashboard
- Path2D demo
- Runtime information
- About / reconstruction status

## Rojo

Run:

```bash
rojo serve
```

The project maps `src/SenzHub.client.lua` to `StarterPlayerScripts/SenzHub`.

## Analysis files

The `analysis/` and `docs/` directories keep the recovered VM/runtime material used during reconstruction.

This Studio build does not use `loadstring`, executor-only APIs, or remote-code execution.
