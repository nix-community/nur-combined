{ lib, fetchFromGitHub, stdenv, gdb }:

stdenv.mkDerivation rec {
  name = "gdb-prompt";
  src = fetchFromGitHub {
    owner = "Freed-Wu";
    repo = name;
    rev = "db4e8965a1a9624a142d84e6c81e13a0057433a8";
    hash = "sha256-gcxNV2OP2byas3EGaPpCPBgQPuy1Cp8eZW4rct+DxWc=";
  };

  buildInputs = [ gdb ];
  installPhase = ''
    install -D gdb-prompt -t $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/Freed-Wu/gdb-prompt";
    description = "A powerlevel10k-like prompt for gdb";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
