{ lib
, fetchFromGitHub
, buildRustPackage
}:

buildRustPackage rec {
  pname = "csview";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "wfxr";
    repo = "csview";
    rev = "v${version}";
    sha256 = "18bz12yn85h9vj0b18iaziix9km2iwh8gwfs93fddjv6kg87p38q";
  };

  cargoSha256 = "1my6gl8zq5k7clzapgbf1mmcgq8mmdbhl250rdd1fvfd59wkrwra";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "High performance csv viewer with cjk/emoji support";
    homepage = "https://github.com/wfxr/csview";
    license = licenses.asl20;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
