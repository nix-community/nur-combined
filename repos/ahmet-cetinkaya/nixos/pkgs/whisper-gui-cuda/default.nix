# Pikurrot/whisper-gui - Gradio web UI for WhisperX transcription.
#
# Packaged declaratively by reusing nixpkgs' curated CUDA Python stack
# (whisperx, torch, ctranslate2, pyannote-audio, ...) instead of the upstream
# conda/pip wizard. The upstream repo is a plain collection of Python scripts
# (entry point: `python main.py --autolaunch`), so we vendor the source and
# wrap `main.py` with a launcher that provisions a writable working directory.
#
# NOTE: whisperx already propagates ctranslate2, faster-whisper, pyannote-audio,
# torch, torchaudio, transformers, nltk, numpy, pandas and omegaconf, so the
# Python environment mainly needs whisperx + gradio + onnxruntime on top.
{
  lib,
  stdenvNoCC,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  runtimeShell,
  coreutils,
  ffmpeg,
  python3,
  cudaPackages,
}: let
  pythonEnv = python3.withPackages (ps:
    with ps; [
      whisperx
      gradio
      gradio-client
      onnxruntime
      # Explicitly listed for clarity; also pulled in transitively via whisperx.
      torch
      torchaudio
      faster-whisper
      ctranslate2
      pyannote-audio
      transformers
      nltk
      numpy
      pandas
      omegaconf
    ]);

  # Host NVIDIA driver (libcuda.so) lives at /run/opengl-driver/lib; the rest of
  # the CUDA runtime comes from nixpkgs. ctranslate2/faster-whisper may dlopen
  # cuBLAS/cuDNN at runtime, so keep them on LD_LIBRARY_PATH.
  cudaLibPath = lib.makeLibraryPath [
    stdenv.cc.cc.lib
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvrtc
    cudaPackages.libcublas
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    cudaPackages.cudnn
    cudaPackages.nccl
  ];

  # whisperx/faster-whisper shell out to `ffmpeg` for audio/video decoding
  # (README lists it as a hard requirement), so it must be on the launcher PATH.
  runtimePath = lib.makeBinPath [coreutils ffmpeg];
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    # AUR-style naming: source is a pinned upstream release tag (not a VCS
    # HEAD tracker, so no "-git"; not a redistributed binary, so no "-bin"),
    # but this build wires whisperx/torch to nixpkgs' CUDA-enabled Python
    # stack (see pkgs/default.nix's pkgsCuda), so it gets the "-cuda" suffix.
    pname = "whisper-gui-cuda";
    version = "2.4.0";

    src = fetchFromGitHub {
      owner = "Pikurrot";
      repo = "whisper-gui";
      tag = "v${finalAttrs.version}";
      hash = "sha256-nWNZrl26ZY30Wi6BmFmQGbiDHDdO8XLjmC6+Ld5+Wsw=";
    };

    nativeBuildInputs = [makeWrapper];

    # The "Faster Whisper" tab hard-codes a short language dropdown
    # (whisperx_langs) that omits most languages WhisperX can actually align -
    # Turkish included. But main.py already defines ALIGN_LANGS, the full list
    # of alignment-capable languages (with "tr"). Point the dropdown at that
    # list (prefixed with "auto") so every alignment-supported language,
    # Turkish among them, is selectable on the easy tab without switching to
    # the "Custom model" tab and hand-entering a HuggingFace model.
    postPatch = ''
      substituteInPlace main.py \
        --replace-fail \
          'whisperx_langs = ["auto", "en", "es", "fr", "de", "it", "ja", "zh", "nl", "uk", "pt"]' \
          'whisperx_langs = ["auto"] + ALIGN_LANGS'
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/whisper-gui" "$out/bin"
      cp -R . "$out/share/whisper-gui/"

      # `builder/` holds upstream's PyInstaller/AppImage packaging artifacts
      # (WhisperGUI-cuda.AppDir / WhisperGUI-cpu.AppDir) with dangling symlinks
      # to binaries that are only produced during their own AppImage build.
      # We run from source via python main.py, so this dir is unused and its
      # broken symlinks would fail the noBrokenSymlinks fixup check. Drop it.
      rm -rf "$out/share/whisper-gui/builder"

      # The app writes to configs/, models/, outputs/, temp/ relative to CWD and
      # the Nix store is read-only, so the launcher builds a writable working
      # directory under $XDG_DATA_HOME and cd's into it before running main.py.
      cat > "$out/bin/.whisper-gui-unwrapped" <<'LAUNCH'
      #!${runtimeShell}
      set -euo pipefail

      src="''${WHISPER_GUI_SRC:?missing WHISPER_GUI_SRC}"
      state="''${XDG_DATA_HOME:-$HOME/.local/share}/whisper-gui"
      work="$state/work"

      ensure_link() {
        local target="$1" link="$2"
        if [ -e "$link" ] && [ ! -L "$link" ]; then
          rm -rf "$link"
        fi
        ln -sfn "$target" "$link"
      }

      mkdir -p "$work" "$state/configs" "$state/models" "$state/outputs" "$state/temp"

      # main.py and scripts/ are COPIED (not symlinked) into the writable work
      # dir. scripts/config_io.py resolves its config path from __file__, i.e.
      # relative to where the script physically lives. If these were symlinks
      # into the read-only Nix store, __file__.resolve() would point back at
      # the store and write_config_value() could never persist gpu_support -
      # which is exactly why the UI was stuck on CPU. Copying them here makes
      # $work/configs/config.json a real writable target.
      cp -f "$src/main.py" "$work/main.py"
      rm -rf "$work/scripts"
      cp -R "$src/scripts" "$work/scripts"
      chmod -R u+w "$work/main.py" "$work/scripts"
      [ -d "$src/examples" ] && ensure_link "$src/examples" "$work/examples"

      # lang.json ships with the app (read-only); config.json is user state.
      cp -f "$src/configs/lang.json" "$state/configs/lang.json"
      chmod u+w "$state/configs/lang.json"
      # config_io.py's write_config_value() bails out unless config.json
      # already exists, so seed an empty one on first run. The app then fills
      # in gpu_support (via nvidia-smi detection) and other keys itself.
      if [ ! -f "$state/configs/config.json" ]; then
        if [ -f "$src/configs/config.json" ]; then
          cp "$src/configs/config.json" "$state/configs/config.json"
        else
          printf '{}\n' > "$state/configs/config.json"
        fi
      fi
      chmod u+w "$state/configs/config.json"

      # Writable dirs -> real state directories.
      ensure_link "$state/configs" "$work/configs"
      ensure_link "$state/models" "$work/models"
      ensure_link "$state/outputs" "$work/outputs"
      ensure_link "$state/temp" "$work/temp"

      export PYTHONDONTWRITEBYTECODE=1
      # torch 2.6+ defaults torch.load(weights_only=True), which breaks the
      # pyannote/omegaconf VAD models whisperx loads. Force the legacy behavior.
      export TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
      export HF_HOME="''${HF_HOME:-$state/huggingface}"

      cd "$work"
      exec ${pythonEnv}/bin/python main.py --autolaunch "$@"
      LAUNCH

      chmod +x "$out/bin/.whisper-gui-unwrapped"

      makeWrapper "$out/bin/.whisper-gui-unwrapped" "$out/bin/whisper-gui" \
        --set WHISPER_GUI_SRC "$out/share/whisper-gui" \
        --prefix PATH : "${runtimePath}:/run/current-system/sw/bin" \
        --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:${cudaLibPath}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Gradio web UI for WhisperX speech-to-text transcription (CUDA build)";
      homepage = "https://github.com/Pikurrot/whisper-gui";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "whisper-gui";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  })
