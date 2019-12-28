with import <nixpkgs> {};

notmuch.overrideAttrs ( oldAttrs: {
  buildInputs = with pkgs; [
    gnupg
    xapian gmime3 talloc zlib
    perl
    pythonPackages.python
  ];
  postPatch = ''
    patchShebangs configure
    patchShebangs test/

    substituteInPlace lib/Makefile.local \
      --replace '-install_name $(libdir)' "-install_name $out/lib"
  '';
  doCheck = false;
})
