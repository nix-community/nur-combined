# alpaca: llama-cpp llm client
# - super simple, easy UI
#
# shortcomings (as of 6.1.7, 2025-07-23):
# - doesn't seem to do any prompt tuning;
#   inherits all the pathologies of the underlying model (e.g. makes up citations)
#
# it creates a config dir, `~/.config/com.jeffser.Alpaca`, but apparently empty.
# the actual config (and chat state) is held in a relatively simple sqlite database.
{ config, lib, pkgs, ... }:
let
  # deskoHostname = if config.networking.hostName == "desko" then
  #   "127.0.0.1"
  # else
  #   config.sane.hosts.by-name.desko.wg-home.ip
  # ;
  deskoHostname = config.sane.hosts.by-name.desko.wg-home.ip;
  llamaCppHost = "http://${deskoHostname}:11435";
  llamaCppInstanceId = "20260227100437991096899573eb7ac545abaf08e318fb45e5c9";
  llamaCppType = "openai:generic";
  llamaCppModels = map (p: lib.removeSuffix ".gguf" p.name) [
    # keep synchronized with modules/services/llama-cpp.nix
    # pkgs.mlModels.glm-4_7-flash
    pkgs.mlModels.gemma-4-12b-it-iq4_nl
    pkgs.mlModels.gemma-4-12b-it-iq4_xs
    pkgs.mlModels.gemma-4-12b-it-q3_k_m
    pkgs.mlModels.gemma-4-12b-it-q3_k_s
    pkgs.mlModels.gemma-4-12b-it-q4_k_m
    pkgs.mlModels.gemma-4-12b-it-q4_k_s
    pkgs.mlModels.gemma-4-12b-it-ud-iq3_xxs
    pkgs.mlModels.gemma-4-12b-it-ud-q3_k_xl
    pkgs.mlModels.gemma-4-12b-it-ud-q4_k_xl
    pkgs.mlModels.gpt-oss-20b
    # pkgs.mlModels.minimax-m2_5
    pkgs.mlModels.nemotron-3-nano-4b
    # pkgs.mlModels.nemotron-3-nano-30b-a3b
    # pkgs.mlModels.omnicoder-9b
    # pkgs.mlModels.qwen3_5-35b-a3b
    # pkgs.mlModels.qwen3_5-9b
    # pkgs.mlModels.qwen3_5-4b-claude-4_6-opus-reasoning-distilled-v2
    # pkgs.mlModels.qwen3_5-9b-claude-4_6-opus-reasoning-distilled-v2-q4_k_m
    pkgs.mlModels.qwen3_5-9b-claude-4_6-opus-reasoning-distilled-q3_k_m
    # pkgs.mlModels.qwen3_5-27b-claude-4_6-opus-reasoning-distilled-v2
    pkgs.mlModels.qwen3_6-27b-mtp-q4_k_m
  ];
  llamaCppProperties = {
    api = "NOKEY";
    default_model = lib.removeSuffix ".gguf" pkgs.mlModels.gemma-4-12b-it-ud-q3_k_xl;
    max_tokens = 32768.0;
    name = "deskoLlamaCpp";
    override_parameters = false;
    seed = 0.0;
    temperature = 0.7;
    title_model = null;
    url = llamaCppHost;
  };
  defaultDb = pkgs.runCommand "alpaca-default-db" {
    nativeBuildInputs = with pkgs; [
      sqlite
    ];
  } ''
    set -x
    # schema taken from <repo:jeffser/Alpaca:src/sql_manager.py>
    cat <<EOF >> create.sql
    CREATE TABLE instance (
      id TEXT NOT NULL PRIMARY KEY,
      pinned INTEGER NOT NULL,
      type TEXT NOT NULL,
      properties TEXT NOT NULL
    );
    CREATE TABLE online_instance_model_list (
      id TEXT NOT NULL PRIMARY KEY,
      list TEXT NOT NULL
    );
    INSERT INTO instance (id, pinned, type, properties) VALUES (
      '${llamaCppInstanceId}',
      0,
      '${llamaCppType}',
      '${builtins.toJSON llamaCppProperties}'
    );
    INSERT INTO online_instance_model_list (id, list) VALUES (
      '${llamaCppInstanceId}',
      '${builtins.toJSON llamaCppModels}'
    );
    EOF
    sqlite3 alpaca.db "$(cat create.sql)"

    mkdir $out
    cp alpaca.db $out
  '';
in
{
  sane.programs.alpaca = {
    packageUnwrapped = (pkgs.alpaca.override {
      # ollama is only added to `PATH`; since i'm using it via http, remove it here.
      # fixes cross compilation & simplifies closure.
      ollama = null;
      python3Packages = pkgs.python3Packages.overrideScope (self: super: {
        markitdown = null;  #< XXX(2025-12-07): does not cross compile (markitdown -> speechrecognition -> onnxruntime)
        opencv4 = null;  #< XXX(2025-10-11): doesn't cross compile. or, fails at import time: "OpenCV loader: missing configuration file: ..."
        rembg = null;  #< XXX(2025-10-11): pulls in opencv, which doesn't cross compile; marked as optional-dependency
        openai-whisper = null;  #< XXX(2025-10-11): doesn't cross compile; marked as optional-dependency
        spacy-models.en_core_web_sm = null;  #< XXX(2025-10-11): doesn't cross compile; marked as optional-dependency
        kokoro = null;  #< XXX(2025-10-11): doesn't cross compile; marked as optional-dependency
      });
    }).overrideAttrs (upstream: {
      # add missing direct dependencies that were previously smuggled via
      # one of the null'd dependencies above.
      propagatedBuildInputs = upstream.propagatedBuildInputs ++ [
        pkgs.python3Packages.beautifulsoup4
      ];

      postPatch = (upstream.postPatch or "") + ''
        substituteInPlace data/meson.build \
          --replace-fail \
            "('glib-compile-schemas', required: true, disabler: true)" \
            "('glib-compile-schemas', required: true, disabler: true, native: true)"

        # for nulled dependencies (above), patch so the application only errors
        # at runtime, on first attempted use.
        substituteInPlace src/widgets/attachments.py \
          --replace-fail 'from markitdown'  '# from markitdown'
        substituteInPlace src/widgets/activities/web_browser.py \
          --replace-fail 'from markitdown'  '# from markitdown'
        substituteInPlace src/widgets/blocks/table.py \
          --replace-fail 'import pandas'  '# inport pandas'

        substituteInPlace src/widgets/activities/camera.py \
          --replace-fail 'import cv2,'  'import'
      '';

      passthru = (upstream.passthru or {}) // {
        inherit defaultDb;
      };
    });
    buildCost = 2;  #< liable to break cross during updates; not important enough to block deploy over

    sandbox.net = "all";  # should be `vpn.wg-home` but would require bunpen to forward ports to the host, for desko.
    sandbox.whitelistWayland = true;
    sandbox.matplotlibCacheDir = ".cache/com.jeffser.Alpaca/matplotlib";
    sandbox.mesaCacheDir = ".cache/com.jeffser.Alpaca/mesa";

    sandbox.whitelistDbus.user.own = [
      "com.jeffser.Alpaca"
      "com.jeffser.Alpaca.Service"
    ];
    sandbox.whitelistPortal = [
      "OpenURI"
    ];
    sandbox.whitelistSendNotifications = true;

    # persist.byStore.private = [
    #   # alpaca.db: sqlite3 database with the following tables:
    #   # - attachment
    #   # - chat
    #   # - instances
    #   # - message
    #   # - model_preferences
    #   # - preferences
    #   # - tool_parameters
    #   ".local/share/com.jeffser.Alpaca"
    # ];

    # N.B.: needs to be a file, not a symlink, else Alpaca crashes on launch.
    fs.".local/share/com.jeffser.Alpaca/alpaca.db".file.copyFrom = "${defaultDb}/alpaca.db";

    gsettings."com/jeffser/Alpaca" = {
      skip-welcome = true;
      last-notice-seen = "Alpaca8";
      selected-instance = llamaCppInstanceId;
    };
    # gsettingsPersist = [ "com/jeffser/Alpaca" ];  # for `selected-instance`
  };
}
