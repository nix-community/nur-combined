{
  lib,
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.14";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-sPeg7S7OUFwQxY6cU74TjpwQTBhkQ2itteXi7WfmfAs=";
  };

  postPatch = ''
    grep -Fxq '// AAA Certificate Services' common/certificate/mozilla.go
    grep -Fq '// CN=emSign ECC Root CA - G3;' common/certificate/chrome.go

    sed -i -E \
      '/^\/\/ (CN=)?(AAA Certificate Services|emSign ECC Root CA - G3)(;|$)/,/^-----END CERTIFICATE-----$/d' \
      common/certificate/{mozilla,chrome}.go
  '';

  vendorHash = "sha256-q9We+hnPZ/GqAYNXsJJrOlous0XIMCyCIfqQMVnluLo=";

  postInstall =
    lib.replaceString
      "install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules"
      ""
      previousAttrs.postInstall;
})
