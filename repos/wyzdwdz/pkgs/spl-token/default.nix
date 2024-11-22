{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "spl-token";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "solana-labs";
    repo = "solana-program-library";
    rev = "token-v7.0.0";
    hash = "sha1-JFRShygwvUJSkOcHEr+9kRkTvoI=";
  };

  cargoSha256 = lib.fakeHash;

  cargoBuildFlags = [ "--bin=spl-token" ];

  meta = with lib; {
    description = "Solana Program Library Token";
    homepage = "https://github.com/solana-labs/solana-program-library";
    license = licenses.asl20;
    maintainers = with maintainers; [ wyzdwdz ];
    platforms = platforms.linux;
    broken = true;
  };
}
