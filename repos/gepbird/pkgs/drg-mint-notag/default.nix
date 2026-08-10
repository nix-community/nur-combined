{
  pkgs,
  lib,
  fetchFromGitHub,
  pkgsCross,
  makeRustPlatform,
  pkg-config,
  makeWrapper,
  gtk3,
  libGL,
  openssl,
  atk,
  libxkbcommon,
  wayland,
}:

let
  rust-overlay = import ../mint-mod-manager/rust-overlay (
    pkgs
    // {
      inherit (rust-overlay) rust-bin;
    }
  ) { };

  rustNightlyVersion = "2023-10-01";

  # drg-mint-notag pins `nightly-2023-08-18` (see upstream rust-toolchain.toml) and hasn't been
  # updated since. That date has been pruned from the manifests bundled with the rust-overlay
  # subtree above (it only keeps ~2 years of nightlies), so build the toolchain straight from
  # the (permanently archived) upstream rustup manifest instead of `rust-bin.nightly.<date>`.
  #
  # Slightly newer than the pinned date: some dependencies (e.g. `termtree` 0.5.1) require
  # rustc >= 1.74, while nightly-2023-08-18 is still 1.73.0-nightly. This is the *last* nightly
  # of the 1.74 cycle on purpose: crates that feature-detect via the reported version (serde's
  # build script and friends) assume everything stabilized in 1.74 is present, which only holds
  # near the end of the cycle.
  #
  # Uses `builtins.fetchurl` (not `pkgs.fetchurl`) on purpose: `buildRustPackage` forces
  # `rustc.targetPlatforms` just to compute `meta.platforms`, so anything that reads this
  # manifest is evaluated even by a plain `nix-env -qa`/`nix search`. `pkgs.fetchurl` is a
  # derivation, so reading it needs an import-from-derivation build, which tools like
  # `nix-env -qa --drv-path` don't perform (see CI's "Check evaluation" step). `builtins.fetchurl`
  # fetches during evaluation itself, so it needs no build and CI's `--allowed-uris` already
  # permits it.
  rustNightlyManifestRaw = builtins.fromTOML (
    builtins.readFile (
      builtins.fetchurl {
        url = "https://static.rust-lang.org/dist/${rustNightlyVersion}/channel-rust-nightly.toml";
        sha256 = "sha256-aMPg5IYBoK4GAqa0/6axConww2zDJUxU1aQIOq7Da9I=";
      }
    )
  );

  rustNightlyManifest = rustNightlyManifestRaw // {
    # Unlike rust-overlay's own (pre-filtered) manifests, upstream manifests list an entry
    # (with `available = false` and no url/hash) for every known target, even ones this
    # component wasn't built for. Drop those so `toolchainFromManifest` doesn't choke on the
    # missing `xz_url`/`xz_hash`.
    pkg = lib.mapAttrs (
      _: p: p // { target = lib.filterAttrs (_: v: v.available or false) p.target; }
    ) rustNightlyManifestRaw.pkg;
    # Not present in upstream manifests; rust-overlay hardcodes the same value.
    targetComponentsList = [
      "rust-std"
      "rustc-dev"
      "rustc-docs"
    ];
    # rust-overlay's own manifests compute this from the compact `v`+`d` fields; only used
    # for naming the resulting derivations.
    version = "nightly-${rustNightlyVersion}";
  };

  rustToolchain =
    (rust-overlay.rust-bin._internal.toolchainFromManifest rustNightlyManifest).default.override
      {
        targets = [ "x86_64-pc-windows-gnu" ];
      };
  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };

  mingwPkgs = pkgsCross.mingwW64;
  mingwCompiler = mingwPkgs.buildPackages.gcc;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "drg-mint-notag";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "Strappazzon";
    repo = "drg-mint-notag";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hXMMxryQb/pzuHUdJ0NyyUPb51omYdGYV8hItIOFT9w=";
  };

  cargoHash = "sha256-QGjZLgEDf4QtpRjJRCEfBukVEeQcCDgvQDWM/HZB6vE=";

  env = {
    # Necessary for cross compiled build scripts, otherwise it will build as ELF format
    # https://docs.rs/cc/latest/cc/#external-configuration-via-environment-variables
    CC_x86_64_pc_windows_gnu = "${mingwCompiler}/bin/${mingwCompiler.targetPrefix}cc";
    CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS = "-L ${mingwPkgs.windows.pthreads}/lib";
  };

  nativeBuildInputs = [
    mingwCompiler
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    gtk3
    libGL
    openssl
    atk
    libxkbcommon
    wayland
  ];

  postInstall = ''
    wrapProgram $out/bin/mint \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  '';

  # only used for `nix develop .#drg-mint-notag`
  shellHook = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath finalAttrs.buildInputs}:$LD_LIBRARY_PATH"
    export XDG_DATA_DIRS="${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Deep Rock Galactic mod loader and integration, fork of mint";
    longDescription = ''
      Drg-mint-notag is a fork of Mint that is more maintained and contains necessary bug fixes.

      Mint is a 3rd party mod integration tool for Deep Rock Galactic to download and integrate mods completely externally of the game.
      This enables more stable mod usage as well as offline mod usage.
    '';
    homepage = "https://github.com/Strappazzon/drg-mint-notag";
    changelog = "https://github.com/Strappazzon/drg-mint-notag/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      gepbird
    ];
    mainProgram = "mint";
    platforms = [ "x86_64-linux" ];
  };
})
