{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "nix-daemon-proxy-client";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "yueyinqiu";
    repo = "NixDaemonProxy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Wpe3JKdxEwuXulPUYKxMJv6r1wHoBXKC+1KQZnS7NNo=";
  };

  projectFile = "src/NixDaemonProxy.Client/NixDaemonProxy.Client.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  nugetDeps = ./deps.json;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "An on-the-fly switchable HTTP/HTTPS/SOCKS5 proxy for the Nix daemon";
    homepage = "https://github.com/yueyinqiu/NixDaemonProxy";
    license = lib.licenses.mit;
    mainProgram = "NixDaemonProxy.Client";
    maintainers = [ ];
  };
})
