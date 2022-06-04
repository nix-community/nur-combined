{ rustPlatforms, rustPlatformFor
, fetchFromGitHub
, Security ? darwin.Security, darwin
, lib, hostPlatform
}: with lib; let
  rustPlatform = if true
    then rustPlatformFor {
      # https://github.com/rust-lang/rustfmt/blob/${version}/rust-toolchain
      channel = "nightly";
      date = "2021-10-20";
      sha256 = "13qhkyix8hxqclba1pfhizf02p82h8gh7hdpnk8j20z8a1py2yyw";
      rustcDev = true;
    }
    else rustPlatforms.nightly;
in rustPlatform.buildRustPackage rec {
  pname = "rustfmt-nightly";
  version = "1.4.38";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rustfmt";
    rev = "v${version}";
    sha256 = "08j5b77sidg5fi7q2d50faii14xmbvp8nd7iicbphg6sw2szipxw";
  };

  dontUpdateAutotoolsGnuConfigScripts = true;
  cargoSha256 = "1v12jmrf2bpb5p53mfvdanqmzkif098yp9nahj6jcp2hma99jk0z";

  buildInputs = optional hostPlatform.isDarwin Security;

  doCheck = false;

  RUSTC_BOOTSTRAP = 1;
  CFG_RELEASE = rustPlatform.rust.rustc.version;
  CFG_RELEASE_CHANNEL = "nightly";
}
