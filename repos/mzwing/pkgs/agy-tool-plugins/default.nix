{
  lib,
  stdenvNoCC,
  nodejs_24,
  source,
}:
stdenvNoCC.mkDerivation {
  pname = "agy-tool-plugins";
  version = "2.0.0-unstable-${source.date}";
  inherit (source) src;

  postPatch = ''
    substituteInPlace plugins/agy-codemode/mcp_config.json \
      --replace-fail '"command": "node"' '"command": "${lib.getExe nodejs_24}"'
    substituteInPlace plugins/agy-output-guard/hooks.json plugins/agy-rehydrate/hooks.json \
      --replace-fail '"command": "node ' '"command": "${lib.getExe nodejs_24} '
    # codemode only recognises its install dir under ~/.gemini, but cwd resolves the symlink into the store
    substituteInPlace plugins/agy-codemode/scripts/codemode-mcp.mjs \
      --replace-fail '!normCwd.includes("/.gemini/config/plugins")' "!normCwd.startsWith(\"$out/\") && !normCwd.includes(\"/.gemini/config/plugins\")"
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r plugins/agy-codemode plugins/agy-output-guard plugins/agy-rehydrate $out/
    install -Dm644 plugins/README.md -t $out/share/doc/agy-tool-plugins

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
      | ${lib.getExe nodejs_24} $out/agy-codemode/scripts/codemode-mcp.mjs | grep -qF '"name":"codemode"'
    for hook in agy-output-guard/scripts/output-guard-hook.mjs agy-rehydrate/scripts/rehydrate-hook.mjs; do
      echo '{}' | ${lib.getExe nodejs_24} $out/$hook | grep -qxF '{}'
    done

    runHook postInstallCheck
  '';

  meta = {
    description = "Antigravity plugins from agy-tool: codemode sandbox, oversized tool output guard and lossless rehydrate after compaction";
    homepage = "https://github.com/justhil/agy-tool";
    license = lib.licenses.free;
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
