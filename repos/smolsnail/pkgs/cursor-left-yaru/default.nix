{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "cursor-left-yaru";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Microtribute";
    repo = pname;
    rev = version;
    sha256 = "1xy8q04wjxlrlwf9kxcna8sv7mpk5b13vcdcp8h8izvnpynwrxgi";
  };

  installPhase = ''
    mkdir -p $out/share/icons/${pname}
    cp -r {cursors,cursor.theme,index.theme} $out/share/icons/${pname}
  '';

  meta = with lib; {
    description = "A set of left-handed cursors for left-handed people.";
    longDescription = ''
      A set of left-handed cursors for left-handed people.
      Flipped the right-hand Yaru cursors and made hotspot adjustments.
      As a bonus, this cursor set has a black hand!
    '';
    homepage = "https://github.com/Microtribute/cursor-left-yaru";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
