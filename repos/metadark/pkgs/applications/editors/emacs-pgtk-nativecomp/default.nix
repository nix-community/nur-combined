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
    rev = "1cf25c5a2038d4e79fbb610193ae4ccbc7457f57";
    hash = "sha256:1vaaalzj1njzgs9ksi96j0hln711ry62ihgiy08ifvl0wz4piiz3";
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
