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
    rev = "0b9329428f00f78a8a7fd952f94ae051178e2f16";
    sha256 = "1hgbrr110crvhq7avqhsp5f8yzwx4hnrjddpxr8aaqma8pjqfqnr";
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
