{ stdenv, lib, fetchurl, fetchgit, makeWrapper, firefox, gnome }:

let
  desktopFile = fetchurl {
    url = "https://gist.githubusercontent.com/mildred/c44d6ca8ac76333ca4a2/raw/f71167ad2e35a2bb2166047e5ecfd7c0a5ea17ad/multifirefox.desktop";
    sha256 = "sha256-m/BjqfgQ0RCdCRSmIly3jzpwlQ3HaHu+mejGScWo/vY=";
  };

in stdenv.mkDerivation {
  pname = "multifirefox";
  version = "unstable-2023-04-18";

  src = fetchgit {
    url = "https://codeberg.org/wolfangaukang/multifirefox";
    rev = "ddf4f4965d0a78d1429d9475f0fb6968ee3bc7b8";
    sha256 = "sha256-ohBOEs5Th1k0rv2Lp/vvP7EQNQYBuEdA0+5nQjSRfNE=";
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
