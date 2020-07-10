{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "prm-${version}";
  version = "3.4.0";
  rev = "v${version}";

  goPackagePath = "github.com/ldez/prm";

  buildFlagsArray = let t = "${goPackagePath}/meta"; in
    ''
      -ldflags=
         -X ${t}.Version=${version}
         -X ${t}.BuildDate=unknown
    '';

  src = fetchFromGitHub {
    inherit rev;
    owner = "ldez";
    repo = "prm";
    sha256 = "1vpii7046rq13ahjkbk7rmbqskk6x1mcsrzqx91nii7nzl32wdap";
  };
  vendorSha256 = "1lsi02d0vm0z308brbxpwaywwa6jlpynh332fsfs6w4da448vmx9";
  modSha256 = "${vendorSha256}";

  meta = {
    description = "Pull Request Manager for Maintainers";
    homepage = "https://github.com/ldez/prm";
    license = lib.licenses.asl20;
  };
}
