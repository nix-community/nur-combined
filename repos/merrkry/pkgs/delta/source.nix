{ fetchFromGitHub }:

rec {
  version = "0.23.0";
  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "delta-nix";
    tag = "v${version}";
    hash = "sha256-AEn+sidGsd0GVcnTZVKDxYiKZeEoqmA+aIQPUIFfnAQ=";
  };
}
