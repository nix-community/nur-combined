{
  lib,
  stdenv,
  cmake,
  eigen,
  catch2_3,
  python3 ? null,
  source,
}:

stdenv.mkDerivation rec {
  inherit (source) pname src;
  patches = [ ./pc.patch ];
  version = lib.removePrefix "v" source.version;

  nativeBuildInputs =
    [
      cmake
      eigen
      catch2_3
    ]
    ++ (
      if python3 != null then
        [
          (python3.withPackages (
            ps: with ps; [
              setuptools
              pybind11
            ]
          ))
        ]
      else
        [ ]
    );

  # Building the tests currently fails on AArch64 due to internal compiler
  # errors (with GCC 9.2):
  cmakeFlags = [
    "-DRANGES_ENABLE_WERROR=OFF"
  ] ++ (if python3 != null then [ ] else [ "-DAUTODIFF_BUILD_PYTHON=OFF" ]);

  # checkTarget = "test";

  meta = with lib; {
    description = "automatic differentiation made easier for C++";
    homepage = "https://autodiff.github.io/";
    changelog = "https://github.com/autodiff/autodiff/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
