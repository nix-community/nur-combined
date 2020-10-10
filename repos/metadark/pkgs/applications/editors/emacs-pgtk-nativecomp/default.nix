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
    rev = "cfda02f1254b21d5d0109f88e223e48d15e9504c";
    sha256 = "11sxi2yp774nn1ya9g14pp54bmi3whwpmxgy8msxjmw4qllr15pv";
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
