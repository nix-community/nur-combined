{
  stdenv, lib,
  buildGoModule, buildNpmPackage, importNpmLock,
  musl,
  fetchFromGitHub,
}:
let
  version = "v1.1.2-stable";
  commitHash = "207bc39bf7fde64c81c502309881268adb41de8d";
  src = fetchFromGitHub {
    owner = "gtsteffaniak";
    repo = "filebrowser";
    tag = version;
    hash = "sha256-WUYfl4mUyAK5Z+Yjrde0qmLBVh/JZslIk/oBVAF3lgk=";
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

  vendorHash = "sha256-j7zNwkW9EBzmzVLmENTkmxSaokdxsTxdI3CkTEMhnG4=";
}