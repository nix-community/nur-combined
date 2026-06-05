{
  python3,
  static-nix-shell,
}:
static-nix-shell.mkPython3 {
  pname = "nanogpt-api";
  srcRoot = ./.;
  pkgs = {
    "python3.pkgs.pydantic" = python3.pkgs.pydantic;
    "python3.pkgs.pygobject3" = python3.pkgs.pygobject3;
    "python3.pkgs.requests" = python3.pkgs.requests;
  };
  meta = {
    description = "CLI access interface to nano-gpt.com LLM provider";
    homepage = "https://docs.nano-gpt.com/api-reference";
  };
}
