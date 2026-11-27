{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  makeWrapper,
  pipewire,
  openvino,
  libGL,
  wayland,
  libxkbcommon,
  fontconfig,
  freetype,
  curl,
  coreutils,
  gnutar,
  gzip,
  systemd,
  # The dfmic checkout. Separate from `src` because `callPackage` would otherwise
  # fill it from nixpkgs' top-level `src` alias. The flake passes its `dfmic`
  # input here; a plain `nix-build -A dfmic` falls back to the pinned tarball, so
  # both entry points build the same revision.
  dfmicSrc ?
    fetchFromGitHub {
      owner = "Dev380";
      repo = "dfmic";
      rev = "1bf536b576a88520f656f9528092c766283ec71a";
      hash = "sha256-aez84HGAvLYOgf49Q3vOoQ32hl9Q7s8iw6fJ6kXbCio=";
    },
  # Whether the converted DeepFilterNet3_ll IR ships in the closure.
  #
  # The default is `false`: the package carries no model, and the daemon fetches
  # the ~18 MB archive into `$XDG_DATA_HOME/dfmic/models/<version>/` on request
  # (`dfmic models download`, or the button in the window), verifying it with
  # SHA-256. That keeps the closure — and the binary cache — small, and it means
  # the model is fetched once per user rather than once per machine.
  #
  # `true` puts the same, hash-pinned archive in the closure instead, which is
  # what you want for a machine that is never online:
  #
  #   pkgs.dfmic.override { withModels = true; }
  withModels ? false,
  # What the daemon forks. `pw-metadata` handles the default-source takeover and
  # its startup recovery; curl + sha256sum + tar + gzip are the model downloader;
  # `systemctl` answers the window's unit queries.
  #
  # A systemd *user* unit gets NixOS's minimal default PATH, which holds only
  # coreutils/findutils/gnugrep/gnused/systemd. Without `pw-metadata` the daemon
  # cannot restore the default source after an unclean stop and refuses to
  # start, which `Restart=on-failure` then turns into a restart loop.
  # `tar -xzf` shells out to `gzip`, so gzip has to be on PATH too.
  runtimePath ? lib.makeBinPath [pipewire curl coreutils gnutar gzip systemd],
}: let
  # The archive `crates/dfmic/src/models.rs` fetches at runtime, pinned to the
  # same bytes so the offline variant installs exactly what a download would.
  # 0.5.6 is `models::VERSION` and part of the path, so bumping it here without
  # bumping the source only changes where the files sit, never what they are.
  modelArchive = fetchurl {
    url = "https://huggingface.co/jsjxjjfrkznmeme/dfmic-models-DeepFilterNet3_ll/resolve/main/dfmic-models-DeepFilterNet3_ll-0.5.6.tar.gz";
    hash = "sha256-+7WKR71V/+GFcwAYIUMFXGMy+9ByxR77wwCNYloCebU=";
  };
  modelVersion = "DeepFilterNet3_ll-0.5.6";
  # Flake inputs are store paths; a plain checkout is not. `toString` covers both
  # without a `builtins.typeOf` branch.
  source = dfmicSrc;
  # The OpenVINO C API and PipeWire are found through these search paths.
  # nixpkgs' OpenVINO splits into `out`/`python` and keeps the runtime libraries
  # under `runtime/lib/intel64`, not `lib`; a repackaged build may use `lib`.
  # Testing both means this does not silently link against nothing when the
  # packaging changes — `cargo` ignores a `-L` that does not exist, and the
  # failure would otherwise only show up at link time in a confusing way.
  openvinoLib =
    if builtins.pathExists "${openvino}/runtime/lib/intel64"
    then "${openvino}/runtime/lib/intel64"
    else "${openvino}/lib";
in
  rustPlatform.buildRustPackage {
    pname = "dfmic";
    version = "0.1.0";

    src = source;

    # Cargo.lock is in the repository, so no separate cargoHash is needed.
    cargoLock.lockFile = "${source}/Cargo.lock";

    # pipewire-sys and libspa-sys run bindgen, which needs libclang.
    nativeBuildInputs = [pkg-config makeWrapper rustPlatform.bindgenHook];
    buildInputs = [
      pipewire
      openvino
      libGL
      wayland
      libxkbcommon
      fontconfig
      freetype
    ];

    env.RUSTFLAGS = "-L native=${pipewire.dev}/lib -L native=${openvinoLib}";
    cargoBuildFlags = ["--features" "gui"];

    # The GUI tests are behind the feature, so the flag has to be repeated here.
    doCheck = true;
    cargoTestFlags = ["--features" "gui"];

    # Order matters: the rpath goes on the ELF *before* wrapProgram replaces it
    # with a shell script, or patchelf is handed a script and fails.
    postFixup = ''
      # Slint's winit backend dlopens libwayland and libEGL, which the auto-patcher
      # cannot see because nothing links against them.
      patchelf --add-rpath ${lib.makeLibraryPath [wayland libxkbcommon libGL]} $out/bin/dfmic
      wrapProgram $out/bin/dfmic --prefix PATH : ${runtimePath}
    '';

    postInstall =
      ''
        install -Dm644 ${source}/nix/dfmic.desktop $out/share/applications/dfmic.desktop
        # One size: upstream only ships a 256x256 icon, and installing it at 128 as
        # well would leave a mislabelled file in the theme.
        install -Dm644 ${source}/nix/icon.png \
          $out/share/icons/hicolor/256x256/apps/dfmic.png
      ''
      + lib.optionalString withModels ''
        mkdir -p $out/share/dfmic/models/${modelVersion}
        tar -xzf ${modelArchive} -C $out/share/dfmic/models/${modelVersion} --strip-components=1
      '';

    meta = {
      description = "DeepFilterNet3_ll noise suppression as a PipeWire virtual microphone on the Intel NPU";
      homepage = "https://github.com/Dev380/dfmic";
      # The crates are MIT OR Apache-2.0; see the repository's own `license` field.
      license = lib.licenses.OR [lib.licenses.mit lib.licenses.asl20];
      mainProgram = "dfmic";
      # OpenVINO's NPU plugin, the Intel NPU driver and PipeWire are all Linux-only.
      platforms = ["x86_64-linux"];
      # The model bundle is a 18 MB download; the rest builds from source.
      broken = false;
    };

    passthru = {
      inherit withModels;
      # Where the IR lives in this variant, for a module or script that has to pass
      # `--models`. `null` when nothing is bundled, so a caller cannot point the
      # daemon at a store path that does not exist.
      modelsPath =
        if withModels
        then placeholder "out" + "/share/dfmic/models/${modelVersion}"
        else null;
    };
  }
