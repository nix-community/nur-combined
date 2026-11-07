{
  callPackage,
  fetchFromGitea,
}:

let
  upstream = fetchFromGitea {
    domain = "codeberg.org";
    owner = "buckley310";
    repo = "brave-browser-nix";
    rev = "35bfbc3349e6145f9b4cc840b8c0ced7121c55a2";
    hash = "sha256-1kahbxlsma1KNavOrhBjgRnyzieWTwlij7DkkfDVxEQ=";
  };
in
(callPackage (upstream + "/brave") { }).brave-origin
