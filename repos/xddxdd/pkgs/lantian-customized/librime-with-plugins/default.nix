{
  fetchFromGitHub,
  lib,
  librime,
  librime-lua,
  librime-octagram,
}:
let
  librimeCharcodeSrc = fetchFromGitHub {
    owner = "rime";
    repo = "librime-charcode";
    rev = "55e7f563e999802d41a13ba02657c1be4b2011b4";
    hash = "sha256-KfKkpph+2ChQpkkGKubmpg/18uPX9qUHTqJT1PSGorI=";
  };
  librimeProtoSrc = fetchFromGitHub {
    owner = "lotem";
    repo = "librime-proto";
    rev = "657a923cd4c333e681dc943e6894e6f6d42d25b4";
    hash = "sha256-HdypebfmzreSdEQBwbvRG6sJZPASP+e8Tew+GrMnpOQ=";
  };
in
(librime.override {
  plugins = [
    librime-lua
    librime-octagram
    (librimeCharcodeSrc.overrideAttrs (_old: {
      name = "librime-charcode";
    }))
    (librimeProtoSrc.overrideAttrs (_old: {
      name = "librime-proto";
    }))
  ];
}).overrideAttrs
  (old: {
    passthru.updateScript = [ (toString ./update.sh) ];
    meta = old.meta // {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Librime with plugins (librime-charcode, librime-lua, librime-octagram, librime-proto)";
      mainProgram = "rime_deployer";
    };
  })
