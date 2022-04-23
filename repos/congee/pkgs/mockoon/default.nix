{ stdenv
, lib
, fetchurl

, alsaLib  # libasound
, atk
, gtk3
, libxkbcommon
, xorg
, mesa  # libgbm
, nspr
, nss

, systemd

, dpkg
, autoPatchelfHook
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "mockoon";
  vnum = "1.18.1";
  version = "v${vnum}";

  src = fetchurl {
    url = "https://github.com/mockoon/mockoon/releases/download/v${vnum}/mockoon-${vnum}.deb";
    sha256 = "sha256-D7CyW5ku3naCaAn4rA7zZ2WBFmqVT9vrn9f88wmx4Tw=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];
  buildInputs = [
    alsaLib
    atk
    gtk3
    libxkbcommon
    xorg.libxshmfence
    mesa
    nspr
    nss
  ];

  runtimeDependencies = [
    systemd
  ];

  dontConfig = true;
  dontBuild = true;

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/share/mockoon $out/lib $out/bin

    mv usr/share/* $out/share
    mv opt/Mockoon/* $out/share/mockoon
    ln -s $out/share/mockoon/*.so $out/lib

    makeWrapper $out/share/mockoon/mockoon $out/bin/mockoon --add-flags --disable-gpu-sandbox

    sed -i 's|\/opt\/Mockoon|'$out'/bin|g' $out/share/applications/mockoon.desktop
  '';

  meta = with lib; {
    description = "Mockoon is the easiest and quickest way to run mock APIs locally. No remote deployment, no account required, open source.";
    homepage = "https://mockoon.com/";
    licenses = licenses.mit;
    maintainers = with maintainers; [ congee ];
    mainProgram = "mockoon";
  };
}
