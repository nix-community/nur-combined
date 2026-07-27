{
  sources,

  lib,
  stdenvNoCC,
}:
let
  mkProton = lib.makeOverridable (
    {
      source,
      meta,
      version ? source.version,
      steamDisplayName ? source.pname,
    }:
    stdenvNoCC.mkDerivation {
      inherit (source) pname src;
      inherit version;

      outputs = [
        "out"
        "steamcompattool"
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/share/steam/compatibilitytools.d/$pname
        cp -r * $out/share/steam/compatibilitytools.d/$pname
        ln -s $out/share/steam/compatibilitytools.d/$pname $steamcompattool
        substituteInPlace $steamcompattool/compatibilitytool.vdf \
          --replace-fail "${source.version}" "${steamDisplayName}"

        runHook postBuild
      '';

      meta = {
        license = lib.licenses.bsd3;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    }
  );
in
{
  cachyos = mkProton rec {
    source = sources.proton-cachyos;
    version = lib.removePrefix "cachyos-" source.version;
    meta = {
      description = "A compatibility tool for Steam Play based on Wine and additional components, experimental branch with extra CachyOS flavour";
      homepage = "https://github.com/CachyOS/proton-cachyos";
      broken = true; # broken symlinks
    };
  };

  ge = mkProton rec {
    source = sources.proton-ge;
    version = lib.removePrefix "GE-Proton" source.version;
    meta = {
      description = "Compatibility tool for Steam Play based on Wine and additional components";
      homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    };
  };

  sarek = mkProton rec {
    source = sources.proton-sarek;
    version = lib.removePrefix "Proton-Sarek" source.version;
    meta = {
      description = "Steam Play compatibility tool based on Wine and additional components, with a focus on older PCs";
      homepage = "https://github.com/pythonlover02/Proton-Sarek";
    };
  };

  sarek-async = mkProton rec {
    source = sources.proton-sarek-async;
    version = lib.removePrefix "Proton-Sarek" source.version;
    meta = {
      description = "Steam Play compatibility tool based on Wine and additional components, with a focus on older PCs (with DXVK async)";
      homepage = "https://github.com/pythonlover02/Proton-Sarek";
    };
  };

  em = mkProton rec {
    source = sources.proton-em;
    version = lib.removePrefix "EM-" source.version;
    meta = {
      description = "Development Oriented Compatibility tool for Steam Play based on Wine and additional components";
      homepage = "https://github.com/Etaash-mathamsetty/Proton";
    };
  };
}
