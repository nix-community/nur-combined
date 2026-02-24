{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  openssl,
}:

let
  version = "1.9.21";
in
buildNpmPackage rec {
  pname = "blueprint-mcp";
  inherit version;

  src = fetchFromGitHub {
    owner = "railsblueprint";
    repo = "blueprint-mcp";
    rev = "v${version}";
    sha256 = "sha256-TLAYKJT2QYNPDuMdgGVRnCgoT80Yz/MDNYkU4MCE/Js=";
  };

  sourceRoot = "${src.name}/server";

  npmDepsHash = "sha256-Evgt+WhAEMBXVXaaGWwVKYlTMTfesZ91IFuZTw+Tfwc=";

  dontNpmBuild = true;

  # The postinstall script is just a console.log message
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ openssl ];

  # Patch extensionServer.js to use HTTPS/WSS for Firefox HTTPS-First compatibility
  postPatch = ''
    substituteInPlace src/extensionServer.js \
      --replace-fail "const http = require('http');" \
        "const https = require('https'); const fs = require('fs'); const path = require('path');" \
      --replace-fail "this._httpServer = http.createServer((req, res) => {" \
        "const __key = fs.readFileSync(path.join(__dirname, 'localhost-key.pem')); const __cert = fs.readFileSync(path.join(__dirname, 'localhost-cert.pem')); this._httpServer = https.createServer({ key: __key, cert: __cert }, (req, res) => {"
  '';

  preInstall = ''
    openssl req -x509 -newkey rsa:2048 \
      -keyout src/localhost-key.pem \
      -out src/localhost-cert.pem \
      -days 3650 -nodes \
      -subj '/CN=127.0.0.1' \
      -addext 'subjectAltName=IP:127.0.0.1' 2>/dev/null
  '';

  meta = with lib; {
    description = "MCP server for browser automation using real browser profiles";
    homepage = "https://github.com/railsblueprint/blueprint-mcp";
    license = licenses.asl20;
    mainProgram = "blueprint-mcp";
  };
}
