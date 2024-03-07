{
  lib,
  stdenvNoCC,
  source,
  undmg,
}:

stdenvNoCC.mkDerivation {
  pname = "vivaldi";
  inherit (source) version src;

  preferLocalBuild = true;

  nativeBuildInputs = [ undmg ];

  sourceRoot = "Vivaldi.app";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications/Vivaldi.app
    cp -R . $out/Applications/Vivaldi.app

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Browser for our Friends powerful and personal";
    homepage = "https://vivaldi.com";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ natsukium ];
  };
}
