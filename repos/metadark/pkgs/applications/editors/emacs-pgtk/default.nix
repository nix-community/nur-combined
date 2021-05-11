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
    rev = "486e77befd2ea7fd750b1f24eb5dfaf2b91d70b3";
    hash = "sha256-CbIpL/e8u6jCdSEd3MhGgkLIcmEcA7C5VYpEF0u7COY=";
  };

  patches = [ ];

  configureFlags = attrs.configureFlags ++ [
    "--with-pgtk"
  ];

  meta = attrs.meta // (with lib; {
    description = "Emacs with pure GTK3 support";
    homepage = "https://git.savannah.gnu.org/cgit/emacs.git/log/?h=feature/pgtk";
    maintainer = with maintainers; [ metadark ];
  });
})
