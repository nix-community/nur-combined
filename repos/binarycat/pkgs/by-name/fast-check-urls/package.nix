{ stdenv
, fetchFromGitea
, rustPlatform
, openssl
}:
rustPlatform.buildRustPackage {
  pname = "fast-check-urls";
  version = "0.1.0-unstable-2024-03-20";

  src = fetchFromGitea {
    domain = "git.envs.net";
    owner = "binarycat";
    repo = "fast-check-urls";
    rev = "560ff20";
    hash = "sha256-aAommw8koj0FaHfanAmM4/E++Qs+8ZUw20dSfUm7+98="; #"sha256-QD+M5DD89ITX7UnAyt9Ayr/SQhdsBokW+AP8D33l+1w=";
  };

  cargoHash = "sha256-mwvgR0Q8/Bw5qSPShFXz+7WL+cZ27kgnr3E19bGi2e8="; #"sha256-mwvgR0Q8/Bw5qSPShFXz+7WL+cZ27kgnr3E19bGi2e8=";

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
