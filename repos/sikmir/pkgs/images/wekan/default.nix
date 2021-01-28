{ dockerTools }:

dockerTools.pullImage {
  imageName = "quay.io/wekan/wekan";
  imageDigest = "sha256:f66f80352b5478c6fc2a6b91367b85e70401ac201dcb188aa63e21c5e1137ecc";
  sha256 = "e22fd21376d0ca96e75406940bb8478fc5820289069630a9808f2f28a028212f";
  finalImageName = "wekan";
  finalImageTag = "4.81";
}
