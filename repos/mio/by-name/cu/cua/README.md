# CUA (Computer Use Agent)

This package/directory is a placeholder for `cua`, an open-source driver for scaling computer-use fleets.

## Architecture Context

Based on research into LLM Agent VM Nix setups, the optimal architecture for autonomous computer use leverages:
- Declarative NixOS microVMs (`microvm.nix`) for ephemeral, isolated sandboxes.
- Virtiofs for persistent host directory mapping without compromising the security boundary.
- Headless X Virtual Framebuffer (Xvfb) restricted to 1024x768 resolution to balance token usage and UI fidelity.
- Model Context Protocol (MCP) servers (e.g., Anthropic's `computer_toolset_20260801`) to translate LLM decisions into mechanical inputs.

## Models
- **Commercial:** Claude Fable 5.1 with dynamic prompt caching to handle extensive context efficiently.
- **Local:** Qwen2.5-VL served via SGLang (utilizing RadixAttention for prompt caching) or hybrid grounding approaches using OmniParser V2.

## Usage Examples

You can run the default CUA agent sandbox configuration directly from this repository:

```bash
nix run .#cua
```

To configure specific parameters (e.g., memory, CPUs, or the agent start command), you apply overrides directly in your Nix expressions. 

**Example Nix Configuration:**
```nix
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.cua.override {
      memorySize = 8192;
      cpus = 4;
      hypervisor = "cloud-hypervisor";
      agentStartCommand = "claude-code --mcp-server";
      useVirtiofs = true;
    })
  ];
}
```

*Note: This architecture ensures maximum security against indirect prompt injection by using ephemeral VM states.*
