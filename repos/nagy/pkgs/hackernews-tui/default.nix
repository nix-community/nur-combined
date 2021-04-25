{ lib, fetchFromGitHub, rustPlatform }:
rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    sha256 = "02hifn5vi69c9vg1ldgflhiv5g881php0fbns1ghhvpmfgz0zhqp";
  };

  cargoSha256 = "17nl614j9yciy3mi28lx0fb9i4812kra8a94v377k0whvyzprqkj";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    maintainers = with maintainers; [ ];
    license = with licenses; [ mit ];
  };
}
