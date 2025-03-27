#
#
# package build fails with:
# [100%] Built target cvextern
# Building Emgu.CV with command:  "/nix/store/y20wcqi704x58v394scs6cyvay6x0x86-dotnet-sdk-wrapped-9.0.200/bin/dotnet" build -c Release /p:Platform="AnyCPU" "/build/source/Emgu.CV/NetStandard/Emgu.CV.csproj"
#   Determining projects to restore...
# /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301: Unable to load the service index for source https://api.nuget.org/v3/index.json.
# /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301:   Resource temporarily unavailable (api.nuget.org:443)
# /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj : error NU1301:   Resource temporarily unavailable
#   Failed to restore /build/source/Emgu.CV/NetStandard/Emgu.CV.csproj (in 5.78 sec).

{
  buildDotnetModule,
  cmake,
  dotnetCorePackages,
  # dotnetConfigureHook,
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
buildDotnetModule rec {
  pname = "emgucv";
  version = "4.10.0";
  src = fetchFromGitHub {
    owner = "emgucv";
    repo = "emgucv";
    rev = version;
    hash = "sha256-0WGXVIJCVnmqtyTzAjHnr8s0oQB9O1DUBFuhym9q+0E=";
    # TODO: use nixpkgs' eigen, harfbuzz, hdf5, opencv, vtk?
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    stdenv.cc
  ];

  buildInputs = [
    eigen  #< yes, this *does* impact the build, even though emgucv vendors its own
    lapack  #< TODO: necessary?
    libgeotiff
    libjpeg
    libpng
    libtiff
    libva  #< TODO: necessary?
    # openblas
    openjpeg
    # opencv
    vtk  #< TODO: necessary?
  ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  # we only need libcvextern.so, and some of the other targets fail to build
  postPatch = lib.concatMapStrings (d: ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'ADD_SUBDIRECTORY(${d})' \
      '# ADD_SUBDIRECTORY(${d})'
  '') [
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
}
