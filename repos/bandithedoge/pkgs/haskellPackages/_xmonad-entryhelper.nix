{
  mkDerivation,
  base,
  directory,
  extensible-exceptions,
  fetchgit,
  filepath,
  lib,
  mtl,
  process,
  unix,
  X11,
  xmonad,
  xmonad-contrib,
}:
mkDerivation {
  pname = "xmonad-entryhelper";
  version = "0.2.0.0";
  src = fetchgit {
    url = "https://github.com/Javran/xmonad-entryhelper";
    sha256 = "1m2hl0jnmq7kb9ix5xmnjh8jj7b7frprw244ykh3jyhq3mns4rh8";
    rev = "ee2d0c14f9258503d7bd62907aa731dd64fa34d0";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    base
    directory
    extensible-exceptions
    filepath
    mtl
    process
    unix
    X11
    xmonad
    xmonad-contrib
  ];
  homepage = "https://github.com/Javran/xmonad-entryhelper";
  description = "XMonad config entry point wrapper";
  license = lib.licenses.mit;
}
