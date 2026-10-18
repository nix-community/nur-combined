{
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "HydraStreamer";
  version = "0.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "HydraaLabs";
    repo = "HydraStreamer";
    tag = "v${version}";
    hash = "sha256-yk8RqeYaw0oP3DcRmD8TZmN240bKQnAoNoa7PPLBl/s=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ ];

  meta = {
    description = "Hydracker local HLS streamer for 1Fichier and debrid direct links";
    homepage = "https://github.com/HydraaLabs/HydraStreamer";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
  };
}
