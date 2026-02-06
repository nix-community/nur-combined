{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  ruby,
  bundlerEnv,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trmnl_preview";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "usetrmnl";
    repo = "trmnlp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vem1hkX5wCZRarWyuC6nhgEw4C42XY899NwngbS7jWc=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase =
    let
      env = bundlerEnv {
        name = "trmnl_preview";
        gemdir = ./.;
        gemset = ./gemset.nix;
      };
    in
    ''
      mkdir -p $out/bin $out/share/trmnl_preview
      cp -r . $out/share/trmnl_preview

      makeWrapper ${ruby}/bin/ruby $out/bin/trmnlp \
        --add-flags "-I $out/share/trmnl_preview/lib $out/share/trmnl_preview/bin/trmnlp" \
        --set GEM_PATH "${env}/${env.ruby.gemPath}"
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  meta = {
    description = "A local dev server for building TRMNL plugins";
    homepage = "https://github.com/usetrmnl/trmnlp";
    license = lib.licenses.mit;
    mainProgram = "trmnlp";
    platforms = [ "x86_64-linux" ];
  };
})
