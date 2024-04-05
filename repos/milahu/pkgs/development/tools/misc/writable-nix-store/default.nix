{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "writable-nix-store";
  version = "unstable-2024-04-05";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "writable-nix-store";
    rev = "9f323face93bdbf52c45a21037353dc0027d3b97";
    hash = "sha256-GTL9PPYGhlUfpCmHE5w63OrEh2dzGcqg4eYJ7EF6k/o=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp writable-nix-store.js $out/bin/writable-nix-store
  '';

  meta = with lib; {
    description = "Get temporary write access to the nix store";
    homepage = "https://github.com/milahu/writable-nix-store";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "writable-nix-store";
    platforms = platforms.all;
  };
}
