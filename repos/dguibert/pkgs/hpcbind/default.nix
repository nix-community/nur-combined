{
  stdenv,
  fetchFromGitHub,
  lib,
  hwloc,
  makeWrapper,
  nvidia ? null,
}:
stdenv.mkDerivation {
  name = "hpcbind-20180406";
  src = fetchFromGitHub {
    owner = "kokkos";
    repo = "hpcbind";
    rev = "641c8ac";
    sha256 = "sha256:1lxs9v7p2inbnxkq20jf2mci8mx0l0wr5bnvhmidb4il4ifx4g49";
  };
  buildInputs = [makeWrapper];
  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp hpcbind $out/bin/

    wrapProgram $out/bin/hpcbind --prefix PATH : ${lib.makeBinPath [hwloc nvidia]}
  '';
}
