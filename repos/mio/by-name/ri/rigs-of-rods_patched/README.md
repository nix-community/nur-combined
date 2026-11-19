# rigs-of-rods_patched

`rigs-of-rods` plus the community native **macOS / Apple Silicon** port.

## Upstream

- Tracking issue: https://github.com/RigsOfRods/rigs-of-rods/issues/2981
- Apple Silicon PoC: https://github.com/RigsOfRods/rigs-of-rods/issues/3465
- Port PR (closed for `AI_POLICY.md`, still the usable tree):
  https://github.com/RigsOfRods/rigs-of-rods/pull/3484
- Source fork: https://github.com/aasaasaasss/rigs-of-rods-apple-silicon
  (`3749713f1f81704843222e66263d89f618fb65a5`, tagged upstream as v0.3 work)

## What the port adds

- Cocoa app lifecycle / event pump (`MacOS.mm`)
- `_NSGetExecutablePath` and macOS OpenAL Soft includes
- GLSL terrain / nicemetal / SkyX paths without NVIDIA Cg on arm64
- CMake Apple frameworks and FindMyGUI wiring

Nix packaging patches from `rigs-of-rods` (data-dir env, MyGUI string_view,
curl/rornet includes, etc.) are kept and still apply on this tree.
