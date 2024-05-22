{
  lib,
  buildGoModule,
  fetchFromGitHub,
  alist,
  testers,
  fuse,
  fetchurl,
  go,
}:
buildGoModule rec {
  pname = "alist";
  version = "3.34.0";

  src = fetchFromGitHub {
    owner = "alist-org";
    repo = "alist";
    rev = "v${version}";
    hash = "sha256-LHkUqOpZk8GZPUis+oX077w8LY7lLwrLu4AO/NvLVeg=";
  };

  CGO_ENABLED = 1;

  vendorHash = "sha256-1VZwBbpc1dH7kyCAAcidY8phIKTwZBJNH1TIdIWqiyc=";

  web = fetchurl {
    url = "https://github.com/alist-org/alist-web/releases/download/${version}/dist.tar.gz";
    hash = "sha256-gqY0wg34iwzjhdAp0KI6gEe4JSc2IdCMJ2Iy+zMJRCw=";
  };

  buildInputs = [ fuse ];
  tags = [ "jsoniter" ];

  ldflags = [
    "-s"
    "-w"
    "-X \"github.com/alist-org/alist/v3/internal/conf.GitAuthor=Xhofe <i@nn.ci>\""
    # time should not be used as the input for nix, instead use "Nix" as a placeholder.
    "-X github.com/alist-org/alist/v3/internal/conf.BuiltAt=Nix"
    "-X github.com/alist-org/alist/v3/internal/conf.GoVersion=${go.version}"
    "-X github.com/alist-org/alist/v3/internal/conf.GitCommit=${version}"
    "-X github.com/alist-org/alist/v3/internal/conf.Version=${version}"
    "-X github.com/alist-org/alist/v3/internal/conf.WebVersion=${version}"
  ];

  preConfigure = ''
    # wait for https://github.com/alist-org/alist/pull/6422 to merge
    sed -z -i 's/setupStorages(t)//2' internal/op/storage_test.go

    # build sandbox do not provide network
    rm pkg/aria2/rpc/client_test.go pkg/aria2/rpc/call_test.go

    # use matched web files
    rm -rf public/dist
    cp ${web} dist.tar.gz
    tar -xzf dist.tar.gz
    mv -f dist public
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = alist;
      command = "${alist}/bin/alist version";
    };
  };

  meta = with lib; {
    description = "A file list/WebDAV program that supports multiple storages";
    homepage = "https://github.com/alist-org/alist";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ moraxyc ];
    mainProgram = "alist";
  };
}
