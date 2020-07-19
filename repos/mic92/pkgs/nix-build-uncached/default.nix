{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, nix, nixFlakes, runCommandNoCC }:

let
  unwrapped = buildGoModule rec {
    pname = "nix-build-uncached";
    version = "1.0.0rc1";
    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "nix-build-uncached";
      rev = "v${version}";
      sha256 = "1br3vzjyrh1ncc8yri0mmxra58nv0y52bv6sspllwjrcmi64ymks";
    };

    vendorSha256 = null;

    goPackagePath = "github.com/Mic92/nix-build-uncached";

    meta = with stdenv.lib; {
      description = "A CI friendly wrapper around nix-build.";
      homepage = "https://github.com/Mic92/nix-build-uncached";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };
in {
  nix-build-uncached = runCommandNoCC "nix-build-uncached" { nativeBuildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/nix-build-uncached $out/bin/nix-build-uncached \
      --prefix PATH ":" ${stdenv.lib.makeBinPath [ nix ]}
  '';
  nix-build-uncached-flakes = runCommandNoCC "nix-build-uncached-flakes" { nativeBuildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${unwrapped}/bin/nix-build-uncached $out/bin/nix-build-uncached \
      --prefix PATH ":" ${stdenv.lib.makeBinPath [ nixFlakes ]}
  '';
}
