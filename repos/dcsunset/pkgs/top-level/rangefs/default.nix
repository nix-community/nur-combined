{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rangefs";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-g1koNgO1OMk8Y2mcz8GKAvP1FUMxVE5FeW/pGevmD0U=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-0oEBOrsXYXJpElYQQcqxpSazMq3QBL0G/KpIuLGkl90=";

  nativeBuildInputs = [
    makeWrapper
  ];

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
