{ lib
, buildPythonPackage
, fetchFromGitHub
, imageio
, tqdm
, python
, pillow
, requests
, scipy
, tensorflow
}:

buildPythonPackage rec {
  pname = "stylegan2";
  version = "unstable-2021-10-28";
  format = "other";

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = "stylegan2-ada";
    rev = "43eca5156619dd6ee649c70c4bc3f3cab19a5b79";
    hash = "sha256-N/RFQwICxDd3lyQNwWNXps2sO7Lpbh10gqBx+OwF2xo=";
  };

  nativeBuildInputs = [
    tensorflow
  ];

  postPatch =
    let
      cwdModules = [
        "dnnlib"
        "metrics"
        "training"
        "dataset_tool"
        "pretrained_networks"
        "projector"
      ];
      reCwdModules = builtins.concatStringsSep "\\|" cwdModules;
      prefix = "stylegan2";
    in
    ''
      find -iname '*.py' -exec sed -i 's/^\(\s*\)from \(${reCwdModules}\) import/\1from ${prefix}.\2 import/' '{}' \;
      find -iname '*.py' -exec sed -i 's/^\(\s*\)import \(${reCwdModules}\)/\1import ${prefix}.\2/' '{}' \;

      find -iname '*.py' -exec sed -i '/tensorflow.contrib/d' '{}' \;
      find -iname '*.py' -exec sed -i 's/import tensorflow as tf/import tensorflow.compat.v1 as tf/' '{}' \;
      find -iname '*.py' -exec sed -i '/import tensorflow.compat.v1 as tf/a tf.disable_v2_behavior()' '{}' \;
    '';

  propagatedBuildInputs = [
    imageio
    pillow
    requests
    scipy
    tensorflow
    tqdm
  ];

  installPhase =
    let
      moduleDir = "$out/${python.sitePackages}/stylegan2";
    in
    ''
      mkdir -p "${moduleDir}" $out/share/${pname} $out/bin
      install train.py $out/bin/${pname}-train.py
      install generate.py $out/bin/${pname}-generate.py
      install calc_metrics.py $out/bin/${pname}-calc_metrics.py
      install -t "${moduleDir}" dataset_tool.py projector.py style_mixing.py
      cp -rf dnnlib/ metrics/ training/ "${moduleDir}"/
    '';

  pythonImportsCheck = [
    "stylegan2.projector"
  ];

  meta = with lib; {
    description = "StyleGAN2 with adaptive discriminator augmentation (ADA) - Official TensorFlow implementation";
    homepage = "https://github.com/NVlabs/stylegan2-ada";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
