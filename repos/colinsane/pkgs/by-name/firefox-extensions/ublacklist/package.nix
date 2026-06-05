{
  addon-git-updater,
  fetchurl,
  stdenv,
  unzip,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ublacklist";
  version = "9.6.0";
  src = fetchurl {
    url = "https://github.com/iorate/ublacklist/releases/download/v${finalAttrs.version}/ublacklist-v${finalAttrs.version}-firefox.zip";
    hash = "sha256-0A8DhX0x6QQNH8GkT1ZnHnlmAIURmqtnSvk0jav0orU=";
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
})
