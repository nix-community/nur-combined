{
  sources,

  lib,

  ghidra,
  makeWrapper,
  python3,
}:
let
  python' = python3.withPackages (p: with p; [ mcp ]);
in
ghidra.buildGhidraExtension {
  inherit (sources.ghidra-mcp) pname src;
  version = lib.removePrefix "v" sources.ghidra-mcp.version;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib/Ghidra/Extensions,bin}
    unzip -d $out/lib/Ghidra/Extensions build/distributions/*.zip
    cp bridge_mcp_ghidra.py $out/lib/Ghidra/Extensions/GhidraMCP

    makeWrapper ${lib.getExe python'} $out/bin/bridge-mcp-ghidra \
      --add-flag $out/lib/Ghidra/Extensions/GhidraMCP/bridge_mcp_ghidra.py

    runHook postInstall
  '';

  meta = {
    description = "Production-ready Model Context Protocol (MCP) server that bridges Ghidra's powerful reverse engineering capabilities with modern AI tools and automation frameworks";
    homepage = "https://github.com/bethington/ghidra-mcp";
    license = lib.licenses.asl20;
    inherit (ghidra.meta) platforms;
    mainProgram = "bridge-mcp-ghidra";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
