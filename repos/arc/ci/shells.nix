{ arc }:
let
  mkShell = attrs: arc.pkgs.mkShell (attrs // {
    nobuildPhase = ''
      mkdir $out
      echo $buildInputs > $out/inputs
      echo $nativeBuildInputs > $out/nativeInputs
      export PATH_PURE=$PATH
      ENV_VARS=(PATH_PURE)
      ENV_VARS+=(''${!CARGO_@})
      declare -p "''${ENV_VARS[@]}" > $out/env
    '';
  });
  rust = arc.shells.rust.override { inherit mkShell; };
  shells = arc.pkgs.lib.optionals (arc.pkgs ? rustChannelOf) [ rust.stable rust.nightly ];
in
shells
