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
    rev = "a9829672f70ec0c6cd9d7e6b09ba762ea22e86b5";
    sha256 = "0j5db79jl6sgsjznr631kvqha2sp8wpwwkfk8qdsdbc8lw7svdh4";
  };

  patches = [];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk" "--with-cairo"
  ];

  postInstall = builtins.replaceStrings [ attrs.version ] [ version ] attrs.postInstall;

  meta = attrs.meta // (with lib; {
    description = "Emacs with pure GTK3 to support Wayland";
    homepage = "https://github.com/masm11/emacs";
    maintainer = with maintainers; [ metadark ];
  });
})
