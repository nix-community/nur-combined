{ dockerTools }:

dockerTools.pullImage {
  imageName = "wekanteam/wekan";
  imageDigest = "sha256:5aa26f2f5f6181835c0338a3b7b8c8030a0e0362038c805f659604e8c0dcc27d";
  sha256 = "0bnip138h9161m2p44d4s6183hcx7zfiw6k90xg6c7lbz934hzdd";
  finalImageName = "wekan";
  finalImageTag = "4.95";
}
