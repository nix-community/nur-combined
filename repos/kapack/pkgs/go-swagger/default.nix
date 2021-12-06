{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "go-swagger";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "go-swagger";
    repo = "go-swagger";
    rev = "v${version}";
    sha256 = "0cr8aa772w4yvnc4j8p6261izsj4isrhnzryy7x86f41g7zv5zwx";
  };

  goPackagePath = "github.com/go-swagger/go-swagger";

  subPackages = [ "cmd/swagger" ];

  goDeps = ./deps.nix;
  
  ldflags = ''
    -X github.com/go-swagger/go-swagger/cmd/swagger/commands/version.Version=${version}
  '';

  meta = with lib; {
    homepage = "https://goswagger.io";
    description = "Swagger 2.0 implementation for go";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    platforms = platforms.unix;
  };
}
