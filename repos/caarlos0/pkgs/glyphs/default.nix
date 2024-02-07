with import <nixpkgs> { };
{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule {
  pname = "glyphs";
  version = "2024-02-06";

  src = fetchFromGitHub {
    owner = "maaslalani";
    repo = "glyphs";
    rev = "main";
    hash = "sha256-AosbD235VOMG+zYFf/14AOUEtHD63aOU4Xwka+e1QN8=";
  };

  vendorHash = "sha256-R1M74SGmooHIsFUkqF4Vj52znKDsXyezrmL9o3fBDws=";

  doCheck = false;

  meta = with lib; {
    description = "Unicode symbols on the command line";
    homepage = "https://github.com/maaslalani/glyphs";
    changelog = "https://github.com/maaslalani/glyphs/commits";
    maintainers = with maintainers; [ caarlos0 ];
    mainProgram = "glyphs";
  };
}
