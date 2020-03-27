{ lib, buildGoPackage, fetchFromGitHub}:

buildGoPackage rec {
  pname = "flarectl";
  version = "v0.11.5";
  goPackagePath = "github.com/cloudflare/cloudflare-go";

  subPackages = [ "cmd/flarectl" ];

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cloudflare-go";
    rev = version;
    sha256 = "1la9am3mhfs3y8xk0r8ja19wxb7asidz284srr0f2yg2pw60l0a1";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "A CLI application for interacting with a Cloudflare account. Powered by [cloudflare-go].";
    license = licenses.bsd3;
    homepage = "cloudflare.com";
    maintainers = [ "trevor@trevorriles.com" ];
  };
}
