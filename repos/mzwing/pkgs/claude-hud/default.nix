# Claude Code statusline plugin, compiled from TypeScript; $out doubles as the plugin root Claude Code loads.
{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_24,
  source,
}: let
  version = lib.removePrefix "v" source.version;
in
  buildNpmPackage {
    inherit (source) pname src;
    inherit version;

    nodejs = nodejs_24;

    # Refreshed by update-hashes.
    npmDepsHash = "sha256-+gl22+ufAR8Oo1tY9xvQ3VR3RQbKSmD6pNSRMV3Mg+k=";

    nativeBuildInputs = [makeWrapper];

    # npm run build deletes the dist/ upstream CI commits and recompiles it from src/.

    installPhase = ''
      runHook preInstall

      # Claude Code loads the plugin from $out itself, so the manifest and commands stay at the root.
      mkdir -p $out
      cp -r .claude-plugin commands dist $out/

      # dist/*.js are ESM; node reads the module type from this package.json.
      install -Dm644 package.json $out/package.json

      makeWrapper ${lib.getExe nodejs_24} $out/bin/claude-hud \
        --add-flags $out/dist/index.js

      install -Dm644 LICENSE README.md -t $out/share/doc/claude-hud

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      grep -qF '"version": "${version}"' $out/.claude-plugin/plugin.json
      test -f $out/commands/setup.md
      test -f $out/commands/configure.md

      # The statusline renders one frame per stdin payload; this is upstream's own smoke input.
      echo '{"model":{"display_name":"Opus"},"context_window":{"current_usage":{"input_tokens":45000},"context_window_size":200000},"transcript_path":"/nonexistent/transcript.jsonl"}' |
        $out/bin/claude-hud | grep -qF Opus

      test -f $out/share/doc/claude-hud/LICENSE
      test -f $out/share/doc/claude-hud/README.md

      runHook postInstallCheck
    '';

    meta = {
      description = "Real-time statusline HUD for Claude Code";
      homepage = "https://github.com/jarrodwatts/claude-hud";
      changelog = "https://github.com/jarrodwatts/claude-hud/releases/tag/${source.version}";
      license = lib.licenses.mit;
      mainProgram = "claude-hud";
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
