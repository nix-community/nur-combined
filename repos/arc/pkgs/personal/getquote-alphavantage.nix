{ wrapShellScriptBin, fetchFromGitHub, coreutils, curl, jq }:
let
  rev = "6f426157f700fb7291aa0fd0ff74cc422b5ad9eb";
  src = fetchFromGitHub {
    inherit rev;
    owner = "arcnmx";
    repo = "getquote-alphavantage";
    sha256 = "101fzxd64f48683zn3f43qgxi69d8ygmipb59piq7a95gwknfvsc";
  };
in
wrapShellScriptBin "getquote" src {
  depsRuntimePath = [coreutils curl jq];
  name = "getquote-alphavantage-${rev}";
  version = rev;
  source = "${src}/getquote";
}
