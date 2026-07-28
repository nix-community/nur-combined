{
  buildDotnetModule,
  cmake,
  dotnetCorePackages,
  eigen,
  fetchFromGitHub,
  lapack,
  lib,
  libgeotiff,
  libjpeg,
  libpng,
  libtiff,
  libva,
  openjpeg,
  stdenv,
  vtk,
}:
buildDotnetModule (finalAttrs: {
  pname = "emgucv";
  version = "4.12.0";
  src = fetchFromGitHub {
    owner = "emgucv";
    repo = "emgucv";
    rev = finalAttrs.version;
    hash = "sha256-puWZFYCe8whg2hx1MMa1rk/ILz9M11J+kkgjF6LxF00=";
    # TODO: use nixpkgs' eigen, harfbuzz, hdf5, opencv, vtk?
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    stdenv.cc
  ];

  buildInputs = [
    eigen # < yes, this *does* impact the build, even though emgucv vendors its own
    lapack # < TODO: necessary?
    libgeotiff
    libjpeg
    libpng
    libtiff
    libva # < TODO: necessary?
    # openblas
    openjpeg
    # opencv
    vtk # < TODO: necessary?
  ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  # we only need libcvextern.so, and some of the other targets fail to build
  postPatch =
    lib.concatMapStrings
      (d: ''
        substituteInPlace CMakeLists.txt --replace-fail \
          'ADD_SUBDIRECTORY(${d})' \
          '# ADD_SUBDIRECTORY(${d})'
      '')
      [
        # "Emgu.Util"
        # >   Determining projects to restore...
        # > /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301: Unable to load the service index for source https://api.nuget.org/v3/index.json.
        # > /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301:   Resource temporarily unavailable (api.nuget.org:443)
        # > /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301:   Resource temporarily unavailable
        # >   Failed to restore /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj (in 5.86 sec).
        # TODO: with enough rangling, `nugetDeps` _should_ allow fixing this.
        # but it needs a slightly custom approach because of the mix of CMake + nuget
        "Emgu.CV"

        "Emgu.CV.Bitmap"
        "Emgu.CV.Wpf"
        "Emgu.CV.WindowsUI"
        "Emgu.CV.Example"
        "Emgu.CV.Test"
        "Emgu.CV.Cuda"
        "Emgu.CV.OCR"
        "Emgu.CV.Contrib"
        "Emgu.CV.Models"
        "Emgu.CV.Runtime"
        "platforms/nuget"
        "Emgu.CV.Runtime/Maui"
      ];

  # move libs/ -> lib/ so that nix will fix the .so linker paths
  postInstall = ''
    mv $out/libs/* $out/lib
    rmdir $out/libs
  '';

  # dontUnpackNugetPackage = true;
  # dontConfigureNuget = true;
  # dontCreateNugetSource = true;
  dontDotnetBuild = true;
  # dontDotnetCheck = true;
  # dontDotnetConfigure = true;
  dontDotnetInstall = true;
  # dontDotnetFixup = true;

  # dontStrip = false;
  # dontWrapGApps = false;
  # enableParallelBuilding = false;

  meta = {
    description = "A cross platform .Net wrapper to the OpenCV image processing library";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
