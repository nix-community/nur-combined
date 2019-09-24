{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "wtplan";
  version = "2019-05-09";

  src = fetchFromGitHub {
    owner = "kjellwinblad";
    repo = pname;
    rev = "71ca956dfb5c55960eb16471ffd795b0f2cf718c";
    sha256 = "0hmi3i2nrxbz2db3zfvh2f4lfkn7rmyq7z84fl2xggv3h5zhnc9k";
  };

  preBuild = ''
    go generate ${goPackagePath}/src/wtplan
    go generate ${goPackagePath}/src/wtplan-web
  '';

  goPackagePath = "github.com/kjellwinblad/wtplan";
}
