{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    sha256 = "15ly7bl4lid3l2h6n9xc62326pqplgy3gjx7kd5cgr203ar18x32";
  };

  cargoSha256 = "18dj6pdl2c4wffd87d96m6ja5nkncm8yy09i52vn5d7gg3zyv7qv";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    maintainers = with maintainers; [ ];
    license = with licenses; [ mit ];
  };
}
