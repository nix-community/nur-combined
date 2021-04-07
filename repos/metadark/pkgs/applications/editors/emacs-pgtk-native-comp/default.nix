{ lib, emacs, fetchFromGitHub, ... }@args:

(emacs.override (removeAttrs args [ "lib" "emacs" "fetchFromGitHub" ] // {
  srcRepo = true;
  nativeComp = true;
})).overrideAttrs (attrs: rec {
  pname = "emacs";
  version = "28.0.50";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "MetaDark";
    repo = "emacs";
    rev = "5fede5507040743516ffcaea73b250c5e831fb0e";
    hash = "sha256-7nsU+Ww7VIcqc8gvRt3iTBdN9HlSPfUKn77jTrSHJMA=";
  };

  patches = [ ];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk"
    "--with-cairo"
  ];

  meta = attrs.meta // (with lib; {
    description = "Emacs with pure GTK3 & native compilation support";
    homepage = "https://github.com/MetaDark/emacs/tree/feature/pgtk-native-comp";
    maintainer = with maintainers; [ metadark ];
  });
})
