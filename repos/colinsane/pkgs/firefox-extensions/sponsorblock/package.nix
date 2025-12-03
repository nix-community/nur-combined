{
  addon-git-updater,
  fetchurl,
  stdenvNoCC,
  unzip,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "sponsorblock";
  version = "5.13.2";
  src = fetchurl {
    url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/FirefoxSignedInstaller.xpi";
    hash = "sha256-vBnbfa+/xYXTkAXNs1E4fVVvg/h0o7mHmOyhxQoVRcc=";
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
    # NB: source code looks like `alreadyInstalled: false`, the build process converts that to `alreadyInstalled:!1`.
    # XXX(2024/03/23): the original replacement doesn't match anymore.
    #                  generated code is liable to shuffle around, so make a best-effort to catch all variants.
    substituteInPlace js/*.js \
      --replace 'alreadyInstalled:!1' 'alreadyInstalled:!0' \
      --replace '!r.default.local.alreadyInstalled' '!1'
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
