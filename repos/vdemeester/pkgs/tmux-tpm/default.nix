{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "tmux-tpm";
  rev = "06d41226af02ca4f5bcf58169dd4f0a2aa42218c";
  version = "20200218-${lib.strings.substring 0 7 rev}";

  src = fetchFromGitHub {
    inherit rev;
    owner = "tmux-plugins";
    repo = "tpm";
    sha256 = "1ap5x761abcpw6wd6jb575rws88prkpjygjks9cibvws59xsnki4";
  };

  builder = ./builder.sh;

  meta = {
    description = "Tmux Plugin Manager";
    homepage = "https://github.com/tmux-plugins/tpm";
    license = lib.licenses.mit;
  };
}
