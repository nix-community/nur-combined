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
    name = "MacPass-${finalAttrs.version}.zip";
    hash = "sha256-LQ073JRbQsDB/nmx63Tllptfdo/8VqoobXPTSShzsXM=";
    inherit (finalAttrs) version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
})
