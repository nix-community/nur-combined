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
    rev = "bca518d77b2ad51f577035e5b82b407117434c25";
    sha256 = "1hq0vx98smsay1ycrspp4rykq9yqb3746kgnl06c4dd02djlnhjh";
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
