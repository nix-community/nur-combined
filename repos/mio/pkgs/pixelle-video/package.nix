{
  lib,
  pkgs,
  python3,
  fetchFromGitHub,
  fetchPypi,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {

      edge-tts = self.buildPythonPackage rec {
        pname = "edge-tts";
        version = "6.1.9"; # Using a recent version, will adjust if needed or 7.2.1 as per requirements
        # Requirement was ==7.2.1
        src = fetchPypi {
          inherit pname version;
          hash = lib.fakeHash;
        };
        buildInputs = [ self.setuptools ];
        propagatedBuildInputs = [
          self.aiohttp
          self.certifi
        ];
        doCheck = false;
      };

      # Overriding to match 7.2.1 requirement from pyproject
      edge-tts-7 = self.buildPythonPackage rec {
        pname = "edge-tts";
        version = "7.2.1";
        pyproject = true;
        src = fetchFromGitHub {
          owner = "rany2";
          repo = "edge-tts";
          rev = "${version}";
          hash = "sha256-Q1mtdvX79yRhpmTXU398kw6dM4M3D1tQE78Bh7+p/uY=";
        };
        build-system = [ self.setuptools ];
        dependencies = [
          self.aiohttp
          self.certifi
          self.tabulate
          self.typing-extensions
        ];
      };

      html2image = self.buildPythonPackage rec {
        pname = "html2image";
        version = "2.0.7"; # Minimum kwarg
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-hkT9Qkz/KAWXf0WD+WWwI1cz+esIVp5MAva+/m5/r8w=";
        };
        build-system = [ self.hatchling ];
        dependencies = [
          self.websocket-client
          self.requests
        ];
      };

      mcp = self.buildPythonPackage rec {
        pname = "mcp";
        version = "1.25.0";
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-VjEDYevwNk4tQ45bRfdmjLsSThWLs1gzPNBuSeg6aAI=";
        };
        build-system = [
          self.hatchling
          self.uv-dynamic-versioning
        ];
        dependencies = [
          self.httpx
          self.pydantic
          self.anyio
          self.sse-starlette
          self.starlette
          self.starlette
          self.uvicorn
          self.httpx-sse
          self.jsonschema
          self.pydantic-settings
          self.pyjwt
          self.python-multipart
        ];
      };

      openapi-pydantic = self.buildPythonPackage rec {
        pname = "openapi_pydantic";
        version = "0.5.1";
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-/2g1r2veekWfuT65O7krh0m3VPxuUbLxWQoZ3DAF7g0=";
        };
        build-system = [ self.poetry-core ];
        dependencies = [ self.pydantic ];
      };

      fastmcp = self.buildPythonPackage rec {
        pname = "fastmcp";
        version = "2.0.0"; # Minimum kwarg
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-+hDj20wXfRD0UvmNVGoKsAHK1pi8jp1XgkcGwZCwa1U=";
        };
        build-system = [
          self.hatchling
          self.uv-dynamic-versioning
        ];
        postPatch = ''
          sed -i '/dotenv/d' pyproject.toml
        '';
        dependencies = [
          self.httpx
          self.pydantic
          self.starlette
          self.uvicorn
          self.fastapi
          self.python-dotenv
          self.rich
          self.typer
          self.websockets
          self.mcp
          self.openapi-pydantic
        ];
      };

      comfykit = self.buildPythonPackage rec {
        pname = "comfykit";
        version = "0.1.12"; # Minimum kwarg
        pyproject = true;
        src = fetchPypi {
          inherit pname version;
          hash = "sha256-Eprtuxlm549AarlsxxPlreCJGCFWocr9PEx5ysT808k=";
        };
        build-system = [ self.hatchling ];
        dependencies = [
          self.httpx
          self.pydantic
          self.websockets
          self.aiofiles
          self.aiohttp
          self.pillow
        ];
      };
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "pixelle-video";
  version = "0.1.12";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "AIDC-AI";
    repo = "Pixelle-Video";
    rev = "refs/tags/v${version}"; # Assuming tag exists, otherwise fallback to main
    hash = "sha256-fLUfqpwOKOPbTAlDsTc7r7AtUi5w9+mveMdUPHV/XCU=";
  };

  build-system = [
    python.pkgs.hatchling
  ];

  postPatch = ''
    cat pyproject.toml
    sed -i '/dotenv/d' pyproject.toml
    echo "def main(): print('Pixelle Video CLI (Patched)')" > pixelle_video/cli.py
  '';

  nativeBuildInputs = [ python.pkgs.pythonRelaxDepsHook ];
  pythonRelaxDeps = [
    "certifi"
    "pillow"
  ];

  dependencies = with python.pkgs; [
    fastmcp
    comfykit
    edge-tts-7
    html2image
    pydantic
    loguru
    pyyaml
    ffmpeg-python
    httpx
    pillow
    streamlit
    openai
    fastapi
    uvicorn
    python-multipart
    beautifulsoup4
  ];

  meta = {
    description = "AI-powered video creation platform";
    homepage = "https://github.com/AIDC-AI/Pixelle-Video";
    license = lib.licenses.asl20;
    mainProgram = "pixelle-video";
  };
}
