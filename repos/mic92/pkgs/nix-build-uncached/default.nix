{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, nix }:

buildGoModule rec {
  pname = "nix-build-uncached";
  version = "1.0.0rc1";
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-build-uncached";
    rev = "v${version}";
    sha256 = "1br3vzjyrh1ncc8yri0mmxra58nv0y52bv6sspllwjrcmi64ymks";
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
