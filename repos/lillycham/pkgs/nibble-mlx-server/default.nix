{
  lib,
  fetchFromGitHub,
  fetchurl,
  python3,
  writeShellScriptBin,
}:
let
  # MLX from Apple's PyPI wheels. The nixpkgs build has no Metal support,
  # because Apple's Metal shader compiler can't run in the Nix sandbox. The
  # wheels are for CPython 3.14, so this breaks when nixpkgs moves python3 on.
  mlxVersion = "0.32.2";

  python = python3.override {
    self = python;
    packageOverrides = final: prev: {
      mlx =
        let
          wheel = args: final.buildPythonPackage (args // { version = mlxVersion; format = "wheel"; });
          mlx-metal = wheel {
            pname = "mlx-metal";
            src = fetchurl {
              url = "https://files.pythonhosted.org/packages/79/ec/34f37376e26d537fadffb99af3a760d6545e37f5e1a30a552baadf237fc5/mlx_metal-${mlxVersion}-py3-none-macosx_15_0_arm64.whl";
              hash = "sha256-VaNpJQ0iCyzxAhOoeirBsaQgYIxbNbHfTnFHrI4y8SE=";
            };
          };
        in
        wheel {
          pname = "mlx";
          src = fetchurl {
            url = "https://files.pythonhosted.org/packages/f8/c8/6928f4b9ca8f190c7c7a19c0a67920aa1742c62c6e66b05f7a1e21da728c/mlx-${mlxVersion}-cp314-cp314-macosx_15_0_arm64.whl";
            hash = "sha256-j8Qz41pwWOMPeiJcOfzga6QTlP6On9Zzg7cPCwbeOYw=";
          };
          # mlx/core.so looks for libmlx.dylib in its own mlx/lib, as a pip
          # install would have it. So put mlx-metal's lib there, and don't
          # list mlx-metal as a separate package.
          postInstall = ''
            cp -r ${mlx-metal}/${final.python.sitePackages}/mlx/lib $out/${final.python.sitePackages}/mlx/
          '';
          dontCheckRuntimeDeps = true;
          pythonImportsCheck = [ "mlx.core" ];
        };

      mlx-lm = prev.mlx-lm.overridePythonAttrs (old: rec {
        # Ahead of nixpkgs (0.31.3), which can't load models converted with
        # the newer config names, such as LFM2.5.
        version = "0.32.0";
        src = fetchFromGitHub {
          owner = "ml-explore";
          repo = "mlx-lm";
          tag = "v${version}";
          hash = "sha256-ZkzwImue0UJ+ZRNJVanziqEhdYSO2dS8Y9yQAIIDHK8=";
        };
        build-system = old.build-system ++ [ final.setuptools-scm ];
        # The tests want a GPU, which the sandbox doesn't have. nixpkgs only
        # gets sentencepiece through the test inputs, but mlx-lm needs it at
        # runtime, so add it back as a real dependency.
        doCheck = false;
        dependencies = old.dependencies ++ [ final.sentencepiece ];
        # A small model sometimes ends its turn without the closing
        # </tool_call> tag. The server then sees a stop with no state, and
        # throws the whole call away. Keep any call text that is left when
        # generation ends.
        postPatch = (old.postPatch or "") + ''
          substituteInPlace mlx_lm/server.py \
            --replace-fail 'if prev_state == "tool" and tool_text:' 'if tool_text:'
        '';
      });
    };
  };

  env = python.withPackages (ps: [ ps.mlx-lm ]);
in
# mlx_lm.server on its own, without a python3 on PATH.
(writeShellScriptBin "nibble-mlx-server" ''
  exec ${env}/bin/mlx_lm.server "$@"
'').overrideAttrs (old: {
  meta = old.meta // {
    description = "The MLX model server that nibble starts on demand";
    homepage = "https://github.com/lillycham/nibble";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
})
