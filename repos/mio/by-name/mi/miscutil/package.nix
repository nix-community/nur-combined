{
  lib,
  stdenv,
  fetchFromGitHub,
  mono,
  msbuild,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "miscutil";
  version = "0-unstable-20101223";

  src = fetchFromGitHub {
    owner = "msdiniz";
    repo = "MiscUtil";
    rev = "4a985127a472ad40032909de09297a7062b80868";
    hash = "sha256-dIGcMpxvJj22ONMYz7N6FPT0P1S+XZAacxDpHgokxyw=";
  };

  nativeBuildInputs = [
    mono
    msbuild
  ];

  buildPhase = ''
    runHook preBuild

    msbuild MiscUtil/MiscUtil.csproj /p:Configuration=Release /p:Platform=AnyCPU

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -v MiscUtil/bin/Release/MiscUtil.dll $out/lib/

    runHook postInstall
  '';

  meta = {
    description = "Miscellaneous utility library by Jon Skeet";
    homepage = "https://github.com/msdiniz/MiscUtil";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
