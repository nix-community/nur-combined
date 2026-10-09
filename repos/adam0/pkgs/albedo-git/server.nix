{
  # keep-sorted start
  bash,
  beam29Packages,
  chrome-headless-shell,
  coreutils,
  fetchFromGitHub,
  fetchurl,
  gleam,
  lib,
  makeWrapper,
  python311,
  render,
  rustPlatform,
  src,
  stdenv,
  usageCore,
  # keep-sorted end
}: let
  inherit
    (beam29Packages)
    # keep-sorted start
    erlang
    pc
    rebar3WithPlugins
    # keep-sorted end
    ;
  inherit
    (builtins)
    # keep-sorted start
    readFile
    toFile
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    concatMapStrings
    concatMapStringsSep
    makeBinPath
    toLower
    versionAtLeast
    # keep-sorted end
    ;
  inherit (rustPlatform) fetchCargoVendor;

  # The sources are formatted by Gleam 1.19, whose formatter and 1.18's each
  # reject the other's output. Channels still shipping 1.18 build it from source.
  gleam19 =
    if versionAtLeast gleam.version "1.19.0"
    then gleam
    else
      gleam.overrideAttrs (finalAttrs: _: {
        version = "1.19.0";
        src = fetchFromGitHub {
          owner = "gleam-lang";
          repo = "gleam";
          tag = "v${finalAttrs.version}";
          hash = "sha256-uMD1ZI8A0gdQbIFvJ9q9CVSJ+jvxJiCzdJ1d2r/BHys=";
        };
        cargoDeps = fetchCargoVendor {
          inherit
            (finalAttrs)
            # keep-sorted start
            pname
            src
            version
            # keep-sorted end
            ;
          hash = "sha256-TZWaKlgdKKM7IUjYu96rbgWsNjHW16E+UKleB68yIh0=";
        };
        # nixpkgs runs the compiler's suite for this release already.
        doCheck = false;
      });

  # esqlite loads the pc plugin during its Rebar3 build, which cannot fetch
  # plugins from Hex inside the Nix sandbox.
  rebar3 = rebar3WithPlugins {plugins = [pc];};

  runtimePath = makeBinPath [
    # keep-sorted start
    bash
    chrome-headless-shell
    coreutils
    erlang
    python311
    render
    # keep-sorted end
  ];

  manifest = fromTOML (readFile "${src}/manifest.toml");

  hexPackages =
    map (p: {
      inherit
        (p)
        # keep-sorted start
        name
        version
        # keep-sorted end
        ;
      archive = fetchurl {
        url = "https://repo.hex.pm/tarballs/${p.name}-${p.version}.tar";
        sha256 = toLower p.outer_checksum;
      };
    })
    manifest.packages;

  packageIndex = toFile "packages.toml" (
    "[packages]\n"
    + concatMapStrings (p: "${p.name} = \"${p.version}\"\n") hexPackages
    + "\n[git]\n"
  );
in
  stdenv.mkDerivation {
    pname = "albedo-server";
    version = "1.0.0";

    inherit src;

    nativeBuildInputs = [
      # keep-sorted start
      erlang
      gleam19
      makeWrapper
      rebar3
      # keep-sorted end
    ];

    buildPhase = ''
      runHook preBuild

      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" build/packages

      ${concatMapStringsSep "\n" (p: ''
          mkdir -p build/packages/${p.name} "$TMPDIR/hex-${p.name}"
          tar -xf ${p.archive} -C "$TMPDIR/hex-${p.name}"
          tar -xzf "$TMPDIR/hex-${p.name}/contents.tar.gz" -C build/packages/${p.name}
        '')
        hexPackages}
      cp ${packageIndex} build/packages/packages.toml
      chmod -R u+w build/packages

      gleam export erlang-shipment

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/albedo $out/bin
      cp -R build/erlang-shipment/. $out/lib/albedo/

      # Kernels import this python from the read-only store, where Python
      # cannot cache bytecode, so each would compile it again (megabytes per
      # kernel). Hash-checked, because the store resets every mtime.
      ${python311}/bin/python3 -m compileall -q --invalidation-mode checked-hash $out/lib/albedo/albedo/priv/python

      mkdir -p $out/lib/albedo/albedo/priv/bin
      ln -s ${render}/bin/albedo-render $out/lib/albedo/albedo/priv/bin/albedo-render
      ln -s ${usageCore}/bin/usage $out/lib/albedo/albedo/priv/bin/usage

      makeWrapper $out/lib/albedo/albedo/priv/bin/albedo-daemon $out/bin/albedo-daemon --add-flags "$out/lib/albedo/entrypoint.sh run" --set-default ALBEDO_BUILD $out/bin/albedo-daemon --prefix PATH : ${runtimePath}

      runHook postInstall
    '';
  }
