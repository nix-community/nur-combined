{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromGitLab,
  cmake,
}:

let
  yaml-cpp = fetchFromGitHub {
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "bbf8bdb087bb3f3621ca0a5ace06047805f4e9f3";
    hash = "sha256-o0iidUTFcvK9udbl12bfe4B8Qq616wvqIOJ54vso/9w=";
  };
  dynalo = fetchFromGitHub {
    owner = "maddouri";
    repo = "dynalo";
    rev = "411199d712003195966b380bb4f5dcd2d63f4733";
    hash = "sha256-gUunONYt/g88KfVajUEke2eNiGcPVvjKRXUqm/srqvs=";
  };
in
stdenv.mkDerivation rec {
  pname = "3gxtool";
  version = "1.3";

  src = fetchFromGitLab {
    owner = "thepixellizeross";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qnF0Dg3mcOhVqa894Fp4z2t/a6FTcZouH87oN0o9x/o=";
  };

  patches = [ ./dont-force-static.patch ];

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    rmdir extern/yaml-cpp extern/dynalo
    cp -r ${yaml-cpp} extern/yaml-cpp
    cp -r ${dynalo} extern/dynalo

    # goddamn case sensitivity
    substituteInPlace extern/dynalo/include/dynalo/detail/windows/dynalo.hpp \
      --replace-warn Windows.h windows.h
  '';

  # the original installPhase will install the incorrect files
  installPhase = ''
    pwd
    mkdir -p $out/bin
    cp 3gxtool${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  meta = with lib; {
    description = "An utility to generate 3GX plugins.";
    homepage = "https://gitlab.com/thepixellizeross/3gxtool";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.windows ++ platforms.darwin;
    mainProgram = "3gxtool";
  };
}
