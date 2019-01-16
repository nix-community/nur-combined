{ stdenv, rustNightlyPlatform, fetchFromGitLab }: 

rustNightlyPlatform.buildRustPackage rec {
  name = "nix-lsp-${version}";
  version = "2018-11-18";

  cargoSha256 = "0n4a684ybh109pdi5i40zqca532k3ir5scykp4hl89qjbvaf1frh";

  src = fetchFromGitLab {
    owner = "jD91mZM2";
    repo = "nix-lsp";
    rev = "24ac35f05320711185366c921a9306e240eda164";
    sha256 = "0wxg2199x8yv7bkqql2fj4c148kznjbk1mcp6kbh3k419hj1ck6x";
  };

  meta = with stdenv.lib; {
    description = "Language Server for Nix";
    homepage = https://gitlab.com/jD91mZM2/nix-lsp;
    license = licenses.mit;
  };
}
