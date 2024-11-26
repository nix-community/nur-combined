{
  lib,
  writeText,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
}:

let
  attrsToPlugins =
    attrs:
    builtins.map (
      {
        name,
        repo,
        version,
      }:
      "${name}:${repo}"
    ) attrs;
  attrsToSources =
    attrs:
    builtins.map (
      {
        name,
        repo,
        version,
      }:
      "${repo}@${version}"
    ) attrs;

  # pluginConfig = writeText "plugin.cfg" ''
  #   prometheus:metrics
  #   errors:errors
  #   log:log
  #   template:template
  #   alternate:github.com/coredns/alternate
  #   forward:forward
  # '';

  pluginConfig = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/kumahq/coredns-builds/refs/heads/main/plugin.cfg";
    sha256 = "0diymh527vbpl40kc1f9qbqzz1dzz2m4wf9lq8v99i5w3z602s25";
  };

  externalPlugins = [
    {
      name = "alternate";
      repo = "github.com/coredns/alternate";
      version = "v0.2.12";
    }
  ];

in
buildGoModule rec {
  pname = "coredns";
  version = "1.11.4";

  src = fetchFromGitHub {
    owner = "coredns";
    repo = "coredns";
    rev = "v${version}";
    sha256 = "sha256-se9wSgfAPzIvR7e3e7J6G6bqzxgtIG6td7OuMsdlXcw=";
  };

  vendorHash = "sha256-fhmsryTWni69r3Z9wgABd03PWM9LKhJ0/vVPJzp04Ys=";

  nativeBuildInputs = [ installShellFiles ];

  outputs = [ "out" ];

  modBuildPhase = ''
    cp ${pluginConfig} plugin.cfg;
    for src in ${builtins.toString (attrsToSources externalPlugins)}; do go get $src; done
    GOOS= GOARCH= go generate
    go mod vendor
  '';

  modInstallPhase = ''
    mv -t vendor go.mod go.sum plugin.cfg
    cp -r --reflink=auto vendor "$out"
  '';

  preBuild = ''
    chmod -R u+w vendor
    mv -t . vendor/go.{mod,sum} vendor/plugin.cfg

    GOOS= GOARCH= go generate
  '';

  doCheck = false;

  meta = with lib; {
    homepage = "https://coredns.io";
    description = "A DNS server that runs middleware";
    mainProgram = "coredns";
    license = licenses.asl20;
    maintainers = with maintainers; [
      rushmorem
      rtreffer
      deltaevo
    ];
  };
}
