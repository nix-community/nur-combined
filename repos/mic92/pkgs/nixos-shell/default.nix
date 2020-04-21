{ stdenv, makeWrapper, fetchFromGitHub, nix }:

stdenv.mkDerivation rec {
  pname = "nixos-shell";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = version;
    sha256 = "1qk5a01vh6wbbkib8xr57w1j4l3n6xdjd46nsw9bsa444fzlc0wr";
  };

  nativeBuildInputs = [ makeWrapper ];
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    wrapProgram $out/bin/nixos-shell \
      --prefix PATH : ${stdenv.lib.makeBinPath [ nix ]}
  '';
}
