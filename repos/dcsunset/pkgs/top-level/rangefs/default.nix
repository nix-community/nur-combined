{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rangefs";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BSkU103k91S2EPkbfQzB88xxWepSPBRDTKPUds0M6YM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];
  cargoHash = "sha256-AWZcposd3n4+qGD7quEnNpQxnxW12jX2O1yCf09y2Ig=";

  # reference: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/filesystems/gocryptfs/default.nix
  postInstall = ''
    wrapProgram $out/bin/rangefs \
      --suffix PATH : ${lib.makeBinPath [ fuse3 ]}
    ln -s $out/bin/rangefs $out/bin/mount.fuse.rangefs
  '';

  meta = with lib; {
    description = "A fuse-based filesystem to map ranges in file to individual files.";
    homepage = "https://github.com/DCsunset/rangefs";
    license = licenses.agpl3Only;
  };
}
