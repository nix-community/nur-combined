{ fetchFromGitHub }:

rec {
  version = "3.23.1";
  src = fetchFromGitHub {
    owner = "DeterminateSystems";
    repo = "nix-src";
    tag = "v${version}";
    hash = "sha256-fuoqgE/DZMDByEYZyoOBNUxbf/JUMy2VLT8mFcYe0Fc=";
  };
}
