# TODO wait for https://github.com/NixOS/nixpkgs/issues/199318
# taken from nixpkgs pkgs/servers/minio/default.nix
{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

let
  # The web client verifies, that the server version is a valid datetime string:
  # https://github.com/minio/minio/blob/3a0e7347cad25c60b2e51ff3194588b34d9e424c/browser/app/js/web.js#L51-L53
  #
  # Example:
  #   versionToTimestamp "2021-04-22T15-44-28Z"
  #   => "2021-04-22T15:44:28Z"
  versionToTimestamp = version:
    let
      splitTS = builtins.elemAt (builtins.split "(.*)(T.*)" version) 1;
    in
    builtins.concatStringsSep "" [ (builtins.elemAt splitTS 0) (builtins.replaceStrings [ "-" ] [ ":" ] (builtins.elemAt splitTS 1)) ];
in
buildGoModule rec {
  pname = "minio-latest";
  version = "2024-02-12T21-02-27Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.${version}";
    sha256 = "sha256-FlVvMkl0c4dbfxIoIWr1mQo2rhZGakBu8uWgPyGsqS0=";
  };

  vendorHash = "sha256-wCZrb6x9hqOBsfK6HYW8Z5xD5xq2oip1V9R2OiiKcEk=";

  doCheck = false;

  subPackages = [ "." ];

  CGO_ENABLED = 0;

  tags = [ "kqueue" ];

  ldflags = let t = "github.com/minio/minio/cmd"; in
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
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "22.11");
    maintainers = with maintainers; [ yinfeng ];
  };
}
