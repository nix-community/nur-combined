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
    rev = "2d5e81ce9487217f87c954af0c501a9515b67413";
    sha256 = "18kd82h1ib1ldar2ikcf9w1jdqhjmwbak8yccbbga4yk3szymyja";
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
