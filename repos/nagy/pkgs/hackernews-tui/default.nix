{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-OPfFNBg9UZtBFRJiNvA9YIK/Fp3xPA2AHoUa3brZX9o=";
  };

  cargoSha256 = "18dj6pdl2c4wffd87d96m6ja5nkncm8yy09i52vn5d7gg3zyv7qv";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
  };
}
