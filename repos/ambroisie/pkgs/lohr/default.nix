{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "lohr";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "alarsyo";
    repo = "lohr";
    rev = "v${version}";
    sha256 = "sha256-MplTVJG+SoeLMXQP+ix/zM3OSHuQmZnunn900YnyCBw=";
  };

  cargoSha256 = "sha256-iuMJj8tqetlmdfsrfudnU1afwUzjls/UdYLq1u0gr+g=";

  meta = with lib; {
    description = "Git mirroring daemon";
    homepage = "https://github.com/alarsyo/lohr";
    license = with licenses; [ mit asl20 ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ ambroisie ];
  };
}
