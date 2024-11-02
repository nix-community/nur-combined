{ stdenv
, fetchFromGitea
, rustPlatform
, openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "fast-check-urls";
  version = "0.2.0";

  src = fetchFromGitea {
    domain = "git.envs.net";
    owner = "binarycat";
    repo = "fast-check-urls";
    rev = version;
    hash = "sha256-kdyeWuyO1LlA/iwPG1ir/2+deOfjOzKqiHguoVr0y3s=";
  };

  cargoHash = "sha256-uQ5fzFvOfiI1lyOuPEn1SiZhOQ20BTLkJJjw7Awjv8U=";

  buildInputs = [ openssl openssl.dev ];

  env = {
    OPENSSL_DIR = openssl.dev.outPath;
    OPENSSL_LIB_DIR = openssl.out.outPath + "/lib";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  # no tests
  doCheck = false;

  buildPhase = "make $makeFlags build";
  installPhase = "make $makeFlags install";
}
