{ lib, fuse3, makeWrapper, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "transformfs";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = "transformfs";
    rev = "refs/tags/v${version}";
    hash = "sha256-xdH/QvNvlsauV6rlkbCzWggohw9hdMcaEU3sGrYCGh0=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];
  cargoHash = "sha256-vhi89MAkj/AVRjTlQ2NnoNhc9cJRNa/N1znDcopOsiQ=";

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
