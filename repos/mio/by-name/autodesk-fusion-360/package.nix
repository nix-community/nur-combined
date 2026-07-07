{
  lib,
  stdenv,
  fetchFromGitea,
  makeWrapper,
  bash,
  wine,
  winetricks,
  cabextract,
  p7zip,
  curl,
  samba,
  zenity,
  yad,
}:

stdenv.mkDerivation rec {
  pname = "autodesk-fusion-360";
  version = "8.0.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "cryinkfly";
    repo = "Autodesk-Fusion-360-on-Linux";
    rev = "v${version}";
    hash = "sha256-f9BvoDKZePn0uRdUEppfzyuO+xW2EW1PLvHN9PAo3QI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/autodesk-fusion-360
    cp -r files/* $out/share/autodesk-fusion-360/
    
    makeWrapper $out/share/autodesk-fusion-360/setup/autodesk_fusion_installer_x86-64.sh $out/bin/autodesk-fusion-installer \
      --prefix PATH : ${lib.makeBinPath [ bash wine winetricks cabextract p7zip curl samba zenity yad ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Setup Wizard for Autodesk Fusion 360 on Linux";
    homepage = "https://codeberg.org/cryinkfly/Autodesk-Fusion-360-on-Linux";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "autodesk-fusion-installer";
  };
}
