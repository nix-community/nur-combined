{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc,
}:

let
  version = "2.2.0";

  targetBySystem = {
    "x86_64-linux" = "sha256-UKq5/G6IBR5fAur9cbMSfOesUHDXAXV2ScMnipXkhdo=";
    "aarch64-linux" = "sha256-VUNeUhypt9L6uve4XEOmDBNqjwg617e0qTzkdAPTbvM=";
    "x86_64-darwin" = "sha256-JC0AhGLQhapj3r4K3Ny36GfyWQGgYFx0AI1A3LvVH7o=";
    "aarch64-darwin" = "sha256-VkDDqAypDhQYAJrswtSQ7hNZ0tzW3w8ZogIqzktsAEc=";
  };

  sha256BySystem = {
    "x86_64-linux" = "sha256-r/tZRnLC8iDO9o+nz+uBOUXEAQeJpLjMLA5GRo/reHA=";
    "aarch64-linux" = "sha256-bDr90Rx8D7kAU9S1OyclK1w1u3XGeTgyNL7yCiVVjqw=";
    "x86_64-darwin" = "sha256-cp5nFmxQlMiVFQtnLNOkRh+omYl+HyTbzQfBO7O0jBM=";
    "aarch64-darwin" = "sha256-Eh/h7ubZCyLnbk6Yy7YkR07s2XCkpMYi/U1QiJtX2sw=";
  };

  target =
    targetBySystem.${stdenv.hostPlatform.system}
      or (throw "linear-cli: unsupported system ${stdenv.hostPlatform.system}");

  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "linear-cli: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "linear-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-${target}.tar.xz";
    sha256 = srcHash;
  };

  sourceRoot = "linear-${target}";
  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gcc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    install -Dm755 linear "$out/bin/linear"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Linear CLI for listing, starting, and creating Linear issues";
    homepage = "https://github.com/schpet/linear-cli";
    license = licenses.isc;
    platforms = builtins.attrNames targetBySystem;
    mainProgram = "linear";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
