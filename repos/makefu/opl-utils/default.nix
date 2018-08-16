{ stdenv, lib, pkgs, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "opl-utils";
  version = "881c0d2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "ifcaro";
    repo = "open-ps2-loader";
    rev = version;
    sha256 = "1c2hgbyp5hymyq60mrk7g0m3gi00wqx165pdwwwb740q0qig07d1";
  };


  preBuild = "cd pc/";

  installPhase = ''
    mkdir -p $out/bin
    cp */bin/* $out/bin
  '';

  meta = {
    homepage = https://github.com/ifcaro/Open-PS2-Loader;
    description = "open-ps2-loader utils (opl2iso,iso2opl,genvmc)";
    ## not yet in stable
    # license = lib.licenses.afl3;
  };
}
