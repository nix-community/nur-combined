{ lib
, fetchFromGitHub
, fetchurl
, rustPlatform
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "nixpkgs-check";
  version = "0.1.0";
  contributing = fetchurl {
    url = "https://github.com/NixOS/nixpkgs/raw/master/CONTRIBUTING.md";
    sha256 = "11jsw3ffr59qs27xyx70ns3ffzsk9li97z8mbwjgaayy1022qk7a";
  };

  src = fetchFromGitHub {
    owner = "Ekleog";
    repo = "nixpkgs-check";
    rev = "5e718e5fda88c7692e5133cf99a528c720ad5895";
    sha256 = "0mhc498vbbb8pf5w790h7ahb4gplyd7x6ili755q61kx51bfrif5";
  };

  cargoSha256 = "0sfi59l9k37ck2cy1ypxi0g918wb2zyhq2z23887s0x3f9jrxfzq";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  CONTRIBUTING_MD_PATH = contributing;

  doInstallCheck = true;
  installCheckPhase = ''
    if [[ "$("$out/bin/${pname}" --version)" == "nixpkgs-check ${version}" ]]; then
      echo '${pname} smoke check passed'
    else
      echo '${pname} smoke check failed'
      return 1
    fi
  '';

  meta = with lib; {
    description = "A tool to make it easier to run through the usual checklist for PRs to nixpkgs";
    homepage = "https://github.com/Ekleog/nixpkgs-check";
    license = licenses.mit;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
