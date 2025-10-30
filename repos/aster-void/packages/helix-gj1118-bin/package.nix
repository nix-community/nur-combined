{
  stdenv,
  fetchzip,
  autoPatchelfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "helix-gj1118";
  version = "25.10.20";
  src = fetchzip {
    url = "https://github.com/gj1118/helix/releases/download/${finalAttrs.version}/helix-linux-x86_64.tar.gz";
    hash = "sha256-axiMhC3F/CB7RGMIqkGANeJbwVj5+Q92Iy0OfcJOjfY=";
    stripRoot = false;
  };
  buildInputs = [
    stdenv.cc.cc.lib
  ];
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    mkdir -p $out $out/bin $out/lib
    mv ./hx $out/bin
    mv ./runtime $out/lib
  '';
  meta = {
    description = "Helix's fork managed by gj1118";
    homepage = "https://github.com/gj1118/helix";
    mainProgram = "hx";
  };
})
