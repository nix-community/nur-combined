{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  curl,
  gtk3,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sgdboop";
  version = "1.4.3";
  src = fetchFromGitHub {
    owner = "SteamGridDB";
    repo = "SGDBoop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-l4l5CWupL/V/qlnFZIgqUBagc5qg0DDv/zz2yc0mtng=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    gtk3
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/applications}
    cp SGDBoop $out/bin/SGDBoop
    ln -s $out/bin/SGDBoop $out/bin/sgdboop
    cp res/linux/com.steamgriddb.SGDBoop.desktop $out/share/applications

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Program used for applying custom artwork to Steam, using SteamGridDB";
    homepage = "https://www.steamgriddb.com/boop";
    license = lib.licenses.zlib;
    platforms = lib.platforms.linux;
    mainProgram = "SGDBoop";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
