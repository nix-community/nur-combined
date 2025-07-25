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
    }:
    let
      hashInfo = hashes.${nixSystem}.${libc};
      currentStdenv = if overrideStdenv == null then stdenv else overrideStdenv;
      nbname = if bname == null then pname else bname; # new binary name
    in
    currentStdenv.mkDerivation {
      inherit pname version;

      src = fetchurl {
        url = "https://github.com/lxl66566/${pname}/releases/download/${version}/${pname}-${hashInfo.targetSystem}.tar.gz";
        sha256 = hashInfo.sha256;
      };
      dontConfigure = true;
      dontBuild = true;
      dontCheck = true;

      unpackPhase = ''
        tar -xzf $src
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        install -D ${nbname} $out/bin/${nbname}
        runHook postInstall
      '';

      meta = with lib; {
        inherit description license;
        homepage = "https://github.com/lxl66566/${pname}";
        platforms = [ nixSystem ];
        maintainers = with maintainers; [ "lxl66566" ];
        mainProgram = nbname;
      };
    };
}
