/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./jaq.nix {}'
*/

{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "jaq";
  version = "unstable-2022-06-27";

  src = fetchFromGitHub {
    owner = "01mf02";
    repo = pname;
    rev = "50184ac76db411c5cba55a275b31e5f889c82005";
    sha256 = "sha256-qXG89SSE9/pB27nIqxy+C5LdQY4Q+gA0PiLMEH8Woyw=";
  };

  cargoSha256 = "sha256-UbB1D+nkPfZifTUR5ooxvKpjUdC+uGUdXcpoOFpaMoc=";

  meta = with lib; {
    description = "A jq clone focussed on correctness, speed, and simplicity";
    homepage = "https://github.com/01mf02/jaq";
    license = licenses.mit;
    maintainers = with maintainers; [ milahu ];
    platforms = platforms.all;
  };
}
