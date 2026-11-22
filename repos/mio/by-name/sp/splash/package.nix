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
  version = "1.7.1";

  # The engine is compiled here with the upstream Makefile, which drives
  # Xcode's clang++, metal and metallib through `xcrun -sdk macosx`. The
  # kernels use Metal 4 (`-std=metal4.0`) and every binary records upstream's
  # tested floor, macOS 26.4, so the build needs Xcode 26 or newer.
  src = fetchFromGitHub {
    owner = "incoai";
    repo = "splash";
    tag = version;
    hash = "sha256-eqDiKZvEcEvVvISud4upKdlFnMuj7lzqai3vES1+FHw=";
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

  # The app's runtime is signed in buildPhase; rewriting a shebang in the
  # bundle would break its seal. makeWrapper already writes the launcher with
  # an absolute shell.
  dontPatchShebangs = true;

  buildPhase = ''
    runHook preBuild

    # stdenv exports nixpkgs' own Apple SDK (14.4) through SDKROOT and
    # DEVELOPER_DIR, and its stub xcrun is first in PATH. The Metal 4 kernels
    # need the host Xcode's macOS 26 SDK, so drive Xcode directly.
    unset SDKROOT DEVELOPER_DIR
    xcrun=/usr/bin/xcrun

    # Xcode 27 ships Metal as a separately downloaded toolchain; select it
    # when the default `xcrun metal` cannot run. SwiftPM asks xcrun for the
    # same tool, so point its lookup at that toolchain too.
    swift_toolchain=
    metal="$xcrun -sdk macosx metal"
    if ! $metal --version >/dev/null 2>&1; then
      metal="$xcrun --toolchain com.apple.dt.toolchain.Metal -sdk macosx metal"
      swift_toolchain=com.apple.dt.toolchain.Metal
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

    # The SwiftUI app, built with the host Swift toolchain; SwiftPM fetches
    # its pinned Sparkle and SwiftTerm packages into the writable scratch
    # path. TOOLCHAINS only affects xcrun's tool lookup, not clang, and the
    # app packaging below needs the default Xcode toolchain (actool).
    run_swift() {
      if [ -n "$swift_toolchain" ]; then
        TOOLCHAINS="$swift_toolchain" PATH=/usr/bin:$PATH /usr/bin/swift "$@"
      else
        PATH=/usr/bin:$PATH /usr/bin/swift "$@"
      fi
    }
    export HOME=$PWD/build/home
    mkdir -p "$HOME"
    run_swift build \
      -c release \
      --arch arm64 \
      --package-path app \
      --product Splash \
      --scratch-path "$PWD/build/swift" \
      --disable-sandbox
    products=$(run_swift build \
      -c release \
      --arch arm64 \
      --package-path app \
      --product Splash \
      --scratch-path "$PWD/build/swift" \
      --disable-sandbox \
      --show-bin-path)

    # Stage the runtime the app and the CLI share, then assemble the app
    # around it. The app's Python is the same wrapper the CLI uses.
    runtime=$PWD/build/runtime
    mkdir -p "$runtime/python/bin" "$runtime/engine"
    cp -R install server LICENSE THIRD_PARTY_NOTICES "$runtime/"
    install -m755 build/splash "$runtime/engine/splash"
    install -m644 build/splash.metallib "$runtime/engine/splash.metallib"
    if [ -f build/host-step.metallib ]; then
      install -m644 build/host-step.metallib "$runtime/engine/host-step.metallib"
    fi
    printf '{\n  "version": "%s"\n}\n' "${version}" > "$runtime/release.json"
    cat > "$runtime/python/bin/python3" <<EOF
    #!${stdenv.shell}
    exec ${pythonEnv}/bin/python3 "\$@"
    EOF
    chmod 755 "$runtime/python/bin/python3"

    PATH=/usr/bin:$PATH ${python3}/bin/python3 ${./build-app.py} \
      --source . \
      --products "$products" \
      --runtime "$runtime" \
      --output build/Splash.app \
      --version "${version}" \
      --macos-min 26.4

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share" "$out/Applications"
    cp -R build/runtime "$out/share/splash"
    /usr/bin/ditto build/Splash.app "$out/Applications/Splash.app"

    # The launcher and server spawn ROOT/python/bin/python3 for the serving
    # process; the Nix environment supplies the pinned dependency set.
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/splash \
      --add-flags "$out/share/splash/install/launcher.py" \
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
    description = "Local inference engine and desktop app for Apple silicon";
    homepage = "https://github.com/incoai/splash";
    license = lib.licenses.asl20;
    mainProgram = "splash";
    platforms = [ "aarch64-darwin" ];
  };
}
