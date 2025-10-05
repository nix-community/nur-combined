{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "Amethyst";
  version = "0.21.2";

  src = fetchfromgh {
    owner = "ianyh";
    repo = "Amethyst";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pqUzcNUP8v3ls68BIzWXggXgUVe1wc/bN5BtXqKHXM4=";
    name = "Amethyst.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = {
    description = "Automatic tiling window manager for macOS à la xmonad";
    homepage = "https://ianyh.com/amethyst/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
