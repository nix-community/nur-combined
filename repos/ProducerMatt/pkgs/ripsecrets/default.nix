{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "ripsecrets";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "sirwart";
    repo = "ripsecrets";
    rev = "v${version}";
    sha256 = "mPTDzBmVsLAO3iVTT5SxjUg+OSXBcbH+zbr9PIkUrhM=";
  };

  cargoSha256 = "nn0f+L1rxSoK/JLVHgTEPXoc0LM6WEmfdKbAizwAy40=";

  meta = with lib; {
    description = "A command-line tool to prevent committing secret keys into your source code";
    homepage = "https://github.com/sirwart/ripsecrets";
    license = licenses.mit;
    maintainers = with maintainers; [ ProducerMatt ];
  };
}
