{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "zellij";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    rev = "v${version}";
    sha256 = "102zw4napzx05rpmx6scl6il55syf3lw1gzmy1y66cg1f70sij4d";
  };

  cargoSha256 = "121fsch0an6d2hqaq0ws9cm7g5ppzfrycmmhajfacfg6wbiax1m5";

  doCheck = false;

  meta = with lib; {
    description = "A terminal workspace with batteries included";
    homepage = "https://github.com/zellij-org/zellij";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ _0x4A6F ];
  };
}
