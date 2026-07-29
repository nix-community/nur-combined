{
  # keep-sorted start
  alsa-lib,
  buildNpmPackage,
  bun,
  dbus,
  fetchFromGitHub,
  importNpmLock,
  lib,
  makeWrapper,
  nodejs_22,
  stdenv,
  # keep-sorted end
}: let
  linuxDeps = lib.optionals stdenv.isLinux [
    alsa-lib
    dbus
  ];
in
  buildNpmPackage rec {
    pname = "rocksky-cli";
    version = "0.8.0";

    src = fetchFromGitHub {
      owner = "tsirysndr";
      repo = "rocksky";
      rev = "94c2b8a153c8c0f00cad90663ec3f75bcc9e5bca";
      hash = "sha256-6e3+09y4Bwxy68ojRa5RKoElSRsHdl6PhPL9gRZwi6s=";
    };

    sourceRoot = "${src.name}/apps/cli";

    npmDeps = importNpmLock {npmRoot = src + "/apps/cli";};
    inherit (importNpmLock) npmConfigHook;

    nodejs = nodejs_22;

    buildInputs = linuxDeps;
    nativeBuildInputs =
      [bun]
      ++ lib.optionals stdenv.isLinux [makeWrapper];

    postInstall = lib.optionalString stdenv.isLinux ''
      wrapProgram $out/bin/rocksky \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath linuxDeps}
    '';

    meta = {
      # keep-sorted start
      description = "CLI for the decentralized Rocksky music tracking platform";
      homepage = "https://github.com/tsirysndr/rocksky/tree/main/apps/cli";
      license = lib.licenses.asl20;
      mainProgram = "rocksky";
      platforms = lib.platforms.unix;
      # keep-sorted end
    };
  }
