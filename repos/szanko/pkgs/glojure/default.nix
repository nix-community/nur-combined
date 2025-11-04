{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "glojure";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "glojurelang";
    repo = "glojure";
    rev = "v${version}";
    hash = "sha256-/eaqKfVFpf4zX+3rve98TfW3SqoniqYIRcRFQwBxMJA=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-AIghWHfWocoY/6Yxu6cEtUmbembRaLtADmNaZiq+JHA=";

  ldflags = [ "-s" "-w" ];
  subPackage = [ "./cmd/glj" ];

  doCheck=false;

  excludedPackages = [
    "./pkg/stdlib/clojure/test"
    "./pkg/runtime/codegengotest"
  ];

  meta = {
    description = "Clojure interpreter hosted on Go, with extensible interop support";
    homepage = "https://github.com/glojurelang/glojure";
    license = lib.licenses.epl10;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "glj";
  };
}
