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
    rev = "66c40430c7bf526939f24f38d161ed90bc9d8b01";
    sha256 = "18fbdz9k17711bd7nd5yfkm3042vi50w9pippvaspzwrw0h7gv2z";
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
