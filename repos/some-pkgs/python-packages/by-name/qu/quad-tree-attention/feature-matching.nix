src:

{ lib
, buildPythonPackage
, quad-tree-attention
, rsync
, albumentations
, einops
, h5py
, yacs
, joblib
, loguru
, pytorch
, pytorch-lightning
, torchvision
, timm
, kornia
}:

buildPythonPackage {
  pname = "FeatureMatching";
  inherit (quad-tree-attention) version;

  format = "flit";

  src = "${src}/FeatureMatching";
  postPatch = ''
    mv src FeatureMatching
    cp train.py FeatureMatching/train.py

    mv configs FeatureMatching/configs
    mv demo FeatureMatching/demo

    rsync -r --safe-links data/ FeatureMatching/data/

    find -iname '*.py' -exec sed -i \
      -e 's/^from src\./from FeatureMatching./' \
      -e 's/^from configs\./from FeatureMatching.configs./' \
      -e '/sys.path.append/d' \
      '{}' +

    cat << EOF > pyproject.toml
    [build-system]
    requires = ["flit_core"]
    build-backend = "flit_core.buildapi"

    [project]
    name = "FeatureMatching"
    version = "0.0.1"
    description = "LoFTR with Quad Tree Attention"

    [tool.flit.sdist]
    include = ["configs/", "data/"]
  '';

  propagatedBuildInputs = [
    quad-tree-attention
    albumentations
    h5py
    timm
    yacs
    joblib
    loguru
    kornia
  ];

  # Not good in propagated inputs
  checkInputs = [
    (einops.overridePythonAttrs (a: { doCheck = false; }))
    pytorch
    pytorch-lightning
    torchvision
  ];

  nativeBuildInputs = [
    rsync
  ];

  pythonImportsCheck = [
    "FeatureMatching"
    "FeatureMatching.config.default"
    "FeatureMatching.utils.misc"
    "FeatureMatching.utils.profiler"
    "FeatureMatching.lightning.data"
    "FeatureMatching.lightning.lightning_loftr"
  ];

  meta = with lib; {
    maintainers = [ maintainers.SomeoneSerge ];
    platforms = platforms.unix;
  };
}
