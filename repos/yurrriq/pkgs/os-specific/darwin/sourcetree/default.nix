{ fetchzip, lib, stdenv }:

stdenv.mkDerivation rec {
  name = "sourcetree-${version}";
  version = "3.0_200";

  src = fetchzip {
    url = "https://product-downloads.atlassian.com/software/sourcetree/ga/Sourcetree_${version}.zip";
    sha256 = "0l2syq8k652zlk6g7sy611fxkks2pfzwb2bb9bjw4pblzrx8figk";
  };

  installPhase = ''
    install -dm755 "$out/bin"
    install -dm755 "$out/Applications/SourceTree.app"
    cp -R . "$_"
    ln -s "$_/Contents/Resources/stree" "$out/bin"
  '';

  meta = with lib; {
    description = "A free Git client for Windows and Mac";
    homepage = "https://www.sourcetreeapp.com";
    # TODO: license
    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
