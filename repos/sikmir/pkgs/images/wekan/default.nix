{ dockerTools }:

dockerTools.pullImage {
  imageName = "wekanteam/wekan";
  imageDigest = "sha256:2f8b87739ae12893835e90981de8a368e7884f867612bc60f9c2e764b62a1453";
  sha256 = "160f3yccmj67pn7azx3hzjikqvipwhngirx5yj4x9gkwysrmcah1";
  finalImageName = "wekan";
  finalImageTag = "4.90";
}
