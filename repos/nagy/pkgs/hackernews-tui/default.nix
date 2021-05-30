{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ha18x1w7557j1gfhmsdv270gc4zwfhvw92sakm2lqbgvmkjpwpj";
  };

  cargoSha256 = "1sfliybwxr77wbi38sahlazk1hqiji3hv9ppi90aj4cmcpv5nahl";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    maintainers = with maintainers; [ ];
    license = with licenses; [ mit ];
  };
}
