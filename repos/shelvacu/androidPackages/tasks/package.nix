{
  fetchurl,
  fetchFromGitHub,
  gradle_8,
  buildGradleAndroidPackage,
  protobuf,
}:
let
  extraLockData = {
    "io.grpc:protoc-gen-grpc-kotlin:1.3.0" = {
      "protoc-gen-grpc-kotlin-1.3.0.pom" = {
        url = "https://repo.maven.apache.org/maven2/io/grpc/protoc-gen-grpc-kotlin/1.3.0/protoc-gen-grpc-kotlin-1.3.0.pom";
        hash = "sha256-Q9Agt6ECTbSzeWR+u+CI5hnZO0sXry/a7mmaohceHm4=";
      };
      "protoc-gen-grpc-kotlin-1.3.0-jdk8.jar" = {
        url = "https://repo.maven.apache.org/maven2/io/grpc/protoc-gen-grpc-kotlin/1.3.0/protoc-gen-grpc-kotlin-1.3.0-jdk8.jar";
        hash = "sha256-DXr0ZCnfrrpo2kd4kyb+OO6BlC0SQ94vUpB2jnSvKEA=";
      };
    };
    "com.google:google:1" = {
      "google-1.pom" = {
        url = "https://repo.maven.apache.org/maven2/com/google/google/1/google-1.pom";
        hash = "sha256-zW2xehGjHt55TMvR3w5Nl1D2QCNHMfIc/4hamZcnfoE=";
      };
    };
    "com.google:google:5" = {
      "google-5.pom" = {
        url = "https://repo.maven.apache.org/maven2/com/google/google/5/google-5.pom";
        hash = "sha256-4J00XnPKP7yn8+BfMN63Tp053Wt5qT/ujFEfI0F7aCg=";
      };
    };
  };

  protoc-gen-javalite = fetchurl rec {
    pname = "protoc-gen-javalite";
    version = "3.0.0";
    url = "https://repo.maven.apache.org/maven2/com/google/protobuf/${pname}/${version}/${pname}-${version}-linux-x86_64.exe";
    executable = true;
    hash = "sha256-x+5YYK4FbCachiJkrMK5pI44KhPpLtJbI/wRzPtwqRM=";
  };
in
buildGradleAndroidPackage rec {
  pname = "tasks";
  version = "14.8.5";
  applicationId = "org.tasks";

  src = fetchFromGitHub {
    owner = "tasks";
    repo = "tasks";
    tag = version;
    hash = "sha256-0zSVxn3DrPHXn4C2UD5tZJzgk2c5GUFjYKOmTlWDdWI=";
  };

  patches = [
    ./no-donate.patch
    ./no-signing.patch
    ./grpc-fix.patch
  ];

  gradle = gradle_8;

  strictDeps = true;

  env = {
    PROTOC_GEN_JAVALITE_BIN = protoc-gen-javalite;
    PROTOC_BIN = "${protobuf}/bin/protoc";
  };

  sdkVersions = [
    "34"
    "35"
    "36"
  ];

  lockFile = ./gradle.lock;
  inherit extraLockData;

  gradleBuildTask = ":app:assembleGenericRelease";
}
