{ pkgs }:

with pkgs.lib;
{
  makeBinPackage =
    {
      stdenv,
      fetchurl,
      lib,
      pkgs,
      pname,
      version,
      hashes,
      nixSystem,
      bname ? null,
      libc ? "gnu",
      description ? "",
      license ? licenses.mit,
      overrideStdenv ? null,
      owner ? "lxl66566",
    }:
    let
      hashInfo = hashes.${nixSystem}.${libc};
      currentStdenv = if overrideStdenv == null then stdenv else overrideStdenv;
      nbname = if bname == null then pname else bname;

      # download url calculation
      urlTemplate = hashInfo.template or null;
      defaultUrl = "https://github.com/${owner}/${pname}/releases/download/${version}/${pname}-${hashInfo.targetSystem}.tar.gz";
      finalUrl =
        if urlTemplate != null then
          lib.replaceStrings
            [ "__pname__" "__bname__" "__version__" "__targetSystem__" "__owner__" ]
            [ pname nbname version hashInfo.targetSystem owner ]
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

      nativeBuildInputs = lib.optional (lib.hasSuffix ".zip" finalUrl) pkgs.unzip;

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
        install -D ${nbname} $out/bin/${nbname}
        runHook postInstall
      '';

      meta = with lib; {
        inherit description license;
        homepage = "https://github.com/${owner}/${pname}";
        platforms = [ nixSystem ];
        maintainers = with maintainers; [ "lxl66566" ];
        mainProgram = nbname;
      };
    };
}
