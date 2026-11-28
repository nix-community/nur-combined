{
  lib,
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.15";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-NIFdRi2ft7GhgGqxb0+VmKT8eDYadf6Vr3UZCgSe2d0=";
  };

  postPatch = ''
    grep -Fxq '// AAA Certificate Services' common/certificate/mozilla.go
    grep -Fq '// CN=emSign ECC Root CA - G3;' common/certificate/chrome.go

    sed -i -E \
      '/^\/\/ (CN=)?(AAA Certificate Services|emSign ECC Root CA - G3)(;|$)/,/^-----END CERTIFICATE-----$/d' \
      common/certificate/{mozilla,chrome}.go
  '';

  vendorHash = "sha256-+P3JDy8KrFnPnwhhdNaP9m3LWMJT/EPknrzwpDsGeZQ=";

  postInstall =
    lib.replaceString
      "install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules"
      ""
      previousAttrs.postInstall;
})
