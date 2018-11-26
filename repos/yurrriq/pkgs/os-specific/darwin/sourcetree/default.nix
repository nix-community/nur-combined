{ fetchzip, lib, stdenv }:

stdenv.mkDerivation rec {
  name = "sourcetree-${version}";
  version = "3.0.1_205";

  src = fetchzip {
    url = "https://product-downloads.atlassian.com/software/sourcetree/ga/Sourcetree_${version}.zip";
    sha256 = "1wx7vimjm9zn5jvqa5m4768pvvl7hqlj7v3mg5zr0z47r1bxz54n";
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
