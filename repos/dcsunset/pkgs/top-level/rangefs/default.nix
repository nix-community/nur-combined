{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "rangefs";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-WyUvmOmQzcZaTJcOYjPOm8EfKRSLABpvE0qlefUxA0c=";
  };

  cargoHash = "sha256-+8nSXo1si29Rc8DHiqztMyW5Ih9ixr5mv6Z0QMcgr/o=";

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
