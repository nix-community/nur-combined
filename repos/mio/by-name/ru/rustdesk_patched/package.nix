{
  stdenv,
  fetchurl,
  rustdesk,
  libsciter,
}:

let
  sciterSrc = {
    x86_64-linux = {
      urlPath = "x64";
      hash = "sha256-oWgvv1XgBPGGLWrOMbUiASHSCQa9vzCNCpI3tFHk24Y=";
    };
    aarch64-linux = {
      urlPath = "arm64";
      hash = "sha256-bqGPbvtOM8/A6acDbFJGGf4kzKo/4S/bWcH/XvxVySU=";
    };
  };
  libsciterPatched = libsciter.overrideAttrs (oldAttrs: {
    src = fetchurl {
      url = "https://raw.githubusercontent.com/c-smile/sciter-sdk/524a90ef7eab16575df9496f7e4c374bbd5fb1fe/bin.lnx/${sciterSrc.${stdenv.targetPlatform.system}.urlPath}/libsciter-gtk.so";
      inherit (sciterSrc.${stdenv.targetPlatform.system}) hash;
    };
  });
in
(rustdesk.override {
  libsciter = libsciterPatched;
}).overrideAttrs (oldAttrs: {
  dontCargoUseSystemLibs = true;
})
