{ lib
, stdenv
, fetchurl
, gnutar
, autoPatchelfHook
, libGL
, glfw3
, openssl
, libpng
, freetype
, assimp
, gnome3
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "wonderland-engine";
  version = "0.8.9";
  src = fetchurl {
    url = "https://downloads.wonderlandengine.com/${version}/WonderlandEngine-${version}-Linux.tar.gz";
    sha256 = "1cl9vcjza6alxhmpb040z9j6i2a91nchilma569jf3hj1g2bywsd";
  };
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ glfw3 stdenv.cc.cc.lib openssl libpng freetype assimp ];
  installPhase = ''
    mkdir $out -p
    cp . $out -r
    find $out | grep '\.so$' | while read -r file; do dirname $file; done | uniq | while read -r dir; do
      RPATH=$dir
    done
    mv $out/bin/WonderlandEditor $out/bin/WonderlandEditorOriginal
    makeWrapper $out/bin/WonderlandEditorOriginal $out/bin/WonderlandEditor \
      --prefix PATH ":" "${lib.makeBinPath [ gnome3.zenity ]}"
  '';
  meta.broken = true;
}
