{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hackernews-tui";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kAVH4ezdvm84Jc5llvdCdqfyTmsqBYKx/4S9VyP6keI=";
  };

  cargoSha256 = "sha256-uIP1Eh2dm9uXh628L8sB6bd4jJZetPqVQReptCsoCNk=";

  meta = with lib; {
    description = "Terminal UI to browse Hacker News";
    homepage = "https://github.com/aome510/hackernews-TUI";
    license = with licenses; [ mit ];
    mainProgram = "hackernews_tui";
  };
}
