/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
*/

{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "jaq";
  version = "unstable-2022-06-07";

  src = fetchFromGitHub {
    owner = "01mf02";
    repo = pname;
    rev = "0b9e0b8296e8d664a3f6b8342bfc3077b27e9ca0";
    sha256 = "sha256-Njcw8FdcBBAorJWRvaPGF62Gsl0wWXL5NMzIe7CCwGY=";
  };

  cargoSha256 = "sha256-OkZGPYzeq8OdBFCBSz8q+3+MFMiPg4BKp3enA3Ws1ck=";

  meta = with lib; {
    description = "A jq clone focussed on correctness, speed, and simplicity";
    homepage = "https://github.com/01mf02/jaq";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.all;
  };
}
