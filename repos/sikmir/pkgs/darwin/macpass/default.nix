{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "MacPass";
  version = "0.8.1";

  src = fetchfromgh {
    owner = "MacPass";
    repo = "MacPass";
    tag = finalAttrs.version;
    hash = "sha256-LQ073JRbQsDB/nmx63Tllptfdo/8VqoobXPTSShzsXM=";
    name = "MacPass-${finalAttrs.version}.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
