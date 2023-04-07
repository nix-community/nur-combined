{ lib, stdenv, fetchurl, unzip, runtimeShell, writeScriptBin, python3
, autoPatchelfHook, zlib, glibc }:

let

  wrapper = writeScriptBin "keyhub.py" ''
    #!${python3}/bin/python3 -u
    ${builtins.readFile ./keyhub.py}
  '';

in stdenv.mkDerivation rec {
  name = "keyhub-cli-${version}";
  version = "21";

  src = fetchurl {
    url = "https://files.topicus-keyhub.com/manual/keyhub-cli-${version}.zip";
    sha256 = "sha256-Pnzg40WtprMOwULbVXjFVh3kjyGc/0Gv6mWtSfEEAug=";
  };

  buildInputs = [ autoPatchelfHook glibc stdenv.cc.cc zlib ];
  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp linux/keyhub $out/bin
    ln -sf ${wrapper}/bin/keyhub.py $out/bin/keyhub.py
  '';

  meta = with lib; {
    homepage = "https://topicus-keyhub.com/";
    description = "A command line interface to Topicus KeyHub";
    maintainers = with maintainers; [ c0deaddict ];
  };
}
