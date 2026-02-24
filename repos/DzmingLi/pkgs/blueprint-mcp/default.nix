{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
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

  # Patch extensionServer.js to support WSS (TLS) via environment variables.
  # When BLUEPRINT_WSS_CERT and BLUEPRINT_WSS_KEY are set, the server uses
  # https.createServer instead of http.createServer, enabling wss:// connections
  # required by Firefox MV3 extensions (which upgrade ws:// to wss://).
  postPatch = ''
    substituteInPlace src/extensionServer.js \
      --replace-fail \
        "const http = require('http');" \
        "const http = require('http');
const https = require('https');
const fs = require('fs');" \
      --replace-fail \
        "this._httpServer = http.createServer((req, res) => {
        res.writeHead(200);
        res.end('Extension WebSocket Server');
      });" \
        "const certPath = process.env.BLUEPRINT_WSS_CERT;
      const keyPath = process.env.BLUEPRINT_WSS_KEY;
      if (certPath && keyPath) {
        const tlsOptions = {
          cert: fs.readFileSync(certPath),
          key: fs.readFileSync(keyPath),
        };
        this._httpServer = https.createServer(tlsOptions, (req, res) => {
          res.writeHead(200);
          res.end('Extension WebSocket Server (WSS)');
        });
        debugLog('Using WSS (TLS) mode');
      } else {
        this._httpServer = http.createServer((req, res) => {
          res.writeHead(200);
          res.end('Extension WebSocket Server');
        });
      }"
  '';

  meta = with lib; {
    description = "MCP server for browser automation using real browser profiles";
    homepage = "https://github.com/railsblueprint/blueprint-mcp";
    license = licenses.asl20;
    mainProgram = "blueprint-mcp";
  };
}
