{
  lib,
  buildGoModule,
  fetchFromGitHub,
  openssl,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "age-plugin-tpm";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Foxboron";
    repo = "age-plugin-tpm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yr1PSSmcUoOrQ8VMQEoaCLNvDO+3+6N7XXdNUyYVz9M=";
  };

  proxyVendor = true;

  vendorHash = "sha256-VEx6qP02QcwETOQUkMsrqVb+cOElceXcTDaUr480ngs=";

  buildInputs = [
    openssl
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru.tests = {
    help =
      runCommand "test-age-plugin-tpm-old-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          age-plugin-tpm --help
          touch $out
        '';
  };

  meta = {
    description = "TPM 2.0 plugin for age";
    homepage = "https://github.com/Foxboron/age-plugin-tpm";
    license = lib.licenses.mit;
    mainProgram = "age-plugin-tpm";
    platforms = lib.platforms.all;
  };
})
