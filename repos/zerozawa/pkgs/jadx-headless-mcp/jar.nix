{
  lib,
  stdenvNoCC,
  jadx-headless-mcp,
}:
# The fat jar inside `jadx-headless-mcp`'s output, re-exported as a package of
# its own so an MCP client entry can point straight at an absolute path:
#
#   java -jar $(nix build .#jadx-headless-mcp-jar --print-out-paths)
#
# `$out` is a symlink into the parent output, so nothing is duplicated in the
# store and no extra Gradle run is needed — the parent already builds shadowJar.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jadx-headless-mcp-jar";
  version = jadx-headless-mcp.version;

  dontUnpack = true;
  # The output is a symlink to the jar; keep fixup from following it.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    # Fails loudly if upstream ever renames the artifact or stops emitting it.
    ln -s ${jadx-headless-mcp}/share/java/*-all.jar $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "Portable fat jar of jadx-headless-mcp for `java -jar` MCP client entries";
    homepage = "https://github.com/1013503897/jadx-headless-mcp";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    platforms = platforms.unix;
  };
})
