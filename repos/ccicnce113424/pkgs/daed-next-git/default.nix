{
  lib,
  sources,
  webSources,
  hash,
  version,
  stdenvNoCC,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  rustPlatform,
  bpf-linker,
  cmake,
  git,
  makeBinaryWrapper,
  ninja,
}:
let
  pnpm = pnpm_10;

  pnpmDeps = fetchPnpmDeps {
    pname = "daed-next-web";
    inherit version;
    src = webSources.src;
    inherit pnpm hash;
    fetcherVersion = 4;
  };

  # The dashboard lives in the DaedNext product shell repository, the daemon in
  # the DaeNext workspace; upstream's Makefile bundles both into one output.
  web = stdenvNoCC.mkDerivation {
    pname = "daed-next-web";
    inherit version;
    src = webSources.src;

    inherit pnpmDeps;

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    strictDeps = true;
    __structuredAttrs = true;

    buildPhase = ''
      runHook preBuild

      # The web app imports the workspace packages straight from their TypeScript
      # sources (apps/web/vite.config.ts), so turbo is not involved.
      pnpm --filter daed build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R apps/web/dist/. $out/

      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "daed-next-git";
  inherit version;

  src = sources.src;

  cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";

  cargoBuildFlags = [
    "--locked"
    "--package"
    "dae-daemon"
    "--bin"
    "daed"
    "--features"
    "native-ebpf"
  ];

  # The suite wants root, a live eBPF kernel and network, and the eBPF test crates
  # drive aya-build through rustup; upstream CI only smoke-tests `daed --version`.
  doCheck = false;

  # cmake, ninja and git serve boring-sys' bundled BoringSSL only: cmake drives
  # the build (ninja as generator, measured ~1.3-1.7x faster than Unix Makefiles
  # on its ~400-object crypto+ssl targets) and git applies the vendored patches.
  # The ninja setup hook would otherwise claim this derivation's phases, and
  # buildRustPackage sets configurePhase itself, so only ninja needs guarding.
  dontUseNinjaBuild = true;
  dontUseNinjaCheck = true;
  dontUseNinjaInstall = true;

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    bpf-linker
    cmake
    git
    makeBinaryWrapper
    ninja
    rustPlatform.bindgenHook
  ];

  env = {
    # aya-ebpf (via dae-ebpf-program) uses `#![feature(asm_experimental_arch)]`.
    RUSTC_BOOTSTRAP = 1;
    # boring-sys is the only cmake consumer here; see the ninja note above.
    CMAKE_GENERATOR = "Ninja";
    # dae-daemon's build.rs derives this identity from git otherwise, which the
    # sandbox does not provide. Format is upstream's DAED_PRODUCT_VERSION.
    DAE_DAEMON_VERSION = "daed rust-native product version=${finalAttrs.version} ui=${webSources.src.rev} core=${sources.src.rev} target=${stdenvNoCC.hostPlatform.rust.rustcTarget} features=native-ebpf,bpf-btf";
    # dae-build-support shells out to `rustup run nightly cargo`; nixpkgs ships
    # plain cargo, and together with no-build-std.patch the eBPF object links
    # against the bpfel-unknown-none std that nixpkgs' rustc already provides.
    DAE_RUST_NATIVE_BPF_CARGO = lib.getExe rustPlatform.rust.cargo;
    # dae-build-support strips the eBPF object with llvm-strip and validates that
    # .BTF survives; use the LLVM matching rustc instead of relying on PATH.
    DAE_RUST_NATIVE_BPF_STRIP = "${rustPlatform.rust.rustc.llvmPackages.llvm}/bin/llvm-strip";
  };

  patches = [ ./no-build-std.patch ];

  postInstall = ''
    mkdir -p $out/share/daed
    cp -R ${web} $out/share/daed/web

    install -Dm444 ${webSources.src}/install/daed.desktop $out/share/applications/daed.desktop
    # Installed verbatim (NixOS overrides its Exec* through the module's
    # daed-next.service drop-in) but renamed: upstream calls it daed.service,
    # which daeuniverse/daed already ships.
    install -Dm444 ${webSources.src}/install/daed.service $out/lib/systemd/system/daed-next.service

    for icon in ${webSources.src}/install/icons/*.png; do
      install -Dm444 "$icon" \
        "$out/share/icons/hicolor/$(basename "$icon" .png)/apps/daed.png"
    done
  '';

  postFixup = ''
    # The daemon serves the dashboard from /usr/share/daed/web by default.
    wrapProgram $out/bin/daed --set-default PRODUCT_WEB_ROOT $out/share/daed/web
  '';

  passthru = {
    inherit pnpmDeps web;
    # Regenerating the pnpm hash is what this unit is for, so it owns the
    # `daed-next-web` source; the nvfetcher-only `daed-next-core` source is
    # refreshed by its own unit.
    updateScript = {
      command = [ ./update.sh ];
      attrPath = "daed-next-web";
    };
  };

  meta = {
    description = "Product shell and web dashboard for dae (Rust-native daemon)";
    homepage = "https://github.com/ksong008/DaedNext";
    license = with lib.licenses; [
      mit
      agpl3Only
    ];
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
    mainProgram = "daed";
  };
})
