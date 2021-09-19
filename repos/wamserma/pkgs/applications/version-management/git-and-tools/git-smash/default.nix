{ lib, fetchFromGitHub, rustPlatform }:

let
  pname = "git-smash";
  version = "0.0.2";
in
rustPlatform.buildRustPackage {
  inherit pname;
  inherit version;
  src = fetchFromGitHub {
    owner = "anthraxx";
    repo = pname;
    rev = version;
    sha256 = "05xb27lh74yvv4kf0wc75vgjlqy1jcg841c459jv8fki3vvarkxs";
  };

  cargoSha256 = "0h7k99l5gwvz9n25ina6hgkvzygjflazrkqjlhrbqsggails8765";

  meta = {
    description = "Smash staged changes into previous commits to support your Git workflow, pull request and feature branch maintenance";
    homepage = "https://github.com/anthraxx/git-smash";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.wamserma ];
  };
}
