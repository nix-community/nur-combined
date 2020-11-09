{ stdenv, fetchurl, fetchFromGitHub, zig }:

## Build
# stdenv.mkDerivation {
#   pname = "gurl";
#   version = "0.1";

#   src = fetchFromGitHub {
#     owner = "MasterQ32";
#     repo = "gurl";
#     rev = "v0.1";
#     sha256 = "1prg7ywsd78h486lfcqhzxmnx2wai7rr3qzxldw9ggjv1mjf5laq";
#     fetchSubmodules = true;
#   };

#   nativeBuildInputs = [ zig ];

#   buildPhase = ''
#     export XDG_CACHE_HOME=$(mktemp -d)
#     zig build
#     rm -rf $XDG_CACHE_HOME
#   '';

#   installPhase = ''
#     mkdir -p $out/bin
#     cp zig-cache/bin/gurl $out/bin
#   '';
# }

## Prebuilt
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  version = "0.1";

  prebuilts = let
    base = "https://github.com/MasterQ32/gurl/releases/download";
  in
  {
    x86_64-linux = {
      url = "${base}/v${version}/gurl-x86_64-linux";
      sha256 = "0yz3w5mqgl1spszndpbrmy6jvxpfx2n3qlmv4v8f5mp1my6kgysy";
    };
    aarch64-linux = {
      url = "${base}/v${version}/gurl-aarch64-linux";
      sha256 = "0rwscrnzl29rmg2xpzabv0ww9rc4xsj12ddiw2rn005wag9an1ci";
    };
  };

  source = prebuilts.${system} or throwSystem;
  bin = fetchurl source;

in
  stdenv.mkDerivation {
    inherit version;
    pname = "gurl";
    unpackPhase = "true";

    installPhase = ''
      mkdir -p $out/bin
      cp ${bin} $out/bin/gurl
      chmod +x $out/bin/gurl
    '';

  }
