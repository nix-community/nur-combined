{
  lib,
  buildGoModule,
  fetchFromGitHub,
  protobuf, protoc-gen-go, protoc-gen-go-grpc, grpc-gateway, buildNpmPackage
}:

let
  pname = "olivetin";
  version = "2024.12.11";

  src = fetchFromGitHub {
    owner = "OliveTin";
    repo = "OliveTin";
    rev = "10a473ca1cdc3b45120899ed19534f7a8c591e23";
    hash = "sha256-gxC1vzZpKbz7X5gpV8f3Vr6RcyT9SFNoC6PXFYew+fc=";
  };
  googleapis = fetchFromGitHub {
    owner = "googleapis";
    repo = "googleapis";
    rev = "ef8a5429145c241dcb256b0b84fa8e477facc9e1";
    hash = "sha256-K0y7bXf7ehY168WFEHztNzLbh0sf1ZkyVF6A+QgMrRg=";
  };
  webui = buildNpmPackage rec {
    inherit pname version src;

    sourceRoot = "source/webui.dev";
    npmDepsHash = "sha256-VxIPjpsbxEPP15cu5Wvz0qeDGXTMb2tojdry8YaHMVI=";

    buildPhase = ''
      npx parcel build --public-url "."
    '';
  };
in buildGoModule rec {
  inherit pname version src;

  vendorHash = "sha256-NxrN3yUhJlvhFb+5E7KIx4BsM1YOjKZ71XYhAaK+uZY=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];


  nativeBuildInputs = [ protobuf protoc-gen-go protoc-gen-go-grpc grpc-gateway ];

  subPackages = [ "cmd/OliveTin" ];

  preBuild = ''
    protoc -I${googleapis}:. --go_out=. --grpc-gateway_out=. --go-grpc_out=require_unimplemented_servers=false:. OliveTin.proto
    substituteInPlace internal/httpservers/webuiServer.go \
      --replace-fail "../webui/" "$out/webui/"
    substituteInPlace var/helper-actions/olivetin-setup-easy-ssh \
      --replace-fail "/config/ssh/" "/etc/OliveTin/ssh/"
  '';

  postInstall = ''
    install -Dm644 var/manpage/OliveTin.1.gz $out/share/man/man1/OliveTin.1.gz
    install -Dm755 var/helper-actions/olivetin-setup-easy-ssh $out/bin
    mkdir -p $out/webui
    cp ${webui}/lib/node_modules/olivetin-webui/dist/* $out/webui
    cp ${webui}/lib/node_modules/olivetin-webui/*.png $out/webui
  '';

  meta = {
    description = "OliveTin gives safe and simple access to predefined shell commands from a web interface";
    homepage = "https://github.com/OliveTin/OliveTin";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "OliveTin";
  };
}
