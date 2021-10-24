{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "alquitran";
  version = "unstable-2021-10-03";

  src = fetchFromGitHub {
    owner = "ferivoz";
    repo = "alquitran";
    rev = "9f01e25753b1c6185cd0d06554983a10da98e7e8";
    sha256 = "0m384n199jb6wx483z3f3in367kpq5alxbxdvyk7ypiacx1a9s7b";
  };

  cargoPatches = [
    ./Cargo.lock.patch
  ];
  cargoSha256 = "0lr4fx5chgxvsjbjqlz8c0h7mrq3bahvrg758spjdw1da727cp35";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    installManPage man/alquitran.1
  '';

  meta = with lib; {
    description = "Analysis tool for tar archives";
    homepage = "https://github.com/ferivoz/alquitran";
    license = licenses.mit;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.all;
  };
}
