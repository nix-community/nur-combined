{ pkgs ? import <nixpkgs> { } }:
with pkgs;
stdenv.mkDerivation rec {
  name = "MoonPlus";
  version = "git";
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  installPhase = ''
    install -D bin/release/moonp $out/bin/moonp
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pigpigyyy/MoonPlus";
    description = "Moonscript to Lua compiler";
    license = licenses.mit;
    maintainers = with maintainers; [ xe ];
    platforms = platforms.all;
  };
}
