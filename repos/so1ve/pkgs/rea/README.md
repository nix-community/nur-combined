# REA

The official [REA](https://github.com/morluto/rea) CLI and MCP server, packaged
from the published `rea-agents` npm release with Node.js 24. Dependencies,
terminal addons and Frida's matching native addon are pinned in Nix; starting
REA does not download npm packages.

```sh
nix run .#rea -- --version
nix run .#rea -- mcp
```

The matching workflow is installed at
`share/rea/node_modules/rea-agents/skills/reverse-engineer-anything`.
Native analysis engines such as Ghidra, IDA and Hopper are separate installations.

## DeepSeek Harness

```nix
let
  rea = (import inputs.so1ve { inherit pkgs; }).rea;
in
{
  home.packages = [ rea ];
  home.file.".dsh/skills/reverse-engineer-anything".source =
    "${rea}/share/rea/node_modules/rea-agents/skills/reverse-engineer-anything";

  programs.deepseek-harness.cordisPatch = [
    {
      insert = [
        {
          id = "rea-mcp";
          name = "@deepseek-ai/dsh-mcp-client";
          config = {
            serverName = "rea";
            transport = "stdio";
            command = "${rea}/bin/rea";
            args = [ "mcp" ];
            toolCallTimeoutMs = 450000;
            reconnect.enabled = false;
          };
        }
      ];
    }
  ];
}
```

Restart dsh after applying the configuration. REA tools use the
`mcp__rea__` prefix. Automatic reconnection is disabled because restarting REA
loses its active analysis sessions.

## Updating

```sh
nix run .#update -- rea
```

The updater locks the npm release and derives Frida's native addon version from
that lock file, for both Linux architectures supported by this repository.
