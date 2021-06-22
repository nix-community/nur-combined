{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "bunnyfetch";
  version = "unstable-2021-06-16";

  src = fetchFromGitHub {
    owner = "Rosettea";
    repo = pname;
    rev = "dd3b43c5afc2e942c8e7b1109ffc917bc6f4a606";
    sha256 = "sha256-F0aGLrnqkxpkiPaIKhMOlLtAy+wigrEBhNHhvMw6lqo=";
  };

  cargoSha256 = "sha256-4/kRkL3KHFtAQGxcNrmoa5+4yvLcvtD3CC0svvAtf4I=";

  meta = with lib; {
    description = "Tiny system info fetch utility. ";
    homepage = "https://github.com/Rosettea/bunnyfetch/tree/rs";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
