{pkgs, ...}:
let
  version = "0.2.2";
  srcs = builtins.mapAttrs (k: v: pkgs.fetchzip v) {
    "x86_64-linux" = {
      url = "https://cli.pipedream.com/linux/amd64/${version}/pd.zip";
      sha256 = "sha256-8sxDm27NhNQSKvbaZnT3zGIYE9yUZoVtc3OlCmwugiQ=";
    };
    "aarch64-linux" = {
      url = "https://cli.pipedream.com/linux/arm64/${version}/pd.zip";
      sha256 = "sha256-wugMuEr+I7rmik1wd4ewR36gGUATvp9V5jpK+bttqrc=";
    };
  };
in pkgs.stdenvNoCC.mkDerivation rec {
  pname = "pipedream-cli";
  inherit version;
  src = srcs."${pkgs.stdenv.system}";

  dontBuild = true;
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src/pd $out/bin/pd
  '';
} // { inherit srcs; }
