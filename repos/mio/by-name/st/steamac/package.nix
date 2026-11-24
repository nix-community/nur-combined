{
  lib,
  fetchFromGitHub,
  fetchurl,
  applyPatches,
  callPackage,
}:

let
  version = "1.9.15";
  src = fetchFromGitHub {
    owner = "fxgl";
    repo = "steamac";
    rev = "v${version}";
    hash = "sha256-XO/1Z5fzUcSklh+gbGP0uBSzUzfAUmW1BMpMTxGJYKI=";
  };

  libepoxy = callPackage ./libepoxy.nix { };

  moltenvkSrc = fetchFromGitHub {
    owner = "utmapp";
    repo = "MoltenVK";
    rev = "05604465d691118cfd20f53a48ecf1aad9c12f93";
    hash = "sha256-fVIJ7kihxxmQ8eEiIEHsAFUe/JiEQ4p4xkxYw2WuJMU=";
  };

  spirvCross = applyPatches {
    name = "SPIRV-Cross-steamac";
    src = fetchFromGitHub {
      owner = "utmapp";
      repo = "SPIRV-Cross";
      rev = "939b40b33a44443c404c4078823c406e3c94866f";
      hash = "sha256-YeiKovpy41nXCn0jbMbTi0Y/3VxUitFrDaHfyxGsQEU=";
    };
    patches = lib.sort (a: b: a < b) (
      builtins.filter (p: lib.hasSuffix ".patch" p) (
        lib.filesystem.listFilesRecursive "${src}/host/moltenvk/patches/spirv-cross"
      )
    );
  };

  moltenvkExternal =
    repo: rev: hash:
    fetchFromGitHub {
      owner = "KhronosGroup";
      inherit repo rev hash;
    };

  moltenvkDeps = callPackage ./moltenvk-deps.nix {
    inherit moltenvkSrc spirvCross;
    spirvTools =
      moltenvkExternal "SPIRV-Tools" "262bdab48146c937467f826699a40da0fdfc0f1a"
        "sha256-H+t7ZH4SB+XgWTLj9XaJWZwAWk8M2QeC98Zi5ay8PBc=";
    spirvHeaders =
      moltenvkExternal "SPIRV-Headers" "b824a462d4256d720bebb40e78b9eb8f78bbb305"
        "sha256-HjJjMuqTrYv5LUOWcexzPHb8nhOT4duooDAhDsd44Zo=";
    vulkanHeaders =
      moltenvkExternal "Vulkan-Headers" "6aefb8eb95c8e170d0805fd0f2d02832ec1e099a"
        "sha256-yuINyOugmlb4o6akLAMU9t3R2ArK9ddbuUZPyKOl56s=";
    vulkanTools =
      moltenvkExternal "Vulkan-Tools" "013058f74e2356347f8d9317233bc769816c9dfb"
        "sha256-2CCFO3VMhBWKyoWaz7dLfOE+MKBFqaajiAMSYwTvnDI=";
    volk = fetchFromGitHub {
      owner = "zeux";
      repo = "volk";
      rev = "59660878571aa99e3c9a366bb1d19fdcd701f0e7";
      hash = "sha256-W3PKNtk4L17VkjC7M/bNuq16OZjIAA5MFmX3u26+HZc=";
    };
    cereal = fetchFromGitHub {
      owner = "USCiLab";
      repo = "cereal";
      rev = "a56bad8bbb770ee266e930c95d37fff2a5be7fea";
      hash = "sha256-Q2/W74G5DYvgjPpzPRDWcWdqmEVyaY9wZaoMlfvfOnM=";
    };
  };

  moltenvk = callPackage ./moltenvk.nix {
    steamacSrc = src;
    inherit moltenvkSrc moltenvkDeps;
  };

  virglrendererSrc = callPackage ./virglrenderer-src.nix { steamacSrc = src; };

  virglrenderer = callPackage ./virglrenderer.nix {
    inherit virglrendererSrc libepoxy;
    # The venus-protocol.wrap pins v1.1.3.
    venusProtocol = fetchurl {
      url = "https://gitlab.freedesktop.org/virgl/venus-protocol/-/archive/ca19b6358d7cc491bc3e4de76f04c6700876a8fa/venus-protocol-ca19b6358d7cc491bc3e4de76f04c6700876a8fa.tar.gz";
      hash = "sha256-7OKYz6SahpxhrZf/Mngl+KXpX9oVBoZIxQoO496qd6s=";
    };
  };

  libkrunVersion = "1.19.6";

  libkrunSrc = fetchFromGitHub {
    owner = "libkrun";
    repo = "libkrun";
    rev = "v${libkrunVersion}";
    hash = "sha256-h37J1J/oe4PpY5Xtv8Js/wEA7av9M/VK4OTY1svK++0=";
  };

  libkrunSysroot = callPackage ./libkrun-sysroot.nix { inherit libkrunSrc; };

  libkrun = callPackage ./libkrun.nix {
    steamacSrc = src;
    inherit
      libkrunVersion
      libkrunSrc
      libkrunSysroot
      libepoxy
      virglrenderer
      ;
  };

  launchGvproxy = callPackage ./gvproxy.nix { };
  launchDesync = callPackage ./desync.nix { };

  # The signed release supplies the Linux guest images (see guest-images.nix).
  releaseDmg = fetchurl {
    url = "https://github.com/fxgl/steamac/releases/download/v${version}/FX-Steam-Launcher-${version}.dmg";
    hash = "sha256-yWJm5ETsGHCXTmijarChnO/7GfFnQM9Xc1sQkEjnY2M=";
  };

  guestImages = callPackage ./guest-images.nix { inherit version releaseDmg; };

  launcherSources = callPackage ./launcher-sources.nix { };

  swiftpmDeps = callPackage ./swiftpm-deps.nix { steamacSrc = src; };

in
callPackage ./launcher.nix {
  steamacSrc = src;
  inherit
    version
    launcherSources
    swiftpmDeps
    libepoxy
    virglrenderer
    moltenvk
    libkrun
    guestImages
    ;
  gvproxy = launchGvproxy;
  desync = launchDesync;
}
