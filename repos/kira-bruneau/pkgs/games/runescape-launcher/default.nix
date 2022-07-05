{ lib, stdenv, fetchurl, dpkg }:

stdenv.mkDerivation rec {
  pname = "runescape-launcher";
  version = "2.2.10";

  # Debian Repo:
  # curl https://content.runescape.com/downloads/ubuntu/dists/trusty/Release
  # curl https://content.runescape.com/downloads/ubuntu/dists/trusty/non-free/binary-amd64/Packages
  src = fetchurl {
    url = "https://content.runescape.com/downloads/ubuntu/pool/non-free/r/${pname}/${pname}_${version}_amd64.deb";
    sha256 = "sha256-YnAxxs4MzXQns3Y1O/PoL7xnr51dGtoyDbehjLm3KjE=";
  };

  # What about fhs wrapper?
  outputs = [ "out" "doc" ];

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r usr/* "$out"
    runHook postInstall
  '';

  # Avoid modifying the executable to comply with the license
  dontPatchELF = true;
  dontStrip = true;

  postFixup = ''
    substituteInPlace "$out/bin/${pname}" \
      --replace /usr/share/games/${pname} "$out/share/games/${pname}"

    substituteInPlace "$out/share/applications/${pname}.desktop" \
      --replace /usr/bin/${pname} ${pname}
  '';

  meta = with lib; {
    description = "RuneScape Game Client (NXT)";
    homepage = "https://www.runescape.com";
    license = {
      fullName = "RuneScape EULA";
      url = "http://content.runescape.com/downloads/LICENCE.txt";
      free = false;
    };
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = [ "x86_64-linux" ];
  };
}
