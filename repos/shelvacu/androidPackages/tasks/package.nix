{
  fetchurl,
  fetchFromGitHub,
  gradle-packages,
  buildGradleAndroidPackage,
  binutils,
  jdk21,
  protobuf,
}:
let
  gradle = gradle-packages.mkGradle {
    version = "9.7.1";
    hash = "sha256-rNU/HtrwLxqP+Zh5+KNLMCZhoFfZsGOunjW1UvgE0go=";
    defaultJava = jdk21;
  };
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
  version = "15.12";
  applicationId = "org.tasks";

  src = fetchFromGitHub {
    owner = "tasks";
    repo = "tasks";
    tag = version;
    hash = "sha256-ah6/xqlgBOKsXk5CJQHvxteihWL+HAMLUj1yqLjwSCE=";
  };

  patches = [
    ./no-donate.patch
    ./no-signing.patch
    ./grpc-fix.patch
  ];

  inherit gradle;
  jdk = jdk21;

  strictDeps = true;

  env = {
    PROTOC_GEN_JAVALITE_BIN = protoc-gen-javalite;
    PROTOC_BIN = "${protobuf}/bin/protoc";
  };

  sdkVersions = [
    "34"
    "35"
    "36"
    "37"
  ];

  lockFile = ./gradle.lock;
  inherit extraLockData;

  gradleBuildTask = ":app:assembleGenericRelease";
  gradleBuildFlags = [ ":composeApp:createDistributable" ];

  nativeBuildInputs = [ binutils ];

  postInstall = ''
    mkdir -p "$out/desktop"
    cp -a composeApp/build/compose/binaries/main/app/tasks-org \
      "$out/desktop/"
    cp graphics/icon.svg "$out/desktop/"
  '';
}
