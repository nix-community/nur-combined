{ lib
, stdenv
, fetchFromGitHub
, xorg
, freetype
}:

stdenv.mkDerivation rec {
  pname = "ragnar";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "cococry";
    repo = "Ragnar";
    rev = version;
    hash = "sha256-OZhIwrKEhTfkw9K8nZIwGZzxXBObseWS92Y+85HmdNs=";
  };

  /*
  FREETYPEINC = /usr/include/freetype2
  cp -f ragnar /usr/bin
  cp -f ragnar.desktop /usr/share/applications
  cp -f ragnarstart /usr/bin
  chmod 755 /usr/bin/ragnar
  rm -f /usr/bin/ragnar
  rm -f /usr/share/applications/ragnar.desktop
  */

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/include/freetype2" "${freetype.dev}/include/freetype2" \
      --replace "/usr/" "$out/"
  '';

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
  '';

  buildInputs = [
    xorg.xorgproto
    xorg.libXcursor
    xorg.libX11
    xorg.libXft
    xorg.libXcomposite
    freetype
  ];

  meta = with lib; {
    description = "Minimal, flexible & user-friendly X tiling window manager";
    homepage = "https://github.com/cococry/Ragnar";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "ragnar";
    platforms = platforms.all;
  };
}
