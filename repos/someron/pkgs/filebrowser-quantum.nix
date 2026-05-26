{
  stdenv, lib,
  buildGoModule, buildNpmPackage, importNpmLock,
  musl,
  fetchFromGitHub,
}:
let
  version = "v1.3.3-stable";
  commitHash = "28e9b81e438e65e1af2979d4a7e66f1a433fe720";
  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    tag = version;
    hash = "sha256-Q4TtC5x/nAbeZzICH9R9LBqe/8tbQOFR8vAImhQ5sYM=";
  };
  frontend = buildNpmPackage {
    name = "filebrowser-quantum-frontend";
    version = version;
    src = src + "/frontend";

    npmBuildScript = "build:docker";

    npmDeps = importNpmLock {
      package = builtins.fromJSON (builtins.readFile (src + "/frontend/package.json"));
      packageLock = builtins.fromJSON (builtins.readFile (src + "/frontend/package-lock.json"));
      pname = "filebrowser-quantum-frontend-deps";
      version = version;
    };

    npmConfigHook = importNpmLock.npmConfigHook;
  };
  backendSources = stdenv.mkDerivation {
    pname = "filebrowser-quantum-backend-sources";
    version = version;

    src = src + "/backend";

    buildPhase = ''
      mkdir -p $out

      cp -r --no-preserve=mode,ownership $src/* $out/
      unlink $out/preview/testdata
      cp -r --no-preserve=mode,ownership ${frontend}/lib/node_modules/filebrowser-frontend/dist/* $out/http/embed/
    '';
  };
in
buildGoModule {
  src = backendSources;
  name = "filebrowser-quantum";
  version = version;

  meta = {
    description = "📂 Web File Browser";
    homepage = "https://github.com/gtsteffaniak/filebrowser";
    license = lib.licenses.asl20; # Apache License 2.0
    mainProgram = "backend";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  nativeBuildInputs = [musl];

  ldflags = [
    "-w -s
      -X 'github.com/gtsteffaniak/filebrowser/backend/common/version.Version=${version}'
      -X 'github.com/gtsteffaniak/filebrowser/backend/common/version.CommitSHA=${commitHash}'"
  ];

  doCheck = false;

  vendorHash = "sha256-Fq5FqsZ4m5j+UIn1RsElhNUb4guwI9wo48SjQdvESRU=";
}