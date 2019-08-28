{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  name = "roboto-mono-nerd";
  src = fetchzip {
    url =
      "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/RobotoMono.zip";
    sha256 = "sha256:1i78fn62x0337p2974dn1nga1pbdi7mqg203h81yi9b79pyxv9bh";
    stripRoot = false;
  };
  installPhase = "mkdir -p $out/share/fonts; cp $src/* $out/share/fonts";
}
