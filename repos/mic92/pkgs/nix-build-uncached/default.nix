{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, nix }:

buildGoModule rec {
  pname = "nix-build-uncached";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-build-uncached";
    rev = "v${version}";
    sha256 = "0gl6y6qsd7d3b9il8zqb8w4wq0crqqr38d0nx23d5hfqf8adv6si";
  };

  modSha256 = "1fl0wb1xj4v4whqm6ivzqjpac1iwpq7m12g37gr4fpgqp8kzi6cn";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/nix-build-uncached \
      --prefix PATH ":" ${stdenv.lib.makeBinPath [ nix ]}
  '';

  goPackagePath = "github.com/Mic92/nix-build-uncached";

  meta = with stdenv.lib; {
    description = "A CI friendly wrapper around nix-build.";
    homepage = "https://github.com/Mic92/nix-build-uncached";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
