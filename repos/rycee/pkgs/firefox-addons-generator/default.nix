{ mkDerivation, aeson, base-noprelude, directory, fetchgit, hnix
, microlens-aeson, microlens-platform, relude, stdenv, text, wreq
}:

mkDerivation rec {
  pname = "nixpkgs-firefox-addons";
  version = "0.7.0";
  src = fetchgit {
    url = "https://gitlab.com/rycee/nixpkgs-firefox-addons";
    sha256 = "1kva943vzbkpn3x8fi5xclwhcg3m0s74i9bzsvn3q6fwsz3xd10i";
    rev = "v${version}";
    fetchSubmodules = false;
  };
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [
    aeson base-noprelude directory hnix microlens-aeson
    microlens-platform relude text wreq
  ];
  homepage = "https://gitlab.com/rycee/nix-firefox-addons";
  description = "Tool generating a Nix package set of Firefox addons";
  license = stdenv.lib.licenses.gpl3;
  maintainers = with stdenv.lib.maintainers; [ rycee ];
}
