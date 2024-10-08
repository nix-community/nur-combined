{ fetchFromGitHub
, pkgs
}:

pkgs.guilt.overrideAttrs {
  version = "0.37-rc1-freddy77-20241004";
  src = fetchFromGitHub {
    owner = "freddy77";
    repo = "guilt";
    rev = "4aee8307db7cba0ac6af038bfb04e86d9c85fa0a";
    sha256 = "sha256-88vjP/29NF4qQnqVDMtQhBo5siNNolBBfIgSlMFQUXo=";
  };
}
