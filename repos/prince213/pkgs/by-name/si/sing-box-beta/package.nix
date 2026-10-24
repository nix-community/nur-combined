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

  vendorHash = "sha256-3SyWbFw727nZRCaECDl+Bu1w1yhYB+fzUxvCKw2om6w=";

  postInstall =
    lib.replaceString
      "install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules"
      ""
      previousAttrs.postInstall;
})
