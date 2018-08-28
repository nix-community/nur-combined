{ fetchzip, lib, stdenv }:

stdenv.mkDerivation rec {
  name = "sourcetree-${version}";
  version = "2.7.6a";

  src = fetchzip {
    url = "https://downloads.atlassian.com/software/sourcetree/Sourcetree_${version}.zip";
    sha256 = "0mbaz6rflpwaf77hg9w64kxw55k7cbkmrzpwcq8rlz2ka5yvd37i";
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
