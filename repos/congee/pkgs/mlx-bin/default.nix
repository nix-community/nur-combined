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
  version = "0.32.2";

  # Wheels are published per macOS deployment target. 26_0 additionally
  # carries Metal-4 NAX kernels (M5-class GPUs); on M1-M4 the variants are
  # functionally equivalent. Pick the newest your macOS supports.
  platform = "macosx_26_0_arm64";

  wheels = {
    macosx_14_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/35/c8/d4f7c648d6ea7baee986047ca30647a5733df5b9c77bb0a262dc5aca0843/mlx-${version}-cp314-cp314-macosx_14_0_arm64.whl";
        hash = "sha256-yZ47ZFG7SlUHHPGVlPVkQ1vYjedwCPN35hGkCou/syg=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/f7/ab/ba1952908c5d2a5070cf1cfbfea0161c4751ea62299e2776819810917483/mlx_metal-${version}-py3-none-macosx_14_0_arm64.whl";
        hash = "sha256-OCX/83nbwQfdNBPlZKBsrqokgZkQ7EnAQ55FTAahubg=";
      };
    };
    macosx_15_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/f8/c8/6928f4b9ca8f190c7c7a19c0a67920aa1742c62c6e66b05f7a1e21da728c/mlx-${version}-cp314-cp314-macosx_15_0_arm64.whl";
        hash = "sha256-j8Qz41pwWOMPeiJcOfzga6QTlP6On9Zzg7cPCwbeOYw=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/79/ec/34f37376e26d537fadffb99af3a760d6545e37f5e1a30a552baadf237fc5/mlx_metal-${version}-py3-none-macosx_15_0_arm64.whl";
        hash = "sha256-VaNpJQ0iCyzxAhOoeirBsaQgYIxbNbHfTnFHrI4y8SE=";
      };
    };
    macosx_26_0_arm64 = {
      mlx = {
        url = "https://files.pythonhosted.org/packages/ce/f0/4cb126cdfffb6d976fedba1dc276cb714e1a37d6f47527dc5deeaa8a8668/mlx-${version}-cp314-cp314-macosx_26_0_arm64.whl";
        hash = "sha256-NQNhfjqmqOQR31MjbVvKA5/MqXVW8a3hxOXMimTeUtI=";
      };
      mlx-metal = {
        url = "https://files.pythonhosted.org/packages/dd/cd/4e50bf325100e7165e13d025f264362bf0009196269f9eaf87f2c6e738a2/mlx_metal-${version}-py3-none-macosx_26_0_arm64.whl";
        hash = "sha256-5qvqyaxSZYMMnBVBtvlum+N6hcJEZ2OkatRmxjo4N6s=";
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
