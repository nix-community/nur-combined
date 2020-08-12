{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, nix, nixFlakes, runCommandNoCC }:

let
  unwrapped = buildGoModule rec {
    pname = "nix-build-uncached";
    version = "1.0.0";
    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "nix-build-uncached";
      rev = "v${version}";
      sha256 = "106k4234gpi8mr0n0rfsgwk4z7v0b2gim0r5bhjvg2v566j67g02";
    };

    vendorSha256 = null;

    # cannot use nix-build in nix build
    doCheck = false;

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
