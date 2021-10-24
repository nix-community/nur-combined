{ lib
, fetchFromGitLab
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "conduit";
  version = "0.2.0";

  src = fetchFromGitLab {
    owner = "famedly";
    repo = "conduit";
    rev = "v${version}";
    sha256 = "09c824392p2q6ir2ar0wfrbp8y2pfn0kwxhwi3ab5s03bs8bps7j";
  };

  cargoSha256 = "03pfd8cgrvjrq2grvsmn5ir42my2z6rx7gp5jdkqzv7q6ld1rnng";

  meta = with lib; {
    description = "A Matrix homeserver written in Rust";
    homepage = "https://conduit.rs";
    license = licenses.asl20;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
