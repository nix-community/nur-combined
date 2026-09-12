{
  stdenv,
  lib,
  fetchgit,
  zig_0_15,
  jq,
  callPackage,
  ...
}:
let
  zig = zig_0_15;
  package = stdenv.mkDerivation (finalAttrs: {
    pname = "makko";
    version = "3.0.0";
    src = fetchgit {
      url = "https://forge.starlightnet.work/Team/Makko.git";
      tag = finalAttrs.version;
      hash = "sha256-glXOWTQrTlHO6yaWM1mExkZL0nLrkKyqeFiTAsK+PQk=";
    };

    nativeBuildInputs = [ zig ];
    zigBuildFlags = [
      "-Doptimize=ReleaseSmall"
      "--system"
      (callPackage ./deps.nix { })
    ];

    meta = {
      description = "A simple, lightweight, and portable Static Site Generator written in Zig.";
      homepage = "https://makko.starlightnet.work/";
      changelog = "https://forge.starlightnet.work/Team/Makko/releases";
      license = lib.licenses.zlib;
      mainProgram = "makko";
    };
  });
in
package
// {
  buildMakkoSite = (
    args:
    stdenv.mkDerivation (
      {
        name = "${args.src.name}-rendered";
        nativeBuildInputs = [
          package
          jq
        ];
        buildPhase = ''
          runHook preBuild

          makko .

          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall

          cp -r $(jq -r '.paths.output' makko.json)/ $out

          runHook postInstall
        '';
      }
      // args
    )
  );
}
