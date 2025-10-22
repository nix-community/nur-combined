{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mountains";
  version = "0-unstable-2025-10-16";

  src = fetchFromGitHub {
    owner = "akirmse";
    repo = "mountains";
    rev = "f58bc6205ea2e6fc94e8185f8cc1a6cb442f33c5";
    hash = "sha256-WRL9pwzSb4NLAzweQJ4dcReEofRuGnMIV8W/cyOpga0=";
  };

  sourceRoot = "${finalAttrs.src.name}/code";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "ar -r" "${stdenv.cc.targetPrefix}ar -r"
    substituteInPlace ../scripts/run_prominence.py \
      --replace-fail "'--binary_dir', default='release'" "'--binary_dir', default='$out/bin'"
  '';

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "CC:=$(CC)"
    "LINK=$(CXX)"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-Wno-error=stringop-overflow";

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (
        p: with p; [
          gdal
        ]
      );
    in
    ''
      install -Dm755 release/{isolation,prominence,merge_divide_trees,filter_points,compute_parents} -t $out/bin

      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp ../scripts/*.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/run_prominence \
        --add-flags "$site_packages/run_prominence.py"
    '';

  meta = {
    description = "Code to compute the prominence and isolation of mountains from digital elevation data";
    homepage = "https://github.com/akirmse/mountains";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
