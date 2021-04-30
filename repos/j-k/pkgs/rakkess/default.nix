{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "rakkess";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "corneliusweig";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-PN6YNrYd9kPtz9umIoZPMAcLwOwVDVecvulmWGFddGI=";
  };

  vendorSha256 = "sha256-oY/6gppCi1wNxh6JEn4JgDL7e6ut0xSKf0jar9cJMCo=";

  nativeBuildInputs = [ installShellFiles ];

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w -X github.com/corneliusweig/rakkess/internal/version.version=v${version}")
  '';

  postInstall = ''
    installShellCompletion --cmd rakkess \
      --bash <($out/bin/rakkess completion bash) \
      --zsh <($out/bin/rakkess completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/rakkess --help
    $out/bin/rakkess version | grep "v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/corneliusweig/rakkess";
    changelog = "https://github.com/corneliusweig/rakkess/releases/tag/v${version}";
    description = "Review Access - kubectl plugin to show an access matrix for k8s server resources";
    longDescription = ''
      Have you ever wondered what access rights you have on a provided kubernetes cluster? For single resources you can
      use `kubectl auth can-i list deployments`, but maybe you are looking for a complete overview? This is what rakkess
      is for. It lists access rights for the current user and all server resources, similar to
      `kubectl auth can-i --list`.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
