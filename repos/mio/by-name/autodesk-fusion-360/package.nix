{
  lib,
  stdenv,
  fetchFromGitea,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
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
    rev = "0fcbc4a3c18b60331006e885c34e2621cbaf5287";
    hash = "sha256-f9BvoDKZePn0uRdUEppfzyuO+xW2EW1PLvHN9PAo3QI=";
  };

  patches = [ ./nix-env.patch ];

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "autodesk-fusion-360";
      exec = "autodesk-fusion-360";
      icon = "autodesk-fusion-360";
      desktopName = "Autodesk Fusion 360";
      genericName = "CAD Application";
      categories = [ "Education" "Engineering" ];
      startupNotify = true;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/autodesk-fusion-360 $out/share/icons/hicolor/scalable/apps
    cp -r files/* $out/share/autodesk-fusion-360/
    
    # Install icon
    cp files/images/launcher/Autodesk\ Fusion\ 360-launcher-xterm.png $out/share/icons/hicolor/scalable/apps/autodesk-fusion-360.png

    chmod +x $out/share/autodesk-fusion-360/setup/autodesk_fusion_installer_x86-64.sh
    makeWrapper $out/share/autodesk-fusion-360/setup/autodesk_fusion_installer_x86-64.sh $out/bin/autodesk-fusion-installer \
      --prefix PATH : ${lib.makeBinPath [ bash wine winetricks cabextract p7zip curl samba zenity yad ]}

    chmod +x $out/share/autodesk-fusion-360/setup/data/autodesk_fusion_launcher.sh
    makeWrapper $out/share/autodesk-fusion-360/setup/data/autodesk_fusion_launcher.sh $out/bin/.autodesk-fusion-launcher-wrapped \
      --prefix PATH : ${lib.makeBinPath [ bash wine curl ]}

    cat > $out/bin/autodesk-fusion-360 << 'EOF'
#!/usr/bin/env bash
if [ ! -d "$HOME/.autodesk_fusion/wineprefixes/default" ]; then
    echo "First run detected, starting installer..."
    exec autodesk-fusion-installer --install
else
    echo "Starting Autodesk Fusion 360..."
    exec .autodesk-fusion-launcher-wrapped
fi
EOF
    chmod +x $out/bin/autodesk-fusion-360

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
