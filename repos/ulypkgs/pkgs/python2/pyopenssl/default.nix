{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  openssl,
  cryptography,
  pyasn1,
  idna,
  pytestCheckHook,
  pretend,
  flaky,
  glibcLocales,
  six,
}:

let
  # https://github.com/pyca/pyopenssl/issues/791
  # These tests, we disable in the case that libressl is passed in as openssl.
  failingLibresslTests = [
    "test_op_no_compression"
    "test_npn_advertise_error"
    "test_npn_select_error"
    "test_npn_client_fail"
    "test_npn_success"
    "test_use_certificate_chain_file_unicode"
    "test_use_certificate_chain_file_bytes"
    "test_add_extra_chain_cert"
    "test_set_session_id_fail"
    "test_verify_with_revoked"
    "test_set_notAfter"
    "test_set_notBefore"
  ];

  # these tests are extremely tightly wed to the exact output of the openssl cli tool,
  # including exact punctuation.
  failingOpenSSL_1_1Tests = [
    "test_dump_certificate"
    "test_dump_privatekey_text"
    "test_dump_certificate_request"
    "test_export_text"
  ];

in

buildPythonPackage rec {
  pname = "pyopenssl";
  version = "20.0.1";

  src = fetchPypi {
    pname = "pyOpenSSL";
    inherit version;
    sha256 = "4c231c759543ba02560fcd2480c48dcec4dae34c9da7d3747c508227e0624b51";
  };

  outputs = [
    "out"
    "dev"
  ];

  env.LANG = "en_US.UTF-8";

  # Seems to fail unpredictably on Darwin. See https://hydra.nixos.org/build/49877419/nixlog/1
  # for one example, but I've also seen ContextTests.test_set_verify_callback_exception fail.
  doCheck = !stdenv.isDarwin;

  nativeBuildInputs = [
    openssl
    pytestCheckHook
  ];
  propagatedBuildInputs = [
    cryptography
    pyasn1
    idna
    six
  ];

  disabledTests = [
    # https://github.com/pyca/pyopenssl/issues/692
    # These tests, we disable always.
    "test_set_default_verify_paths"
    "test_fallback_default_verify_paths"
    # https://github.com/pyca/pyopenssl/issues/768
    "test_wantWriteError"
  ]
  ++ (lib.optionals (lib.hasPrefix "libressl" openssl.meta.name) failingLibresslTests)
  ++ (lib.optionals (lib.versionAtLeast (lib.getVersion openssl.name) "1.1") failingOpenSSL_1_1Tests)
  ++ (
    # https://github.com/pyca/pyopenssl/issues/974
    lib.optionals stdenv.is32bit [ "test_verify_with_time" ]
  );

  checkInputs = [
    pretend
    flaky
    glibcLocales
  ];
}
