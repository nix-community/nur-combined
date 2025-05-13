{
  addon-git-updater,
  fetchurl,
  lib,
  stdenv,
  unzip,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenv.mkDerivation rec {
  pname = "sponsorblock";
  version = "5.12.1";
  src = fetchurl {
    url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/FirefoxSignedInstaller.xpi";
    hash = "sha256-boZskrdec2qh1cfe3NkjWKPk00m5qEzrtEqs2v+V1ag=";
    name = "FirefoxSignedInstaller.zip";
  };
  # .zip file has everything in the top-level; stdenv needs it to be extracted into a subdir:
  sourceRoot = ".";
  preUnpack = ''
    mkdir src && cd src
  '';

  postPatch = ''
    # patch sponsorblock to not show the help tab on first launch.
    #
    # XXX: i tried to build sponsorblock from source and patch this *before* it gets webpack'd,
    # but web shit is absolutely cursed and building from source requires a fucking PhD
    # (if you have one, feel free to share your nix package)
    #
    # NB: in source this is `alreadyInstalled: false`, but the build process hates Booleans or something
    # TODO(2024/03/23): this is broken (replacement doesn't match). but maybe not necessary anymore?
    substituteInPlace js/*.js \
      --replace 'alreadyInstalled:!1' 'alreadyInstalled:!0'
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    zip -r -FS $out/$extid.xpi .
    runHook postInstall
  '';

  nativeBuildInputs = [
    unzip  # for unpackPhase
    wrapFirefoxAddonsHook
    zip
  ];

  extid = "sponsorBlocker@ajay.app";
  passthru.updateScript = addon-git-updater;
}
