let
  rev = "f5d3a1204c7e314802c1d00c7c596fdf5b8229a8";
  sha256 = "17i9vrfgd7zw0ycsmw651zrjfy6kyif9bvlykrkd87m75d64cb2m";
  clip = builtins.fetchTarball {
    url = "https://github.com/arcnmx/clip/archive/${rev}.tar.gz";
    inherit sha256;
  };
#in import (clip + "/derivation.nix")
# NUR doesn't like this IFD so inline it here instead:
in { stdenvNoCC
, makeWrapper
, coreutils
, enableX11 ? stdenvNoCC.isLinux
, xsel ? null
, enableWayland ? stdenvNoCC.isLinux
, wl-clipboard ? null
, fetchFromGitHub
}: with stdenvNoCC.lib;

assert enableX11 -> xsel != null;
assert enableWayland -> wl-clipboard != null;

stdenvNoCC.mkDerivation {
  pname = "clip";
  version = "0.0.1"; # idk

  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "clip";
    inherit rev sha256;
  };

  nativeBuildInputs = [ makeWrapper ];

  wrappedPath = makeSearchPath "bin" ([ coreutils ]
    ++ optional enableX11 xsel
    ++ optional enableWayland wl-clipboard
  );

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper clip.sh $out/bin/$pname \
      --prefix PATH : $wrappedPath
  '';
}
