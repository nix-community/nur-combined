{ stdenv, fetchzip, autoPatchelfHook, alsaLib }:

# currently unable to build from source:
#   cargo-vendor doesn't seem to handle git sources well enough
#   and carnix outputs invalid Nix
stdenv.mkDerivation rec {
  name = "spotifyd-${version}";
  version = "v0.2.2";

  src = fetchzip {
    url = "https://github.com/Spotifyd/spotifyd/releases/download/${version}/spotifyd-2018-06-23-amd64.zip";
    sha256 = "0g60f5q6ra1y61716q4rj01k5xqjhq67yp8bpy2wv9ck8s08gmf3";
  };

  nativeBuildInputs = [ autoPatchelfHook alsaLib ];

  installPhase = ''
    install -D $src/spotifyd $out/bin/spotifyd
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/bin/spotifyd
  '';

  meta = with stdenv.lib; {
    description = "A spotify daemon";
    homepage = https://github.com/Spotifyd/spotifyd;
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
