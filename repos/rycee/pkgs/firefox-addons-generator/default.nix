{ mkDerivation, aeson, base-noprelude, directory, fetchgit, hnix
, lens, lens-aeson, relude, stdenv, text, wreq
}:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.3.0";
  src = fetchgit {
    url = "https://gitlab.com/rycee/nixpkgs-firefox-addons";
    sha256 = "0ky71y28dcar8lnrsi7fnc8r0imwn3lzl329cpm5kh8a2h42h0s5";
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
