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
    rev = "17a20390eec321cff767c974de9db8d513310b3c";
    hash = "sha256-2PWKo+P8X3lWK2bFWVbtq4mP7URN9/sLi+sCbKmQT1w=";
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
