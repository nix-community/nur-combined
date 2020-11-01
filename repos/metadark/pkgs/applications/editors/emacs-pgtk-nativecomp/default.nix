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
    rev = "331f30c4a0011e6aaa306ff101c5a0274b2d8b62";
    sha256 = "0gv14nvh07k63gj59qx4vm5z555anwlm1vjxn0n3j55aza3d0xlr";
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
