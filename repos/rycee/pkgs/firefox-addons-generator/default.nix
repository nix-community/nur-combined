{ mkDerivation, aeson, base-noprelude, directory, fetchgit, hnix
, lens, lens-aeson, relude, stdenv, text, wreq
}:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.4.0";
  src = fetchgit {
    url = "https://gitlab.com/rycee/nixpkgs-firefox-addons";
    sha256 = "08sm33f73iy0ql6q356jblwqq09xpnfs0rwx4860vzlr5s65q22q";
    rev = "v${version}";
    fetchSubmodules = false;
  };
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [
    aeson base-noprelude directory hnix lens lens-aeson relude text
    wreq
  ];
  homepage = "https://gitlab.com/rycee/nix-firefox-addons";
  description = "Tool generating a Nix package set of Firefox addons";
  license = stdenv.lib.licenses.gpl3;
  maintainers = with stdenv.lib.maintainers; [ rycee ];
}
