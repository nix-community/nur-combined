{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  writeShellApplication,
  python3,
  perl,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.annotated-doc
    ps.anyio
    ps.attrs
    ps.certifi
    ps.cffi
    ps.click
    ps.cryptography
    ps.filelock
    ps.fsspec
    ps.hf-xet
    ps.h11
    ps.httpcore
    ps.httpx
    ps.huggingface-hub
    ps.idna
    ps.jinja2
    ps.jsonschema
    ps.jsonschema-specifications
    ps.llguidance
    ps.markdown-it-py
    ps.markupsafe
    ps.mdurl
    ps.numpy
    ps.packaging
    ps.pillow
    ps.pip
    ps.pygments
    ps.pycparser
    ps.pypdfium2
    ps.pyyaml
    ps.referencing
    ps.regex
    ps.rich
    ps.rpds-py
    ps.safetensors
    ps.shellingham
    ps.tokenizers
    ps.tqdm
    ps.transformers
    ps.typer
    ps.typing-extensions
  ]);
in
stdenv.mkDerivation rec {
  pname = "splash";
  version = "1.7.0";

  # The engine is compiled here with the upstream Makefile, which drives
  # Xcode's clang++, metal and metallib through `xcrun -sdk macosx`. The
  # kernels use Metal 4 (`-std=metal4.0`) and every binary records upstream's
  # tested floor, macOS 26.4, so the build needs Xcode 26 or newer.
  src = fetchFromGitHub {
    owner = "incoai";
    repo = "splash";
    tag = version;
    hash = "sha256-TpOrLinozvpqkip4ep6sFbMi4xmBlaynGEup1whZQD0=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
    # The Makefile digests build inputs with shasum.
    perl
  ];

  # The sandbox hides the developer directory, so xcrun cannot find Xcode's
  # Metal toolchain. Only darwin loses its sandbox.
  __noChroot = stdenv.hostPlatform.isDarwin;

  dontConfigure = true;

  # The engine is linked by Xcode's linker, which already ad-hoc signs it on
  # arm64; stripping would invalidate that signature.
  dontStrip = true;

  buildPhase = ''
    runHook preBuild

    # stdenv exports nixpkgs' own Apple SDK (14.4) through SDKROOT and
    # DEVELOPER_DIR, and its stub xcrun is first in PATH. The Metal 4 kernels
    # need the host Xcode's macOS 26 SDK, so drive Xcode directly.
    unset SDKROOT DEVELOPER_DIR
    xcrun=/usr/bin/xcrun

    # Xcode 27 ships Metal as a separately downloaded toolchain; select it
    # when the default `xcrun metal` cannot run.
    metal="$xcrun -sdk macosx metal"
    if ! $metal --version >/dev/null 2>&1; then
      metal="$xcrun --toolchain com.apple.dt.toolchain.Metal -sdk macosx metal"
    fi

    # Xcode 27's clang warns about the designated initializers upstream
    # leaves at their defaults, and upstream builds with -Werror. The omitted
    # fields are zero-initialized by the language, so keep that diagnostic a
    # warning.
    make \
      XCRUN="$xcrun" \
      CXX="$xcrun -sdk macosx clang++ -Wno-error=missing-designated-field-initializers" \
      METAL="$metal" \
      -j$NIX_BUILD_CORES all

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    root=$out/share/splash
    mkdir -p $root/python/bin $root/engine

    cp -R install server LICENSE THIRD_PARTY_NOTICES $root/
    install -m755 build/splash $root/engine/splash
    install -m644 build/splash.metallib $root/engine/splash.metallib
    # A Metal compiler that refuses the awake host-step kernels omits this
    # library; the engine then runs awake host steps as plain ones.
    if [ -f build/host-step.metallib ]; then
      install -m644 build/host-step.metallib $root/engine/host-step.metallib
    fi

    printf '{\n  "version": "%s"\n}\n' "${version}" > $root/release.json

    # The launcher and server spawn ROOT/python/bin/python3 for the serving
    # process; the Nix environment supplies the pinned dependency set.
    cat > $root/python/bin/python3 <<EOF
    #!${stdenv.shell}
    exec ${pythonEnv}/bin/python3 "\$@"
    EOF
    chmod 755 $root/python/bin/python3

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/splash \
      --add-flags "$root/install/launcher.py" \
      --set PYTHONDONTWRITEBYTECODE 1

    runHook postInstall
  '';

  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-splash";
    text = ''
      export UPDATE_NIX_ATTR_PATH="splash"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "Local inference engine for Apple silicon";
    homepage = "https://github.com/incoai/splash";
    license = lib.licenses.asl20;
    mainProgram = "splash";
    platforms = [ "aarch64-darwin" ];
  };
}
