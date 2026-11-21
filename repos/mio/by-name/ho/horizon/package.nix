{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  nix-update-script,
  writeShellApplication,
  curl,
  coreutils,
  git,
  gnugrep,
  gnused,
  alsa-lib,
  udev,
  vulkan-loader,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
}:

let
  # wgpu and winit open these with dlopen, so the linker never records them.
  dlopened = [
    vulkan-loader
    wayland
    libxkbcommon
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "horizon";
  version = "2026.10.23";

  src = fetchFromGitHub {
    owner = "horizon-rust";
    repo = "horizon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u0lCVbK23RrNUzUj3xam41m1xlqjEngupkm/Zqmuw94=";
  };

  # The lockfile is the upstream one for this tag: every crate in it carries
  # its own checksum, and it has no git dependencies.
  cargoLock.lockFile = ./Cargo.lock;

  # The game itself; the server, the launcher and the tooling are separate
  # crates that this tag does not ship in the client workspace.
  cargoBuildFlags = [
    "--package=horizon-client"
    "--bin=horizon-client"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
  ];

  # The tests read the prepared vanilla files in .local/, which a build never has.
  doCheck = false;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${lib.makeLibraryPath dlopened} $out/bin/horizon-client
  '';

  # Upstream's release feed only carries launcher@*, nightly-source/* and sdk-*
  # releases: the client ships as date tags (v2026.10.23, or v2026.10.22.16 for
  # same-day respins) that have no release of their own, so nix-update's
  # discovery falls back to a launcher release. Pick the date tag here and pass
  # it as a fixed version. nix-update only refreshes version and src hash, but
  # this package builds against the committed upstream Cargo.lock, so the lock
  # has to move with the version or the next bump fails on a stale crate set.
  passthru.updateScript = writeShellApplication {
    name = "update-horizon";
    runtimeInputs = [
      coreutils
      curl
      git
      gnugrep
      gnused
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="horizon"

      version=$(
        git ls-remote --tags --refs https://github.com/horizon-rust/horizon.git 'v*' \
          | sed -nE 's#.*refs/tags/v(.*)$#\1#p' \
          | grep -E '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}(\.[0-9]{2})?$' \
          | sort -V \
          | tail -n 1
      )
      if [ -z "$version" ]; then
        echo "error: no date-stamped v* tag found upstream" >&2
        exit 1
      fi

      ${lib.escapeShellArgs (nix-update-script { })} --version "$version" "$@"

      pkg="by-name/ho/horizon/package.nix"
      lock="by-name/ho/horizon/Cargo.lock"
      pinned=$(sed -nE 's/^[[:space:]]*version = "([^"]+)";/\1/p' "$pkg" | head -n 1)
      if [ -z "$pinned" ]; then
        echo "error: could not read the horizon version from $pkg" >&2
        exit 1
      fi

      tmp=$(mktemp)
      curl --fail --location --silent --show-error \
        "https://raw.githubusercontent.com/horizon-rust/horizon/v''${pinned}/Cargo.lock" \
        --output "$tmp"
      mv "$tmp" "$lock"
      echo "horizon: refreshed Cargo.lock for v''${pinned}"
    '';
  };

  meta = {
    description = "Minecraft: Java Edition rewritten from scratch in Rust";
    longDescription = ''
      Horizon is a from-scratch Rust implementation of Minecraft: Java Edition,
      checked against vanilla behaviour. This package builds the client with
      sound, controllers and Horizon's online extras; start it with
      `horizon-client --resources DIR`, where DIR is what upstream's
      horizon-prepare wrote. It contains no Minecraft assets.
    '';
    homepage = "https://playhorizon.dev";
    changelog = "https://github.com/horizon-rust/horizon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "horizon-client";
  };
})
