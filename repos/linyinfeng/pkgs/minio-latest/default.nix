# TODO wait for https://github.com/NixOS/nixpkgs/issues/199318
# taken from nixpkgs pkgs/servers/minio/default.nix
{
  lib,
  go,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

let
  # The web client verifies, that the server version is a valid datetime string:
  # https://github.com/minio/minio/blob/3a0e7347cad25c60b2e51ff3194588b34d9e424c/browser/app/js/web.js#L51-L53
  #
  # Example:
  #   versionToTimestamp "2021-04-22T15-44-28Z"
  #   => "2021-04-22T15:44:28Z"
  versionToTimestamp =
    version:
    let
      splitTS = builtins.elemAt (builtins.split "(.*)(T.*)" version) 1;
    in
    builtins.concatStringsSep "" [
      (builtins.elemAt splitTS 0)
      (builtins.replaceStrings [ "-" ] [ ":" ] (builtins.elemAt splitTS 1))
    ];
in
buildGoModule rec {
  pname = "minio-latest";
  version = "2024-11-07T00-52-20Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.${version}";
    sha256 = "sha256-vWrNqfB41Y3MAF9PuyopIDrGq4Bj41Y4gISbN6nO0zU=";
  };

  vendorHash = "sha256-yYAEh4L1eStx0/bID0+wZ5kdqPYshJrSZgVGuXgtgvs=";

  doCheck = false;

  subPackages = [ "." ];

  CGO_ENABLED = 0;

  tags = [ "kqueue" ];

  ldflags =
    let
      t = "github.com/minio/minio/cmd";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=${versionToTimestamp version}"
      "-X ${t}.ReleaseTag=RELEASE.${version}"
      "-X ${t}.CommitID=${src.rev}"
    ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; } ++ [
      "--version-regex"
      "RELEASE\\.(.*)"
    ];
  };

  meta = with lib; {
    homepage = "https://www.minio.io/";
    description = "An S3-compatible object storage server";
    changelog = "https://github.com/minio/minio/releases/tag/RELEASE.${version}";
    platforms = platforms.unix;
    license = licenses.agpl3Plus;
    broken = !(lib.versionAtLeast go.version "1.22");
    maintainers = with maintainers; [ yinfeng ];
  };
}
