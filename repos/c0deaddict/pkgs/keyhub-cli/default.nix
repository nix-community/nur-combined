{ lib, stdenv, fetchurl, unzip, runtimeShell, writeScriptBin, python3
, autoPatchelfHook, zlib, glibc }:

let

  wrapper = writeScriptBin "keyhub.py" ''
    #!${python3}/bin/python3 -u
    ${builtins.readFile ./keyhub.py}
  '';

in stdenv.mkDerivation rec {
  name = "keyhub-cli-${version}";
  version = "18.2";

  src = fetchurl {
    url = "https://files.topicus-keyhub.com/manual/keyhub-cli-${version}.zip";
    sha256 = "189gffg73sws1b5hbi1nna2q6qyvm1wfn5w10s9m03an87bgqxpb";
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
