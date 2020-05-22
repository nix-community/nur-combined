{ stdenv
, buildEnv
}:
{ pkg
, pkgName ? builtins.replaceStrings ["-wrapper" "-all"] ["" ""] (builtins.parseDrvName pkg.name).name
, pkgVersion ? builtins.replaceStrings ["_"] ["."] (builtins.parseDrvName pkg.name).version
, modPrefix ? "nix/"
, modName ? "${modPrefix}${pkgName}/${pkgVersion}.lua"
, modLoad ? []
, modPrereq ? []
, modConflict ? [pkgName] ++ stdenv.lib.optional (modPrefix != "") (modPrefix + pkgName)
, modEnv ? builtins.replaceStrings ["-"] ["_"] (stdenv.lib.toUpper pkgName)
, modPath ? ""
, addLDLibraryPath ? false
, addCFlags ? true
}:

let monopkg = if builtins.length pkg.outputs > 1
  then buildEnv {
    name = pkg.name;
    paths = map (out: pkg.${out}) pkg.outputs;
  } else pkg;
in

stdenv.mkDerivation {
  builder = ./builder.sh;

  name = "module-${pkg.name}";

  buildInputs = [monopkg];

  inherit pkgName pkgVersion modPrefix modName modLoad modPrereq modConflict modEnv modPath addLDLibraryPath addCFlags;

  # sort of hacky, duplicating cc-wrapper:
  nixInfix = stdenv.lib.replaceStrings ["-"] ["_"] stdenv.targetPlatform.config;

  passthru = {
    inherit pkg modName;
  };
}
