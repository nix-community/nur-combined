{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nixosTests,
  caddy,
  testers,
  installShellFiles,
}:
let
  version = "2.7.6";
  dist = fetchFromGitHub {
    owner = "caddyserver";
    repo = "dist";
    rev = "v${version}";
    hash = "sha256-aZ7hdAZJH1PvrX9GQLzLquzzZG3LZSKOvt7sWQhTiR8=";
  };
in
buildGoModule {
  pname = "caddy";
  version = "naive";

  src = fetchFromGitHub {
    owner = "oluceps";
    repo = "caddy";
    rev = "e7b3f114e736e28b99f600c6c2a7bdb490653597";
    hash = "sha256-bZzdrbcVeqJB6ORbKZhS090SXKD1utH1qGhpsaw+CLM=";
  };

  vendorHash = "sha256-ZJQe3JIHJCttEmPCAYjH+hJl/SbFnheKwohR7C+A+ms=";

  subPackages = [ "cmd/caddy" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/caddyserver/caddy/v2.CustomVersion=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

    substituteInPlace $out/lib/systemd/system/caddy.service --replace "/usr/bin/caddy" "$out/bin/caddy"
    substituteInPlace $out/lib/systemd/system/caddy-api.service --replace "/usr/bin/caddy" "$out/bin/caddy"

    $out/bin/caddy manpage --directory manpages
    installManPage manpages/*

    installShellCompletion --cmd caddy \
      --bash <($out/bin/caddy completion bash) \
      --fish <($out/bin/caddy completion fish) \
      --zsh <($out/bin/caddy completion zsh)
  '';

  passthru.tests = {
    inherit (nixosTests) caddy;
    version = testers.testVersion {
      command = "${caddy}/bin/caddy version";
      package = caddy;
    };
  };

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = licenses.asl20;
    mainProgram = "caddy";
    maintainers = with maintainers; [
      Br1ght0ne
      emilylange
      techknowlogick
    ];
  };
}
