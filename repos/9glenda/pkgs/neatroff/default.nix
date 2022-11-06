{ pkgs, stdenv, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "neatroff";
  version = "0.0.1";
  # src = ./.;
  src = pkgs.fetchFromGitHub {
    owner = "aligrudi";
    repo = "neatroff";
    rev = "f8e3db6d29a44708872dd51a57b74033fdac41b6";
    sha256 = "qEnQ5r+VRxjI2Ke0bKwIPCrptfajJMfMa5zSvX/G9wc=";
  };
  buildInputs = with pkgs; [ gnumake ];
  buildPhase = ''
    make
  '';
  installPhase = ''
    mkdir -p $out/bin
    install roff $out/bin/neatroff
    install roff $out/bin/rofff
  '';
}
