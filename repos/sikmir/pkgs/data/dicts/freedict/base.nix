{ lib, stdenvNoCC, fetchurl, lang, version, hash }:

stdenvNoCC.mkDerivation {
  pname = "freedict-${lang}";
  inherit version;

  src = fetchurl {
    url = "https://download.freedict.org/dictionaries/${lang}/${version}/freedict-${lang}-${version}.dictd.tar.xz";
    inherit hash;
  };

  installPhase = ''
    install -Dm644 **.{dict.dz,index} -t $out
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "FreeDict (${lang})";
    homepage = "https://freedict.org";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
