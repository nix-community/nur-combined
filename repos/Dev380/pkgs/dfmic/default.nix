{
  lib,
  rustPlatform,
  fetchFromGitHub,
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
  gnutar,
  coreutils,
  # Named `dfmicSrc` rather than `src`: `callPackage` fills arguments from the
  # package set, and nixpkgs has a top-level `src` alias, which would silently
  # override this. Overridable so the build can be exercised against a local
  # checkout:
  #   pkgs.callPackage ./pkgs/dfmic { dfmicSrc = /path/to/dfmic; }
  dfmicSrc ? fetchFromGitHub {
    owner = "Dev380";
    repo = "dfmic";
    rev = "v0.1.0";
    hash = lib.fakeHash;
  },
}:
# The model is deliberately not part of the closure: dfmic downloads it on
# request into $XDG_DATA_HOME/dfmic/models/<version>/ and verifies it with
# SHA-256. Pass --models DIR or set DFMIC_MODELS to supply the converted IR
# instead. The systemd unit lives in the NixOS module, not here.
rustPlatform.buildRustPackage {
  pname = "dfmic";
  version = "0.1.0";

  src = dfmicSrc;

  # Cargo.lock is in the repository, so no separate cargoHash is needed.
  cargoLock.lockFile = "${dfmicSrc}/Cargo.lock";

  # pipewire-sys and libspa-sys run bindgen, which needs libclang.
  nativeBuildInputs = [pkg-config makeWrapper rustPlatform.bindgenHook];
  buildInputs =
    [pipewire openvino]
    ++ [libGL wayland libxkbcommon fontconfig freetype];

  # The OpenVINO C API and PipeWire are found through these search paths.
  env.RUSTFLAGS = "-L native=${pipewire.dev}/lib -L native=${openvino.lib}/lib";
  cargoBuildFlags = ["--features" "gui"];

  # Order matters: the rpath goes on the ELF *before* wrapProgram replaces it
  # with a shell script, or patchelf is handed a script and fails.
  postFixup = ''
    # Slint's winit backend dlopens libwayland and libEGL, which the auto-patcher
    # cannot see because nothing links against them.
    patchelf --add-rpath ${lib.makeLibraryPath [wayland libxkbcommon libGL]} $out/bin/dfmic
    # The model download shells out to these; a user unit has a minimal PATH.
    wrapProgram $out/bin/dfmic \
      --prefix PATH : ${lib.makeBinPath [curl gnutar coreutils]}
  '';

  postInstall = ''
    install -Dm644 ${dfmicSrc}/nix/dfmic.desktop $out/share/applications/dfmic.desktop
    for size in 128 256; do
      install -Dm644 ${dfmicSrc}/nix/icon.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/dfmic.png
    done
  '';

  # The DSP tests need the model IR; they run in `nix flake check` in the dfmic
  # repository, which has it.
  doCheck = false;

  meta = {
    description = "DeepFilterNet3_ll noise suppression as a PipeWire virtual microphone on the Intel NPU";
    homepage = "https://github.com/Dev380/dfmic";
    license = lib.licenses.mit;
    mainProgram = "dfmic";
    platforms = ["x86_64-linux"];
  };
}
