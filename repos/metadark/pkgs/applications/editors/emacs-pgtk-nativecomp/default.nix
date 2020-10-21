{ lib, emacs, fetchFromGitHub, ... }@args:

(emacs.override (removeAttrs args [ "lib" "emacs" "fetchFromGitHub" ] // {
  srcRepo = true;
  nativeComp = true;
})).overrideAttrs (attrs: rec {
  pname = "emacs";
  version = "28.0.50";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "fejfighter";
    repo = "emacs";
    rev = "2a5c6fb044dc960f80285397819d6fd391bbc9ae";
    sha256 = "0bjdigijrjlkzlv083mh810afl51w7a02wxxh90bp7qvn2r7c6ac";
  };

  patches = [ ];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk"
    "--with-cairo"
  ];

  meta = attrs.meta // (with lib; {
    description = "Emacs with pure GTK3 & native compilation support";
    homepage = "https://github.com/fejfighter/emacs/tree/pgtk-nativecomp";
    maintainer = with maintainers; [ metadark ];
  });
})
