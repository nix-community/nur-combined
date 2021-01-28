{ dockerTools }:

dockerTools.pullImage {
  imageName = "quay.io/wekan/wekan";
  imageDigest = "sha256:f66f80352b5478c6fc2a6b91367b85e70401ac201dcb188aa63e21c5e1137ecc";
  sha256 = "028bcawc22lhnbzcm9wn6cgk1kq7k6lc643z1nvhb5n6m1y5jb9s";
  finalImageName = "wekan";
  finalImageTag = "4.81";
}
