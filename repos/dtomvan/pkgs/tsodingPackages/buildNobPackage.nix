{
  lib,
  stdenv,
  nob_h,
}:
lib.makeOverridable (
  args@{
    outPaths ? [ ],
    nobPath ? "nob.c",
    nobArgs ? [ ],
    pname,
    version,
    meta ? { },
    buildInputs ? [ ],
    nativeBuildInputs ? [ ],
    patches ? [ ],
    src,
    ...
  }:
  stdenv.mkDerivation (
    {
      inherit
        pname
        version
        meta
        buildInputs
        nativeBuildInputs
        src
        patches
        ;

      buildPhase = ''
        runHook preBuild
        # users of buildNobPackage are expected to patch out the vendored nob.h
        # at their own wit.
        cc -I${nob_h}/include -o nob ${nobPath}
        ./nob ${lib.concatStringsSep " " nobArgs}
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        ${lib.concatLines (lib.map (p: "mkdir -p $out/bin; cp ${p} $out/bin") outPaths)}

        runHook postInstall
      '';
    }
    // args
  )
)
