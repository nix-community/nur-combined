{ dataPackage ? some-datasets.config.datasets.mpi-sintel-training-images.package
, dataDir ? "${dataPackage}/data/training/clean/alley_1"
, dino
, omnimotion
, python
, raft
, raftThingsModel ? "${raft.merged.models.raft.weights.default.package}/raft-things.pth"
, runCommand
, some-datasets
}:
runCommand "omnimotion-inputs"
{
  nativeBuildInputs = [
    (python.withPackages (_: [
      dino
      omnimotion
      raft
    ]))
  ];
  requiredSystemFeatures = [ "cuda" ];
}
  ''
    # Not running because of chdir()s, etc
    # python -m omnimotion.preprocessing.main_processing --data_dir "${dataDir}"

    # https://github.com/qianqianwang68/omnimotion/blob/9576dd95477a65d65340425eb9c110853900f509/preprocessing/main_processing.py#L16-L29

    cd $TMPDIR

    mkdir data-dir/
    cp -rf "${dataDir}" data-dir/color
    chmod a+w data-dir/color

    export TORCH_HOME=${dino.merged.weights.vit_small_16_pretrain.package}/data/torch
    export TORCH_HUB=${dino.merged.weights.vit_small_16_pretrain.package}/data/torch/hub

    python -m omnimotion.preprocessing.exhaustive_raft --data_dir=data-dir/ --model="${raftThingsModel}"
    python -m omnimotion.preprocessing.extract_dino_features --data_dir data-dir/
    python -m omnimotion.preprocessing.filter_raft --data_dir data-dir/
    python -m omnimotion.preprocessing.chain_raft --data_dir data-dir/

    cp -rf data-dir $out
  ''
