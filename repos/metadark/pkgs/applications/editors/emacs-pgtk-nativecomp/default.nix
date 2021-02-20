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
    rev = "c22339c9d51b1bc762a837a1b77118f17391d3f0";
    hash = "sha256-65weT5rpCihCroFL0LSzBSoMLMYkPXdJSc6GQb3QDYQ=";
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
