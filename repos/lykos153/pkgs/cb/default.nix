{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "cb";
  version = "5b0e05162e1ae5f98d7c69a660a9b3dbdcfd8987";
  src = fetchurl {
    url = "https://raw.githubusercontent.com/javier-lopez/learn/${version}/sh/tools/cb";
    sha256 = "sha256-uy0awMlj1BZhWgpTKPPeNQHvOhWbseFVCnE2vOlpeBY=";
  };

  preferLocalBuild = true;

  unpackPhase = "true";

  installPhase = ''
    install -Dm755 $src $out/bin/cb
  '';

  meta = with lib; {
    description = "unify the copy and paste commands into one intelligent chainable command";
    homepage = "https://github.com/javier-lopez/learn/blob/master/sh/tools/cb";
    platforms = platforms.all;
  };
}
