{
  cmake,
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "rindex";
  version = "0-unstable-2025-11-11";

  src = fetchFromGitHub {
    owner = "wenxuanjun";
    repo = "rindex";
    rev = "f6fcffeb9a5dec7bfe5bd80d2cded9e0d9646d49";
    hash = "sha256-Qn0sfCUdx8acjNmaT2Rg1Sp6OE/+LEoRRqq1qLm5MEQ=";
  };

  cargoHash = "sha256-543V+xY+27Cmsb8hEGzc8WN/Lxmpg+df0IposjNyTsY=";

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Fast Indexer compatible with nginx's autoindex module";
    homepage = "https://github.com/wenxuanjun/rindex";
    license = lib.licenses.gpl3;
    mainProgram = "rindex";
    maintainers = with lib.maintainers; [ prince213 ];
  };
}
