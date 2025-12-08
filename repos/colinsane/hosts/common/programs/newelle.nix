# newelle: ollama llm client
# - does some extra prompt tuning beyond ollama's defaults,
#   to decrease pathologies
# - intelligent formatting of model output (e.g. latex, markdown)
#
# shortcomings (as of 2025-07-23):
# - poorly adapts to very narrow screens.
#   - usable, but e.g. the "post" button (and the window close button) is cut off
# - closing the UI does not fully exit the process
#   - presumably it's sitting in the background, waiting to be dbus-activated
# - launch is delayed quite a while on moby:
#   > Matplotlib is building the font cache; this may take a moment.
{ pkgs, ... }:
{
  sane.programs.newelle = {
    packageUnwrapped = (pkgs.newelle.override {
      python3Packages = pkgs.python3Packages // {
        # XXX(2025-07-23): these don't cross compile; disable them
        # pydub drags in opencv, but only used for text-to-speech (and only for Newelle <= 0.9.8)
        # pydub = null;
        # speechrecognition has a build error due to python3Packages.standard-aifc > python3Packages.audioop
        speechrecognition = null;
        # both of these are blocked on `python3Packages.spacy`
        # llama-index-* is imported, lazily, from handlers/rag/llamaindex_handler.py
        llama-index-core = null;
        llama-index-readers-file = null;
      };
    }).overridePythonAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        # patch out the toplevel speech_recognition imports so that the app
        # is launchable without it.
        # actually trying to use speech recognition will (likely) manifest as a runtime error, instead.
        find . -exec sed -i 's/import speech_recognition/# import speech_recognition/g' '{}' ';'
      '';
    });

    buildCost = 2;  #< liable to break cross during updates; not important enough to block deploy over

    sandbox.net = "all";  # maybe only needs wireguard, actually
    sandbox.whitelistWayland = true;
    sandbox.matplotlibCacheDir = ".cache/Newelle/matplotlib";
    sandbox.mesaCacheDir = ".cache/Newelle/mesa";

    gsettings."io/github/qwersyk/Newelle" = {
      language-model = "ollama";
      # the actual gsettings is HUGE (see ~/.config/glib-2.0/settings/keyfile).
      # this is sliced down, and i'll let Newelle re-populate the omitted data on launch.
      llm-settings = ''
      {
        "ollama": {
          "last_request": 1,
          "models-info": {},
          "model-library": [
            {
              "key": "qwen2.5-abliterate:14b",
              "title": "qwen2.5-abliterate:14b",
              "description": "User added model"
            }
          ],
          "endpoint": "http://10.0.10.22:11434",
          "models": "[[\"qwen2.5-abliterate:14b\", \"qwen2.5-abliterate:14b\"]]",
          "model": "qwen2.5-abliterate:14b"
        }
      }
      '';
      welcome-screen-shown = true;
      # extensions-settings='{"website-reader": {}, "websearch": {}}'
      # tts-voice='{"groq_tts": {"endpoint": "https://api.groq.com/openai/v1/", "instructions": ""}}'
      # stt-settings='{"groq_sr": {"endpoint": "https://api.groq.com/openai/v1/"}}'
      # llm-settings = <json blob>;
      # embedding-settings = <json blob>;
      # llm-secondary-settings = <json blob>;
    };

    persist.byStore.ephemeral = [
      ".cache/Newelle"  # extensions
      ".config/Newelle"  # chat logs
    ];
  };
}

