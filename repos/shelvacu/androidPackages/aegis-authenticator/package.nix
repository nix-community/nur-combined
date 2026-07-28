{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  protobuf,
}:
buildGradleAndroidPackage rec {
  pname = "aegis-authenticator";
  version = "3.4.1";
  applicationId = "com.beemdevelopment.aegis";

  src = fetchFromGitHub {
    owner = "beemdevelopment";
    repo = "aegis";
    tag = "v${version}";
    hash = "sha256-XoXFsHUnEtXs7WpgsTr48oO/njYk8nRchDXB9AegUlg=";
  };

  postPatch = ''
    sed -i 's/def getGitHash .*/def getGitHash = { -> return "unknown" }/' app/build.gradle
    sed -i 's/def getGitBranch .*/def getGitBranch = { -> return "${src.tag}" }/' app/build.gradle
    sed -i 's/artifact = .com.google.protobuf.*/path = System.getenv("PROTOC_BIN")/' app/build.gradle
  '';

  env = {
    PROTOC_BIN = "${protobuf}/bin/protoc";
  };

  sdkVersions = [ "35" ];

  lockFile = ./gradle.lock;
}
