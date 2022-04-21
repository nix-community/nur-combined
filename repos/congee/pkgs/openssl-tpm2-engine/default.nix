{ stdenv
, lib
, fetchgit
, autoreconfHook
, openssl
, pkg-config
, tpm2-tss
, help2man
, ...
}:

stdenv.mkDerivation rec {
  pname = "openssl-tpm2-engine";
  version = "3.1.1";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/jejb/openssl_tpm2_engine.git";
    rev = "6b9c5718b913900195354edc927b5c2783ff829b";
    sha256 = "sha256-VVAFYKDZXRgz+itEDp7spGiXRTasEckls2wMwBmuMt8=";
  };

  buildInputs = [ pkg-config autoreconfHook help2man ];
  nativeBuildInputs = [ openssl tpm2-tss ];
  # By default libtpm2.so is installed to /nix/store/xxx-openssl-1.1.1n/lib/engines-1.1
  preConfigure = ''
    configureFlagsArray+=("--with-enginesdir=$out/lib/engines")
  '';

  postInstall = ''
    $STRIP -s $out/lib/engines/*.so
  '';

  installCheckPhase = ''
    OPENSSL_ENGINES=$out/lib/engines openssl engine tpm2
  '';
  # Fails to find the symbol EVP_PKEY_get_base_id from tpm2.so
  doInstallCheck = false;

  meta = with lib; {
    description = "A command-line utility used to generate a TSS key blob and write it to disk and an OpenSSL engine which interfaces with the TSS API.";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/jejb/openssl_tpm2_engine.git/about/";
    licenses = licenses.lgpl21Only;
    maintainers = with maintainers; [ congee ];
  };
}
