{
  addon-git-updater,
  fetchurl,
  stdenv,
  unzip,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenv.mkDerivation rec {
  pname = "ublacklist";
  version = "8.9.2";
  src = fetchurl {
    url = "https://github.com/iorate/ublacklist/releases/download/v${version}/ublacklist-v${version}-firefox.zip";
    hash = "sha256-b+MBSeh+YC/qT88pupElPU531YyfvYe1aC1icHXfK3A=";
  };
  # .zip file has everything in the top-level; stdenv needs it to be extracted into a subdir:
  sourceRoot = ".";
  preUnpack = ''
    mkdir src && cd src
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

  extid = "@ublacklist";
  passthru.updateScript = addon-git-updater;
}
