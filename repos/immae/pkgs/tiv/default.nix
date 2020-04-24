{ buildPerlPackage, fetchurl, perlPackages }:
buildPerlPackage rec {
  pname = "tiv";
  version = "2015";
  src = fetchurl {
    url = "http://xyne.archlinux.ca/projects/tiv/src/tiv-${version}.tar.xz";
    sha256 = "1vq073v7z7vmcd57lhs4rf4jasji69cpjgkz4dykp94a77p1qq90";
  };

  outputs = ["out"];
  buildInputs = with perlPackages; [ PerlMagick ];
  perlPreHookScript = ./tiv_builder.sh;
  perlPreHook = ''
    source $perlPreHookScript
  '';
  installPhase = ''
    install -Dm755 tiv "$out/bin/tiv"
  '';
}
