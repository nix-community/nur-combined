{
  lib,
  stdenvNoCC,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  cacert,
}:

let
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "omniwaifu";
    repo = "taskwarrior-mcp";
    rev = "v${version}";
    hash = "sha256-JzeJJUWIDHkiZ8IsGz104j9Cd4xpgTE26WZaAoQEnZo=";
  };

  # FOD: 在 Nix 中从 package.json 生成 package-lock.json
  packageLock = stdenvNoCC.mkDerivation {
    name = "taskwarrior-mcp-package-lock-${version}";
    inherit src;
    nativeBuildInputs = [
      nodejs
      cacert
    ];
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    buildPhase = ''
      export HOME=$TMPDIR
      npm install --package-lock-only --ignore-scripts
    '';
    installPhase = ''
      cp package-lock.json $out
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = "sha256-VzKHRGU0hastid1g40WgY5Jz7QCo2QovJ09dRclspMU=";
  };
in
buildNpmPackage {
  pname = "taskwarrior-mcp";
  inherit version src;

  postPatch = ''
    cp ${packageLock} package-lock.json
    substituteInPlace package.json \
      --replace-fail ' && shx chmod +x dist/*.js' ""
  '';

  npmDepsHash = "sha256-x5MEKVjt3jx9B6MChQvkGxmnv8/eBfKF36D3p5x0pyA=";
  npmFlags = [ "--ignore-scripts" ];
  npmBuildScript = "build";

  meta = with lib; {
    description = "MCP Server for TaskWarrior / GTD Tools";
    homepage = "https://github.com/omniwaifu/taskwarrior-mcp";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
