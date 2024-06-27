{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "transformfs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "transformfs";
    rev = "refs/tags/v${version}";
    hash = "sha256-3pl0ZSwWtEETx1dSzqty3Sr+VKwDHLcfjmDDSWZJ27c=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];
  cargoHash = "sha256-OooLQUfATdrfANy1SnlDgN1vw3Z5QDvjcRfhDwijKXE=";

  # reference: https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/filesystems/gocryptfs/default.nix
  postInstall = ''
    wrapProgram $out/bin/transformfs \
      --suffix PATH : ${lib.makeBinPath [ fuse3 ]}
    ln -s $out/bin/transformfs $out/bin/mount.fuse.transformfs
  '';

  meta = with lib; {
    description = "A read-only FUSE filesystem to transform the content of files with Lua";
    homepage = "https://github.com/DCsunset/transformfs";
    license = licenses.agpl3Only;
  };
}
