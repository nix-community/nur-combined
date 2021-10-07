{ buildGoPackage, lib, fetchFromGitHub, stdenv }:
buildGoPackage  {
  pname = "slit";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "tigrawap";
    repo = "slit";
    rev = "3ba0779af678330d86b81a1edce32d5cc4fe785f";
    sha256 = "0gfqkk70fd4fx1jqlijk4lz7s63jkrzqlhjgqlm847i89lfdvhw1";
  };
  goDeps = ./deps.nix;
  goPackagePath = "github.com/tigrawap/slit";

  meta = {
    description = "a modern pager for viewing logs";
    homepage = "https://github.com/tigrawap/slit";
    license = lib.licenses.mit;
  };
}
