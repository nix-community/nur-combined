{ lib
, bash
, buildPythonPackage
, callPackage
, configargparse
, dino
, fetchFromGitHub
, fetchzip
, imageio
, imageio-ffmpeg
, kornia
, matplotlib
, nixpkgs-pytools
, omnimotion
, opencv4
, prefix-python-modules
, python
, raft
, runCommand
, scipy
, setuptools
, some-datasets
, some-util
, stdenv
, tensorboardx
, torch
, torchvision
, tqdm
}:

buildPythonPackage rec {
  pname = "omnimotion";
  version = "unstable-2023-09-11";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "qianqianwang68";
    repo = "omnimotion";
    rev = "9576dd95477a65d65340425eb9c110853900f509";
    hash = "sha256-PwJbu/E5VPFvf35NxqGSlfcRXtWiX99oKZpAwh0QSKw=";
  };

  outputs = [ "out" "configs" ];

  pyprojectToml = ./pyproject.toml;
  postPatch =
    ''
      substituteInPlace preprocessing/exhaustive_raft.py \
        --replace ", default='models/raft-things.pth'" ""

      find -iname '*.py' -exec sed -i 's/[[:space:]]*sys.path.append.*//' '{}' \;
      prefix-python-modules . \
        --prefix "$pname" \
        --rename-external chain_raft omnimotion.preprocessing.chain_raft "**" \
        --rename-external vision_transformer dino.vision_transformer "**" \
        --rename-external raft raft.core.raft "**" \
        --rename-external utils dino.utils "**/extract_dino_features.py" \
        --rename-external utils raft.core.utils "**/exhaustive_raft.py"
      cp "$pyprojectToml" pyproject.toml
    '';

  nativeBuildInputs = [
    setuptools
    prefix-python-modules
    nixpkgs-pytools
  ];
  propagatedBuildInputs = [
    configargparse
    imageio
    imageio-ffmpeg
    kornia
    matplotlib
    opencv4
    scipy
    tensorboardx
    torch
    torchvision
    tqdm
  ];

  postInstall = ''
    mkdir -p $configs/data/${pname}
    cp -rf configs/* $configs/data/${pname}
  '';

  postFixup = ''
    mkdir -p $out/bin

    buildPythonPath "$out $pythonPath"

    cat << EOF > $out/bin/${pname}-viz
    #!${lib.getExe bash}
    export PYTHONPATH=\$PYTHONPATH:$program_PYTHONPATH
    ${lib.getExe python} -m omnimotion.viz \$@
    EOF
    chmod a+x $out/bin/${pname}-viz

    cat << EOF > $out/bin/${pname}-viz-default
    #!${lib.getExe bash}
    export PYTHONPATH=\$PYTHONPATH:$program_PYTHONPATH
    ${lib.getExe python} -m omnimotion.viz --config=$configs/data/${pname}/default.txt \$@
    EOF
    chmod a+x $out/bin/${pname}-viz-default
  '';

  pythonImportsCheck = [
    "omnimotion.config"
    "omnimotion.criterion"
    "omnimotion.networks"
    "omnimotion.util"
    "omnimotion.viz"
  ];

  passthru = rec {
    merged =
      let
        OverridePackage = with lib; with lib.types; submodule ({ config, name, ... }: {
          name = mkDefault "${name}.zip";
          package = fetchzip { inherit (config) urls hash; extension = ".zip"; };
        });
        m = lib.evalModules {
          modules = with lib; with lib.types; with some-util.types; [
            { options.examples = mkOption { type = attrsOf RemoteFile; }; }
            { options.examples = mkOption { type = attrsOf OverridePackage; }; }
            { inherit examples; }
            ./module-auto-visualizations.nix
            { _module.args = { inherit runVisualizer; }; }
            ({ config, ... }: {
              options.modelDescriptions = mkOption { type = attrsOf package; };
              config.modelDescriptions = callPackage ./model-descriptions.nix {
                inherit (config) examples;
              };
            })
          ];
        };
      in
      m.config;

    examples = import ./examples.nix;
    runVisualizer = callPackage ./run-visualizer.nix { };

    tests.viz-horsejump-with-butterfly-weights =
      merged.visualizations.horsejump-low.override { inherit (merged.visualizations.butterfly.viz-args) checkpoint; };
    tests.viz-butterfly = runVisualizer {
      checkpoint = "${merged.examples.butterfly.package}/model*.pth";
      dataDir = "${merged.examples.butterfly.package}";
      maskPath = "${merged.examples.butterfly.package}/mask_0.png";
    };
    tests.preprocess-sintel = callPackage ./preprocess-dataset.nix { };
    tests.train-sintel = callPackage ./train.nix { dataDir = tests.preprocess-sintel; };
  };

  meta = with lib; {
    description = "";
    homepage = "https://github.com/qianqianwang68/omnimotion";
    license = licenses.asl20;
    maintainers = with maintainers; [ SomeoneSerge ];
    mainProgram = "omnimotion";
    platforms = platforms.all;
  };
}
