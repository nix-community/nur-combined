{
  runtimeShell,
  stdenvNoCC,
}:
builtins.mapAttrs (
  name: script:
  let
    program = stdenvNoCC.mkDerivation {
      name = name;

      dontUnpack = true;
      dontConfigure = true;

      buildPhase = ''
        echo "#!${runtimeShell}" >> ${name}
        echo "${script}" >> ${name}
        chmod +x ${name}
      '';

      doCheck = false;

      installPhase = ''
        mkdir -p $out/bin
        cp ${name} $out/bin/${name}
      '';

      dontFixup = true;
    };
  in
  {
    type = "app";
    program = "${program}/bin/${name}";
    meta.description = script;
  }
)
