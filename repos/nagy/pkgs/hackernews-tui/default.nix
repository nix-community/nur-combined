{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    sha256 = "1kr92x3dwijqxv6sza4l6imc8h9jkjnp4kc8jqv5iialh12iak7q";
  };

  cargoSha256 = "1jwm02aiwf70lshy9ywzk0a7cfg6hn8hakyhvh0b3d9q0mwq01d5";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    maintainers = with maintainers; [ ];
    license = with licenses; [ mit ];
  };
}
