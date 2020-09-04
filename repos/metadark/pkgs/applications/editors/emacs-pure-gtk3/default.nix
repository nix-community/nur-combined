{ lib, emacs, fetchFromGitHub }:

(emacs.override {
  srcRepo = true;
}).overrideAttrs (attrs: rec {
  pname = "emacs";
  version = "28.0.50";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "masm11";
    repo = "emacs";
    rev = "fad3ca10df03582e30307a84a9ee8a94a07b2182";
    sha256 = "08vxvjwly35clrb2jbdqdp9kshm1338f98knk24fg38dh0c1mpcf";
  };

  patches = [ ];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk"
    "--with-cairo"
  ];

  meta = attrs.meta // (with lib; {
    description = "Emacs with pure GTK3 to support Wayland";
    homepage = "https://github.com/masm11/emacs";
    maintainer = with maintainers; [ metadark ];
  });
})
