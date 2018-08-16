{ stdenv, lib, pkgs, fetchurl }:
stdenv.mkDerivation rec {
  pname = "bin2iso";
  version = "1.9b";
  _dlver = builtins.replaceStrings ["."] [""] version;
  name = "${pname}-${version}";

  src = fetchurl {
    url = "http://users.eastlink.ca/~doiron/${pname}/linux/${pname}${_dlver}_linux.c";
    sha256 = "0gg4hbzlm83nnbccy79dnxbwpn7lxl3fb87ka36mlclikvknm2hy";
  };

  unpackPhase = "true";

  buildPhase =''
    gcc -Wall -o $pname $src
  '';

  installPhase = ''
    install -Dm755 $pname $out/bin/$pname
  '';

  meta = {
    homepage = http://users.eastlink.ca/~doiron/bin2iso/ ;
    description = "converts bin+cue to iso";
    license = lib.licenses.gpl3;
  };
}
