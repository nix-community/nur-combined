{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "ht";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "ducaale";
    repo = "ht";
    rev = "v${version}";
    sha256 = "083m1wz8rs5mr1lgvj5rnygv7b5l7ik4m6h666qivm4hci1d4ynh";
  };

  cargoSha256 = "1h0i6zcbhjik6452x73pfz292yb1yclwxxf04gj76y6y4cas3d5p";

  doCheck = false;

  meta = with lib; {
    description = "Yet another HTTPie clone";
    homepage = src.meta.homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
