{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "linuxkit-${version}";
  version = "v0.6";
  rev = "10f07ca1624102de3c2d93da7792be5528c32022";

  goPackagePath = "github.com/linuxkit/linuxkit";

  src = fetchFromGitHub {
    owner = "linuxkit";
    repo = "linuxkit";
    inherit rev;
    sha256 = "12nph1sxgp7l2sb3ar7x8a2rrk2bqphca6snwbcqaqln2ixsh78i";
  };

  subPackages = [ "src/cmd/linuxkit" ];

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-X main.GitCommit=${builtins.substring 0 7 rev} -X main.Version=0.6.0")
  '';

  meta = {
    description = "A toolkit for building secure, portable and lean operating systems for containers";
    license = lib.licenses.asl20;
    homepage = https://github.com/linuxkit/linuxkit;
    platforms = lib.platforms.unix;
  };
}
