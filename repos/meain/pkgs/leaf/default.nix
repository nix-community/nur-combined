{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "leaf";
  version = "1.26.1";

  src = fetchFromGitHub {
    owner = "RivoLink";
    repo = "leaf";
    rev = version;
    hash = "sha256-faZ3yiAdPbN1Pxf7Gss62eYUJzaJ3ZF5BZyCVqHOC4s=";
  };

  cargoHash = "sha256-evHpyavHLJxStN8ZYDetwzxh18eQX9Nq3KL3kudk7dI=";

  meta = {
    description = "Terminal Markdown previewer — GUI-like experience";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    mainProgram = "leaf";
  };
}
