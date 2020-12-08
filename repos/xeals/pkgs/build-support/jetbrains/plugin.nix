{ lib
, stdenv
, fetchzip
, jetbrainsPlatforms
}:

{ pluginId
, pname
, version
, versionId
, sha256
, filename ? "${pname}-${version}.zip"
}:

stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    inherit sha256;
    url = "https://plugins.jetbrains.com/files/${toString pluginId}/${toString versionId}/${filename}";
  };

  passthru = { inherit jetbrainsPlatforms; };

  installPhase = ''
    mkdir $out
    cp -r * $out/
  '';

  meta = {
    homepage = "https://plugins.jetbrains.com/plugin/${pluginId}-${lib.toLower pname}";
  };
}
