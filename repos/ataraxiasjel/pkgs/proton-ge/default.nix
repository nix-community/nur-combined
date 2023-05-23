{ stdenv
, lib
, fetchurl
}:
stdenv.mkDerivation rec {
  name = "proton-ge-custom";
  version = "GE-Proton8-3";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    hash = "sha256-JYGwb0LhIs6B2/OHiU+mJ/dAAS+Dg+MrVksAsn6IS9g=";
  };

  buildCommand = ''
    runHook preBuild

    mkdir -p $out/bin
    tar -C $out/bin --strip=1 -x -f $src

    runHook postBuild
  '';

  meta = with lib; {
    description = "Compatibility tool for Steam Play based on Wine and additional components";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
