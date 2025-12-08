# alpaca: ollama llm client
# - super simple, easy UI
#
# shortcomings (as of 6.1.7, 2025-07-23):
# - doesn't seem to do any prompt tuning;
#   inherits all the pathologies of the underlying model (e.g. makes up citations)
#
# it creates a config dir, `~/.config/com.jeffser.Alpaca`, but apparently empty
#
# TODO: configure ollama connection details statically
# - until then, on first run:
#   - select the non-"managed" ollama option.
#   - connect to http://10.0.10.22:11434
{ pkgs, ... }:
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
    });
    buildCost = 2;  #< liable to break cross during updates; not important enough to block deploy over

    sandbox.net = "all";  # maybe only needs wireguard, actually
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

    persist.byStore.private = [
      # alpaca.db: sqlite3 database with the following tables:
      # - attachment
      # - chat
      # - instances
      # - message
      # - model_preferences
      # - preferences
      # - tool_parameters
      ".local/share/com.jeffser.Alpaca"
    ];

    gsettings."com/jeffser/Alpaca" = {
      skip-welcome = true;
      last-notice-seen = "Alpaca8";
      # selected-instance = ...
    };
    gsettingsPersist = [ "com/jeffser/Alpaca" ];  # for `selected-instance`
  };
}
