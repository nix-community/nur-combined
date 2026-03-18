{
  bun,
  cacert,
  fetchFromGitHub,
  lib,
  stdenvNoCC,
}: let
  pname = "mcp-cli";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "philschmid";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-S924rqlVKzUFD63NDyK5bbXnonra+/UoH6j78AAj3d0=";
  };

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node-modules";
    inherit version src;

    impureEnvVars =
      lib.fetchers.proxyImpureEnvVars
      ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

    nativeBuildInputs = [
      bun
      cacert
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      bun install --frozen-lockfile --ignore-scripts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/

      runHook postInstall
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-BgCPeb8ZjO7SiJPkiAbWRi+bbsUdzzIwbBvnHoufviM=";
  };
in
  stdenvNoCC.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      bun
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR
      cp -r ${node_modules}/node_modules .
      chmod -R u+w node_modules

      bun build --compile --minify src/index.ts --outfile dist/${pname}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 dist/${pname} $out/bin/${pname}

      runHook postInstall
    '';

    dontFixup = true;

    meta = with lib; {
      description = "Lightweight CLI to interact with MCP servers";
      homepage = "https://github.com/philschmid/mcp-cli";
      license = with licenses; [mit];
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [fromSource];
      mainProgram = pname;
    };
  }
