{ stdenv, lib, fetchurl, fetchgit, makeWrapper, firefox, gnome }:

let
  desktopFile = fetchurl {
    url = "https://gist.githubusercontent.com/mildred/c44d6ca8ac76333ca4a2/raw/f71167ad2e35a2bb2166047e5ecfd7c0a5ea17ad/multifirefox.desktop";
    sha256 = "sha256-m/BjqfgQ0RCdCRSmIly3jzpwlQ3HaHu+mejGScWo/vY=";
  };

in stdenv.mkDerivation {
  pname = "multifirefox";
  version = "unstable-2023-07-28";

  src = fetchgit {
    url = "https://codeberg.org/wolfangaukang/multifirefox";
    rev = "293b3fa3f01dc80483823129dad4f5cc536659bf";
    sha256 = "sha256-xRW+OiQr7SOdo27OsvJvs04yVbVTwOYzrD5rjj84Vns=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/multifirefox $out/share/applications
    cp multifirefox/multifirefox.sh $out/opt/multifirefox/multifirefox
    cp ${desktopFile} $out/share/applications/multifirefox.desktop

    cp -R ${firefox}/share/icons $out/share/
    makeWrapper $out/opt/multifirefox/multifirefox \
      $out/bin/multifirefox \
      --prefix PATH : "${lib.makeBinPath [ firefox gnome.zenity ]}"
    substituteInPlace $out/share/applications/multifirefox.desktop \
      --replace "/usr/bin/env " "$out/bin/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Equivalent of `firefox -P PROFILE_NAME -no-remote` but with the remote enabled";
    homepage = "https://codeberg.org/wolfangaukang/multifirefox";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.linux;
  };
}
