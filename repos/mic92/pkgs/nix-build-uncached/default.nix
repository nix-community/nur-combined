{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, nix }:

buildGoModule rec {
  pname = "nix-build-uncached";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-build-uncached";
    rev = "v${version}";
    sha256 = "0jkpg3ab56lg2kdms9w9ka9ba89py3ajksjsi1rd3iqi74zz2mmh";
  };

  vendorSha256 = null;

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
