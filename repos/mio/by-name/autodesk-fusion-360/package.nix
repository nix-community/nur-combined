{
  lib,
  stdenv,
  fetchFromGitea,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  runtimeShell,
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



  postPatch = ''
    substituteInPlace files/setup/autodesk_fusion_installer_x86-64.sh \
      --replace-fail 'sh "$SELECTED_DIRECTORY/bin/winetricks"' 'winetricks' \
      --replace-fail 'curl -L "$WINETRICKS_URL" -o "$SELECTED_DIRECTORY/bin/winetricks"' 'echo "Skipping winetricks download"' \
      --replace-fail 'chmod +x "$SELECTED_DIRECTORY/bin/winetricks"' 'echo "Skipping winetricks chmod"'

    sed -i \
      -e 's/^[[:space:]]*install_required_packages$/            : # skipped install_required_packages/' \
      -e 's/^[[:space:]]*check_and_install_wine$/            : # skipped check_and_install_wine/' \
      -e 's/^[[:space:]]*autodesk_fusion_shortcuts_load$/            : # skipped autodesk_fusion_shortcuts_load/' \
      files/setup/autodesk_fusion_installer_x86-64.sh
  '';

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

    mkdir -p $out/bin $out/libexec $out/share/autodesk-fusion-360 $out/share/icons/hicolor/scalable/apps
    cp -r files/* $out/share/autodesk-fusion-360/
    
    # Install icon
    cp files/images/launcher/Autodesk\ Fusion\ 360-launcher-xterm.png $out/share/icons/hicolor/scalable/apps/autodesk-fusion-360.png

    chmod +x $out/share/autodesk-fusion-360/setup/autodesk_fusion_installer_x86-64.sh
    makeWrapper $out/share/autodesk-fusion-360/setup/autodesk_fusion_installer_x86-64.sh $out/libexec/autodesk-fusion-installer \
      --prefix PATH : ${lib.makeBinPath [ bash wine winetricks cabextract p7zip curl samba zenity yad ]}

    chmod +x $out/share/autodesk-fusion-360/setup/data/autodesk_fusion_launcher.sh
    makeWrapper $out/share/autodesk-fusion-360/setup/data/autodesk_fusion_launcher.sh $out/libexec/autodesk-fusion-launcher \
      --prefix PATH : ${lib.makeBinPath [ bash wine curl ]}

    cat > $out/bin/autodesk-fusion-360 << EOF
#!${runtimeShell}
if [ ! -d "\$HOME/.autodesk_fusion/wineprefixes/default" ]; then
    echo "First run detected, starting installer..."
    exec $out/libexec/autodesk-fusion-installer --install
else
    echo "Starting Autodesk Fusion 360..."
    exec $out/libexec/autodesk-fusion-launcher
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
