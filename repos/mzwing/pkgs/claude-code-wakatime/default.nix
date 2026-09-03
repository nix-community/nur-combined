# WakaTime time tracking for Claude Code, compiled from TypeScript; $out doubles as the plugin root Claude Code loads.
{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_24,
  wakatime-cli,
  source,
}: let
  version = lib.removePrefix "v" source.version;
in
  buildNpmPackage {
    inherit (source) pname src;
    inherit version;

    nodejs = nodejs_24;

    # Refreshed by update-hashes.
    npmDepsHash = "sha256-c9H0z+macmd/Cpp/k9RwGrORXpPmkDMoX6q44O27Gl8=";

    nativeBuildInputs = [makeWrapper];

    # npm run build recompiles dist/ from src/ and stamps the version upstream leaves stale in .claude-plugin/plugin.json.

    installPhase = ''
      runHook preInstall

      # Claude Code loads the plugin from $out itself, so the manifest and hooks stay at the root.
      mkdir -p $out
      cp -r .claude-plugin hooks dist $out/

      # wakatime-cli on PATH is what keeps the plugin from downloading a copy of it into ~/.wakatime.
      makeWrapper ${lib.getExe nodejs_24} $out/bin/claude-code-wakatime \
        --add-flags $out/dist/index.js \
        --prefix PATH : ${lib.makeBinPath [wakatime-cli]}

      # hooks.json runs $CLAUDE_PLUGIN_ROOT/scripts/run, and upstream's copy of it searches $PATH for node,
      # falling back to `nix run nixpkgs#nodejs` once per hook event.
      mkdir -p $out/scripts
      ln -s $out/bin/claude-code-wakatime $out/scripts/run

      install -Dm644 LICENSE README.md -t $out/share/doc/claude-code-wakatime

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      grep -qF '"version": "${version}"' $out/.claude-plugin/plugin.json
      grep -qF '/scripts/run' $out/hooks/hooks.json

      # Every hook feeds one JSON payload to the runner; a transcript that does not exist keeps this
      # to a no-op that still has to resolve node and wakatime-cli, which the debug log then names.
      hookHome=$(mktemp -d)
      printf '[settings]\ndebug = true\n' >"$hookHome/.wakatime.cfg"
      echo '{"hook_event_name":"Stop","transcript_path":"/nonexistent/transcript.jsonl"}' |
        HOME="$hookHome" $out/scripts/run
      grep -qF '${wakatime-cli}/bin/wakatime-cli' "$hookHome/.wakatime/claude-code.log"

      test -f $out/share/doc/claude-code-wakatime/LICENSE
      test -f $out/share/doc/claude-code-wakatime/README.md

      runHook postInstallCheck
    '';

    meta = {
      description = "WakaTime plugin for Claude Code";
      homepage = "https://github.com/wakatime/claude-code-wakatime";
      changelog = "https://github.com/wakatime/claude-code-wakatime/releases/tag/${source.version}";
      license = lib.licenses.bsd3;
      mainProgram = "claude-code-wakatime";
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
