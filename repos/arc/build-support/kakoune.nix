{ self, ... }: let
  buildKakPlugin = self.callPackage ({ lib, stdenvNoCC }: {
    src, sources ? [ ],
    mkDerivation ? stdenvNoCC.mkDerivation,
    name ? "${pname}-${attrs.version}",
    pname ? (builtins.parseDrvName name).name,
    kakrc ? "share/kak/autoload/${pname}.kak",
    ...
  } @ attrs: let
    attrs' = builtins.removeAttrs attrs [ "mkDerivation" ];
    buildKakrc = drv: {
      kakrc = "${drv}/${kakrc}";
    };
    drv = mkDerivation ({
      inherit kakrc;
    } // lib.optionalAttrs (src != null) {
      installPhase = ''
        runHook preInstall

        if [[ -d $src ]]; then
          target=$src
        else
          target=$out/share/kak/${pname}
          install -d $target
          cp -r . $target
        fi

        if [[ -n $sources ]]; then
          for source in $sources; do
            echo "source \"$target/$source\""
          done > rc.kak
        else
          find -L $target -type f -name '*.kak' -fprintf rc.kak 'source "%p"\n'
        fi

        install -Dm0644 rc.kak $out/$kakrc

        runHook postInstall
      '';
    } // attrs');
  in lib.drvPassthru buildKakrc drv) { };
  buildKakPluginFrom2Nix = self.callPackage ({ buildKakPlugin }: attrs: buildKakPlugin ({
    src = null;
  } // attrs)) { };
in {
  inherit buildKakPlugin buildKakPluginFrom2Nix;
}
