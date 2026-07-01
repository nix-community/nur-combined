{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "md2";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "rapatao";
    repo = "md2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lwa12VsVftujGslY03tSNvkKuYpD7/UYd2Mnaaqph24=";
  };

  vendorHash = "sha256-6ZFEs7zWAVFTJ08UPEt3cAw8VRiEOjbtEEByI7E4UaU=";

  # PDF tests render via a browser (Chromium), which the sandbox has no access
  # to and cannot download. Skip the test suite in the build.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Convert markdown files to PDF, HTML, and text";
    homepage = "https://github.com/rapatao/md2";
    license = lib.licenses.mit;
    mainProgram = "md2";
  };
})
