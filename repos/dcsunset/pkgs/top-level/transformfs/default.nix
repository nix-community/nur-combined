{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "transformfs";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "transformfs";
    rev = "refs/tags/v${version}";
    hash = "sha256-lT6cZ5yLNOZNTnbzUeNthngG2bHa73e2tE5kl1CoR88=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-tCACy2mjNZsSBAmXWKRrS7WMvcFO4wxHO6AU9MBKrUs=";

  nativeBuildInputs = [
    makeWrapper
  ];

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
