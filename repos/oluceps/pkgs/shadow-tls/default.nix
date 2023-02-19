{ lib
, fetchFromGitHub
, pkgs
}:

let

  rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.fenix.minimal) cargo rustc; };
in
rustPlatform.buildRustPackage rec{
  pname = "shadow-tls";
  version = "0.2.3";

  src = fetchFromGitHub {
    rev = "44ed093e69097f611a890651152e2d721a51c6f3";
    owner = "ihciah";
    repo = pname;
    sha256 = "sha256-k9Ig/PoQ2HLIBd9lUvH6Tb7JAa7wnJJ+kNGfvJH6bOw=";
  };

  cargoSha256 = "sha256-3jTrJqwClIrokotfedjVsrYnlB/BKDeKgtpHlc8gWFU=";

  meta = with lib; {
    homepage = "https://github.com/ihciah/shadow-tls";
    description = ''
      A proxy to expose real tls handshake to the firewall.
    '';
    #    maintainers = with maintainers; [ oluceps ];
  };
}
