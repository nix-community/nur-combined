{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "i-still-dont-care-about-cookies";
  version = "1.1.9";
  src = fetchFromGitHub {
    owner = "OhMyGuus";
    repo = "I-Still-Dont-Care-About-Cookies";
    rev = "v${version}";
    hash = "sha256-bhrRS73l0124Xl54czIh6nJiqcjZRa3C19GuN4T+gu8=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  postPatch = ''
    # firefox claims to support manifest v3, but actually it won't load unless i point it to v2.
    ln -s manifest_v2.json src/manifest.json
  '';

  installPhase = ''
    runHook preInstall
    pushd src
    mkdir $out
    zip -r $out/$extid.xpi ./*
    popd
    runHook postInstall
  '';

  extid = "idcac-pub@guus.ninja";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    homepage = "https://github.com/OhMyGuus/I-Still-Dont-Care-About-Cookies";
    description = ''Debloated fork of the extension "I don't care about cookies"'';
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
