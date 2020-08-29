{ lib
, fetchFromGitHub
, buildRustPackage
}:

buildRustPackage rec {
  pname = "cargo-sort-ck";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "DevinR528";
    repo = "cargo-sort-ck";
    rev = "v${version}";
    sha256 = "0l2wg0xr8ahprdcxnw7b1afml9z6arqfj9bn0fq9vfpnm14b3j80";
  };

  cargoSha256 = "05m7k5nmzxl6a93rjz320lqc74ljyh2jvrkh5g4c4gpj4966smpv";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Check if tables and items in a .toml file are lexically sorted";
    homepage = "https://github.com/devinr528/cargo-sort-ck";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
