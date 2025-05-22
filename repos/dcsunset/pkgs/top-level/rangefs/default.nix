{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rangefs";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-p/A3lDpNVGctofuJq0vA4XaT+kk5F8aW/kx/I4IgVaE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-GJiiW74JJ4UHDmp8BO+6f4AzhwCNTLgi10VniD8qAjQ=";

  nativeBuildInputs = [
    makeWrapper
  ];

  # reference: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/filesystems/gocryptfs/default.nix
  postInstall = ''
    wrapProgram $out/bin/rangefs \
      --suffix PATH : ${lib.makeBinPath [ fuse3 ]} \
      --add-flags "--foreground" \
    ln -s $out/bin/rangefs $out/bin/mount.fuse.rangefs
  '';

  meta = with lib; {
    description = "A fuse-based filesystem to map ranges in file to individual files.";
    homepage = "https://github.com/DCsunset/rangefs";
    license = licenses.agpl3Only;
  };
}
