{
  lib,
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.13";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-N0Ov1YVNpsCdt2G9cS6jHs52gCvbZ4+CL3kFRuKfYts=";
  };

  postPatch = ''
    grep -Fxq '// AAA Certificate Services' common/certificate/mozilla.go
    grep -Fq '// CN=emSign ECC Root CA - G3;' common/certificate/chrome.go

    sed -i -E \
      '/^\/\/ (CN=)?(AAA Certificate Services|emSign ECC Root CA - G3)(;|$)/,/^-----END CERTIFICATE-----$/d' \
      common/certificate/{mozilla,chrome}.go
  '';

  vendorHash = "sha256-3SyWbFw727nZRCaECDl+Bu1w1yhYB+fzUxvCKw2om6w=";

  postInstall =
    lib.replaceString
      "install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules"
      ""
      previousAttrs.postInstall;
})
