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
    rev = "b9f4df42330ca687cf7b18b42acc5f5d254220d9";
    sha256 = "05xq46kb9l6yh1m3xrvb5y7kypij21a4w8dp105mmnmrb6272a86";
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
