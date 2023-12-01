{ lib
, buildBazelPackage
, fetchFromGitHub
, bazel_6
, nix-update-script
}:

buildBazelPackage rec {
  pname = "protoc-gen-js";
  version = "3.21.2";

  src = fetchFromGitHub {
    owner = "protocolbuffers";
    repo = "protobuf-javascript";
    rev = "refs/tags/v${version}";
    hash = "sha256-TmP6xftUVTD7yML7UEM/DB8bcsL5RFlKPyCpcboD86U=";
  };

  bazel = bazel_6;

  bazelTargets = [ "//generator:protoc-gen-js" ];

  removeRulesCC = false;

  fetchAttrs.sha256 = "sha256-H0zTMCMFct09WdR/mzcs9FcC2OU/ZhGye7GAkx4tGa8=";

  buildAttrs.installPhase = ''
    mkdir -p "$out/bin"
    cp ./bazel-bin/generator/protoc-gen-js "$out/bin"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "JavaScript Protocol Buffers runtime library";
    homepage = "https://github.com/protocolbuffers/protobuf-javascript";
    license = licenses.bsd3;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.all;
  };
}
