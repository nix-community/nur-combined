{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  unzip,
}:

{
  pname,
  version,
  hashes,
  nixSystem,
  bname ? null,
  libc ? "gnu",
  otherNativeBuildInputs ? [ ],
  otherBuildInputs ? [ ],
  description ? "",
  license ? lib.licenses.mit,
  overrideStdenv ? null,
  owner ? "lxl66566",
  # manager.py 元数据：为 false 时 CI 不自动更新该包；构建时忽略
  autoupdate ? true,
}:

let
  hashInfo = hashes.${nixSystem}.${libc};
  currentStdenv = if overrideStdenv == null then stdenv else overrideStdenv;
  nbname = if bname == null then pname else bname;

  urlTemplate = hashInfo.template or null;
  defaultUrl = "https://github.com/${owner}/${pname}/releases/download/${version}/${pname}-${hashInfo.targetSystem}.tar.gz";
  finalUrl =
    if urlTemplate != null then
      lib.replaceStrings
        [ "__pname__" "__bname__" "__version__" "__bare_version__" "__targetSystem__" "__owner__" ]
        [ pname nbname version (lib.removePrefix "v" version) hashInfo.targetSystem owner ]
        urlTemplate
    else
      defaultUrl;
in
currentStdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = finalUrl;
    sha256 = hashInfo.sha256;
  };

  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;

  # avoid substituters
  preferLocalBuild = true;
  allowSubstitutes = false;

  nativeBuildInputs =
    otherNativeBuildInputs
    ++ lib.optional (libc != "musl") autoPatchelfHook
    ++ lib.optional (lib.hasSuffix ".zip" finalUrl) unzip;

  buildInputs = lib.optionals (libc != "musl") [ stdenv.cc.cc.lib ] ++ otherBuildInputs;

  unpackPhase = ''
    runHook preUnpack
    if [[ $src == *.zip ]]; then
      unzip $src
    else
      tar -xzf $src
    fi
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    bin="$(find . -type f -name '${nbname}' -print -quit)"
    if [ -z "$bin" ]; then
      echo "error: binary '${nbname}' not found in unpacked source" >&2
      exit 1
    fi
    install -D "$bin" $out/bin/${nbname}
    runHook postInstall
  '';

  meta = with lib; {
    inherit description license;
    homepage = "https://github.com/${owner}/${pname}";
    platforms = [ nixSystem ];
    maintainers = with maintainers; [ "lxl66566" ];
    mainProgram = nbname;
  };
}
