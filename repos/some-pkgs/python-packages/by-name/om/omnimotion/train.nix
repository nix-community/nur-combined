{ runCommand
, python
, dino
, raft
, omnimotion
, omnimotionConfig ? "${omnimotion.configs}/data/omnimotion/default.txt"
, dataDir
}:
runCommand "model_10000.pth"
{
  nativeBuildInputs = [
    (python.withPackages (_: [
      dino
      omnimotion
      raft
    ]))
  ];
  outputs = [ "out" "logs" ];
  requiredSystemFeatures = [ "cuda" ];
}
  ''
    mkdir $out
    cd $out
    python -m omnimotion.train \
      --config ${omnimotionConfig} \
      --data_dir "${dataDir}"
    mv logs "$logs"
  ''
