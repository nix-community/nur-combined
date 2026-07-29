{
  sources,

  lib,

  ghidra,
  makeWrapper,
  python3Packages,
  symlinkJoin,
}:
symlinkJoin {
  name = "ghidra-mcp";
  paths = [
    (python3Packages.buildPythonApplication {
      pname = "ghidra-mcp-bridge";
      version = lib.removePrefix "v" sources.ghidra-mcp.version;
      inherit (sources.ghidra-mcp) src;

      pyproject = true;

      build-system = with python3Packages; [ hatchling ];

      dependencies = [
        (python3Packages.mcp.overrideAttrs (_: {
          version = lib.removePrefix "v" sources.python-mcp.version;
          inherit (sources.python-mcp) src;
        }))
      ];
    })

    (ghidra.buildGhidraExtension {
      inherit (sources.ghidra-mcp) pname src;
      version = lib.removePrefix "v" sources.ghidra-mcp.version;

      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{lib/Ghidra/Extensions,bin}
        unzip -d $out/lib/Ghidra/Extensions build/distributions/*.zip

        runHook postInstall
      '';
    })
  ];

  meta = {
    description = "Production-ready Model Context Protocol (MCP) server that bridges Ghidra's powerful reverse engineering capabilities with modern AI tools and automation frameworks";
    homepage = "https://github.com/bethington/ghidra-mcp";
    license = lib.licenses.asl20;
    inherit (ghidra.meta) platforms;
    mainProgram = "bridge-mcp-ghidra";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
