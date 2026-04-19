{ lib, stdenv, fetchurl, autoPatchelfHook }: let
    sources = import ./sources.nix;
    currentSystem = stdenv.hostPlatform.system;
    pkgInfo = sources.platforms.${currentSystem} or (throw "Unsupported system: ${currentSystem}");
    baseUrl = "https://drive.mcsl.com.cn/d/ME-Frp/Lanzou/MEFrp-Core/${sources.version}";
    fileName = "mefrpc_linux_${pkgInfo.arch}_${sources.version}.tar";
in stdenv.mkDerivation rec {
    pname = "mefrpc";
    version = sources.version;
    src = fetchurl {
      url = "${baseUrl}/${fileName}";
      hash = pkgInfo.hash;
    };
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ stdenv.cc.cc.lib ];
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      find . -maxdepth 2 -type f -executable -exec install -m755 -D {} $out/bin/mefrpc \;
      runHook postInstall
    '';

    meta = with lib; {
        description = "MagicEdge Frpc";
        homepage = "https://mefrp.com";
        sourceProvenance = [ sourceTypes.binaryNativeCode ];
        license = licenses.unfree;
        platforms = builtins.attrNames sources.platforms;
        maintainers = [ ];
        mainProgram = "mefrpc";
    };
}