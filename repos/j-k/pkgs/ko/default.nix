{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "ko";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "google";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-r07bFFDBB7pFcVpfaHeuE8dqE+SwLQRzY2bpoZyxwFU=";
  };

  vendorSha256 = null;

  # Don't build the legacy main.go and test binary
  excludedPackages = "\\(cmd/ko\\|test\\)";

  nativeBuildInputs = [ installShellFiles ];

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w -X github.com/google/ko/pkg/commands.Version=${version}")
  '';

  preCheck = ''
    export GOROOT=$(go env GOROOT)
  '';

  postInstall = ''
    installShellCompletion --cmd ko \
      --bash <($out/bin/ko completion) \
      --zsh <($out/bin/ko completion --zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/ko --help
    $out/bin/ko version | grep "${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/google/ko";
    changelog = "https://github.com/google/ko/releases/tag/v${version}";
    description = "Build and deploy Go applications on Kubernetes";
    longDescription = ''
      ko is a simple, fast container image builder for Go applications.
      It's ideal for use cases where your image contains a single Go application without any/many dependencies on the OS base image (e.g. no cgo, no OS package dependencies).
      ko builds images by effectively executing go build on your local machine, and as such doesn't require docker to be installed. This can make it a good fit for lightweight CI/CD use cases.
      ko also includes support for simple YAML templating which makes it a powerful tool for Kubernetes applications.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
