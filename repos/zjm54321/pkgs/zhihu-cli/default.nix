{
  autoPatchelfHook,
  fetchurl,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "zhihu-cli";
  version = "0.3.0";

  src = fetchurl {
    url = "https://developer-cdn.zhihu.com/zhihu-cli/releases/stable/cli/${finalAttrs.version}/zhihu-cli-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-1+iaLV3yCrNn2UTCofdpS2JycFwY68jXOIEpp5M+DoA=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -d "$out/bin"
    tar -xOzf "$src" zhihu-cli > "$out/bin/zhihu-cli"
    chmod +x "$out/bin/zhihu-cli"
  '';

  meta = {
    description = "Zhihu command-line interface";
    homepage = "https://www.zhihu.com";
    mainProgram = "zhihu-cli";
    platforms = [ "x86_64-linux" ];
  };
})
