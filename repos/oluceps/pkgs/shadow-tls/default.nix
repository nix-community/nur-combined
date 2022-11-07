{ lib
, fetchFromGitHub
, pkgs
, fenix
}:

let
  #fenix = import
  #    (fetchTarball {
  #      url = "https://github.com/nix-community/fenix/archive/main.tar.gz";
  #      sha256 = "sha256:11fv5w0093l2v9v6l5m87al8yf8c2m05fchbw2kadrvh40kb49ii";
  #    })
  #    { system = "x86_64-linux"; };
  ## WARNING: ONLY FLAKE USER COULD USE THIS DERIVATION DIRECTLY

  rustPlatform = pkgs.makeRustPlatform { inherit (fenix.minimal) cargo rustc; };
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
