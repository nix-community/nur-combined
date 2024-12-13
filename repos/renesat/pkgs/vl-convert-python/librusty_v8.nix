{
  stdenv,
  fetchurl,
}: let
  fetch_librusty_v8 = args:
    fetchurl {
      name = "librusty_v8-${args.version}";
      url = "https://github.com/denoland/rusty_v8/releases/download/v${args.version}/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
      sha256 = args.shas.${stdenv.hostPlatform.system};
      meta = {inherit (args) version;};
    };
in
  fetch_librusty_v8 {
    version = "0.105.1";
    shas = {
      x86_64-linux = "sha256-f7aDA74Jn2h4rp9sACGHX4DBbN6yevgWCEKdfI1fJDU=";
      aarch64-linux = "";
      x86_64-darwin = "";
      aarch64-darwin = "";
    };
  }
