{ stdenv, makeWrapper, fetchFromGitHub, nix }:

stdenv.mkDerivation rec {
  pname = "nixos-shell";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = version;
    sha256 = "19m4k715lfagk606mvkal6g3g8rv7gj2jjyxpls952fiz187m3ph";
  };

  nativeBuildInputs = [ makeWrapper ];
  installFlags = [ "PREFIX=${placeholder "out"}"];

  postInstall = ''
    wrapProgram $out/bin/nixos-shell \
      --prefix PATH : ${stdenv.lib.makeBinPath [ nix ]}
  '';
}
