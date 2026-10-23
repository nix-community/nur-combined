{
  lib,
  stdenv,
  stdenvNoCC,
  callPackage,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  bun,
  nodejs,
  electron_44,
  ffmpeg,
  ctranslate2,
  python3,
  nix-update-script,
}:
let
  electron = electron_44;

  # Must match engines/omnivoice_gguf/backend.py:_platform_slug().
  ggufPlatform =
    {
      x86_64-linux = "linux-x86_64";
      aarch64-linux = "linux-aarch64";
      aarch64-darwin = "darwin-arm64";
    }
    .${stdenv.hostPlatform.system};

  # Missing engines are reported as unavailable. Not packaged: pedalboard,
  # mlx-*, and the engines upstream installs into their own venvs.
  python = python3.override (old: {
    packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) (
      _: super:
      let
        # argostranslate's variant; avoids a second copy in the env.
        ctranslate2-cpp = ctranslate2.override {
          withOneDNN = true;
          withOpenblas = false;
        };
      in
      {
        ctranslate2 = super.ctranslate2.override { inherit ctranslate2-cpp; };
        whisperx = super.whisperx.override { inherit ctranslate2-cpp; };
      }
    );
  });

  pythonEnv = python.buildEnv.override {
    # speechbrain and udapi both install a top-level `docs` package.
    ignoreCollisions = true;
    extraLibs =
      with python.pkgs;
      [
        accelerate
        alembic
        argostranslate
        audioseal
        cryptography
        deep-translator
        demucs
        fastapi
        faster-whisper
        grpcio
        hf-xet
        huggingface-hub
        imageio-ffmpeg
        kittentts
        lightning
        mcp
        num2words
        numpy
        nvidia-ml-py
        openai
        pillow
        pocket-tts
        posthog
        protobuf
        psutil
        pyannote-audio
        pydub
        pypdf
        python-multipart
        pytorch-lightning
        scalar-fastapi
        sherpa-onnx
        socksio
        soundfile
        spacy-models.en_core_web_sm
        supertonic
        tensorboardx
        torch
        torchaudio
        torchcodec
        torchvision
        transformers
        truststore
        uvicorn
        webdataset
        websockets
        whisperx
        yt-dlp
      ]
      ++ uvicorn.optional-dependencies.standard;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "voice-studio";
  version = "0.5.6";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "debpalash";
    repo = "VoiceStudio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FZzfS9Ig5DBY3fKkYjfWwS2tU1J5rm24jwBSaOcl5C8=";
  };

  # finalPackage so that overriding src propagates.
  node-modules = callPackage ./node-modules.nix { voice-studio = finalAttrs.finalPackage; };
  desktop-bridge = callPackage ./desktop-bridge.nix { voice-studio = finalAttrs.finalPackage; };
  omnivoice-cpp = callPackage ./omnivoice-cpp.nix { };

  patches = [
    # Don't build per-engine venvs with their own PyTorch.
    ./no-sidecar-install.patch
    # torchaudio.info() was removed in torchaudio 2.9.
    ./torchaudio-info.patch
  ];

  postPatch = ''
    if ! grep -qF '"runtime_commit_sha": "${finalAttrs.omnivoice-cpp.src.rev}"' \
        backend/engines/omnivoice_gguf/quant_map.json; then
      echo "omnivoice-cpp rev does not match quant_map.json" >&2
      exit 1
    fi

    for f in electron/src/main/*.ts; do
      case "$f" in *.test.ts) continue ;; esac
      substituteInPlace "$f" \
        --replace-quiet process.resourcesPath "'$out/share/voice-studio'"
    done

    # pyannote.audio 4 renamed use_auth_token.
    substituteInPlace backend/services/model_manager.py \
      --replace-fail 'Pipeline.from_pretrained(config_path, use_auth_token=hf_token)' \
        'Pipeline.from_pretrained(config_path, token=hf_token)'

    # torchaudio >= 2.9 needs torchcodec for load/save.
    substituteInPlace backend/main.py \
      --replace-fail 'sys.modules.setdefault("torchcodec", None)' ""
    # torchcodec can't save to buffers; use the soundfile fallback.
    substituteInPlace backend/services/audio_io.py \
      --replace-fail \
        'if isinstance(e, RuntimeError) and "could not load libtorchcodec" not in str(e).lower():' \
        'if isinstance(e, RuntimeError) and "could not load libtorchcodec" not in str(e).lower() and not hasattr(path_or_buf, "write"):'

    substituteInPlace electron/src/main/updater.ts \
      --replace-fail 'const supported = app.isPackaged;' 'const supported = false;'

    # Normally injected by electron-builder.
    substituteInPlace electron/package.json \
      --replace-fail '"version": "0.0.0-electron"' '"version": "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    bun
    nodejs
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node-modules}/. .
    chmod -R u+w node_modules electron frontend
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd electron
    bun run build
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    share=$out/share/voice-studio
    mkdir -p $share/app $share/brand $share/native

    # Ship only the closure of what main/preload import.
    cp -r electron/out electron/package.json $share/app/
    node ${./copy-runtime-deps.mjs} "$PWD" $share/app $(
      grep -ohE '(from |require\(|import\()"[^".][^"]*"' electron/out/main/*.js electron/out/preload/*.mjs \
        | sed -E 's/^[^"]*"//; s/"$//' \
        | grep -v -e '^node:' -e '^electron$' \
        | sed -E 's#^((@[^/]+/)?[^/]+).*#\1#' \
        | sort -u
    )

    cp -r backend omnivoice pyproject.toml uv.lock README.md LICENSE $share/
    find $share/backend $share/omnivoice -type d -name tests -prune -exec rm -rf {} +
    ${pythonEnv.interpreter} -m compileall -q --invalidation-mode unchecked-hash \
      $share/backend $share/omnivoice

    install -Dm644 frontend/src-tauri/icons/icon.png $share/brand/icon.png
    install -Dm644 frontend/src-tauri/icons/32x32.png $share/brand/32x32.png
    install -Dm644 frontend/src-tauri/icons/tray-recording.png $share/brand/tray-recording.png
    ln -s ${lib.getExe finalAttrs.desktop-bridge} $share/native/voicestudio-desktop-bridge
    install -d $share/bin
    ln -s ${lib.getExe finalAttrs.omnivoice-cpp} $share/bin/omnivoice-tts-${ggufPlatform}

    for size in 32 64 128; do
      install -Dm644 frontend/src-tauri/icons/''${size}x''${size}.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/voice-studio.png
    done
    install -Dm644 frontend/src-tauri/icons/icon.png \
      $out/share/icons/hicolor/512x512/apps/voice-studio.png

    # OMNIVOICE_FROZEN disables pip installs from the Model Catalogue.
    makeWrapper ${pythonEnv.interpreter} $out/bin/voice-studio-server \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
      --set OMNIVOICE_FROZEN 1 \
      --add-flags "-m uvicorn main:app --app-dir $share/backend" \
      --add-flags "--host \''${OMNIVOICE_HOST:-127.0.0.1} --port \''${OMNIVOICE_PORT:-3900}"

    makeWrapper ${lib.getExe electron} $out/bin/voice-studio \
      --add-flags $share/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default OMNIVOICE_BACKEND_CMD $out/bin/voice-studio-server

    runHook postInstall
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "voice-studio";
      desktopName = "VoiceStudio";
      comment = finalAttrs.meta.description;
      exec = "voice-studio %U";
      icon = "voice-studio";
      startupWMClass = "VoiceStudio";
      categories = [
        "Audio"
        "AudioVideo"
      ];
    })
  ];

  passthru = {
    inherit pythonEnv;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "node-modules"
        "--subpackage"
        "desktop-bridge"
      ];
    };
  };

  meta = {
    homepage = "https://github.com/debpalash/VoiceStudio";
    changelog = "https://github.com/debpalash/VoiceStudio/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    description = "Open-source voice cloning, voice design, dubbing and transcription studio";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "voice-studio";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
