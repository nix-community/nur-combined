# MLX from the official PyPI wheels instead of the nixpkgs source build.
#
# nixpkgs builds mlx with MLX_BUILD_METAL=OFF because Apple's `metal` shader
# compiler is closed-source and unavailable in the sandbox, so the nixpkgs
# package silently runs on CPU (~0 tok/s for 35B models). The PyPI wheels ship
# libmlx.dylib plus a prebuilt mlx.metallib, all MIT-licensed.
#
# Upstream split the distribution: the `mlx` wheel is a thin frontend whose
# core.cpython-*.so loads `@loader_path/lib/libmlx.dylib`, and the `mlx-metal`
# wheel drops libmlx.dylib + mlx.metallib into that same `mlx/lib/` directory.
# Both wheels must therefore land in ONE store path; two separate packages
# would break the @loader_path lookup across site-packages roots.
{
  lib,
  buildPythonPackage,
  fetchurl,
  python,
  unzip,
}:

let
  version = "0.31.2";

  # Wheels are published per macOS deployment target. 26_0 additionally
  # carries Metal-4 NAX kernels (M5-class GPUs); on M1-M4 the variants are
  # functionally equivalent. Pick the newest your macOS supports.
  platform = "macosx_26_0_arm64";

  wheels = {
    macosx_14_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/8b/f5/e63f6a9316ded2d14a8ebc7a9ca25734c784e8c54d064a78b4dceeacec0e/mlx-${version}-cp314-cp314-macosx_14_0_arm64.whl";
        hash = "sha256-oTyc4jw97vaqWgkxXnlT4aXcMR6FH6Fvx0yB+yUJwLk=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/3f/69/fe3b783ebe999f3118234e1e940feb622518bfb1dea6ac5d13b1d36a8449/mlx_metal-${version}-py3-none-macosx_14_0_arm64.whl";
        hash = "sha256-slOFvO4Y/BlAkiVbi1O5o9hInrZQ5ZFg8bV6rdB6otw=";
      };
    };
    macosx_15_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/31/50/9d0c03ea3134cd85c132df7b0e4b75e6344bd8b4881a0b9c465cfa27f724/mlx-${version}-cp314-cp314-macosx_15_0_arm64.whl";
        hash = "sha256-sHZL8R/Dpx3umI4ZJ17vZ3dcq2MRLYu37xc8qLKhJHw=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/4f/5d/4c690d5b93c30ba002656c37363159d978705bf8eb801b8481840fb942c2/mlx_metal-${version}-py3-none-macosx_15_0_arm64.whl";
        hash = "sha256-6dTl/ObKEKh6DjiFl/mVGa1ZTQnmdHCLUxK9i9T1mX0=";
      };
    };
    macosx_26_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/ef/5b/d364cc793bcb504621313acb55627cf0d5403ab2e0a594aa081cdbe4591f/mlx-${version}-cp314-cp314-macosx_26_0_arm64.whl";
        hash = "sha256-Wcy9DwBE1Pl/EevL8MSAvJ6WKTX9lidfEglUr+plvoo=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/99/82/11fd62a8d7a3e96e5c43220b17de0151e3f10101f8bb3b865f5bd9cdd074/mlx_metal-${version}-py3-none-macosx_26_0_arm64.whl";
        hash = "sha256-hP+2DuUD8D62hPX7Fo1c/zHioWt/J8FzHq92Yr1um0Y=";
      };
    };
  };

  metalWheel = fetchurl wheels.${platform}.mlx-metal;
in

# The wheels are pinned to cp314; bump the urls/hashes when python changes.
assert lib.assertMsg (python.pythonVersion == "3.14")
  "mlx-bin pins cp314 wheels but python is ${python.pythonVersion}";

buildPythonPackage {
  pname = "mlx";
  inherit version;
  format = "wheel";

  src = fetchurl wheels.${platform}.mlx;

  nativeBuildInputs = [ unzip ];

  # Merge the backend wheel into the same site-packages (mlx/lib/*.dylib,
  # mlx.metallib, headers). -o: both wheels ship a few identical stub files.
  postInstall = ''
    unzip -o ${metalWheel} -d $out/${python.sitePackages}
  '';

  # The frontend's Requires-Dist names `mlx-metal`, satisfied by the merge
  # above rather than by a separate nix package.
  dontCheckRuntimeDeps = true;

  # Prebuilt, ad-hoc-signed binaries; stripping would invalidate signatures.
  dontStrip = true;

  pythonImportsCheck = [ "mlx.core" ];

  meta = {
    description = "Array framework for Apple silicon (official wheels with prebuilt Metal kernels)";
    homepage = "https://github.com/ml-explore/mlx";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
  };
}
