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
    rev = "54ef44216cef3480d69b4da2f46b8db5b0249d64";
    sha256 = "04fkxc2rd32w55x1yn5pk3kmwrrq9r36m2v0ykva0wvrwbjmibr5";
  };

  patches = [];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk" "--with-cairo"
  ];

  postInstall = builtins.replaceStrings [ attrs.version ] [ version ] attrs.postInstall;

  meta = attrs.meta // {
    description = "Emacs with pure GTK3 support to support Wayland";
    homepage = "https://github.com/masm11/emacs";
  };
})
