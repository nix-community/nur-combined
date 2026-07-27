{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "clinvk";
  version = "0.1.0-alpha";

  src = fetchFromGitHub {
    owner = "signalridge";
    repo = "clinvoker";
    rev = "v${version}";
    hash = "sha256-qjm6Npm/Zg5QwuU/HxsY6jIDxGxNoydzc0kZqX3owlA=";
  };

  vendorHash = "sha256-mVSH+lVn6NavaScayx2DEgnKbRV1nC5LansdCwABV/k=";

  # Tests require writable home directory, skip in sandbox
  doCheck = false;

  ldflags = [
    "-s" "-w"
    "-X github.com/signalridge/clinvoker/internal/app.version=${version}"
  ];

  meta = with lib; {
    description = "Unified AI CLI wrapper for multiple backends (Claude, Codex, Gemini)";
    homepage = "https://github.com/signalridge/clinvoker";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "clinvk";
  };
}
