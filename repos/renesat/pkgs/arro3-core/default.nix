{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  # Deps
}:
buildPythonPackage rec {
  pname = "arro3-core";
  version = "0.4.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "kylebarron";
    repo = "arro3";
    rev = "py-v${version}";
    hash = "sha256-3hqVvb6MAr1Iqtb1kPAuahdmu7pbyLJSb/dtjkcgJbg=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-MYpTT5PqpjBConlOa797wDnAipCYsXpJf8eRdh/c0pI=";
  };

  buildAndTestSubdir = "arro3-core";

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  pythonImportsCheck = ["arro3.core._core"];

  meta = with lib; {
    description = "A minimal Python library for Apache Arrow, binding to the Rust Arrow implementation";
    homepage = "https://github.com/kylebarron/arro3";
    license = with licenses; [
      asl20
      mit
    ];
    maintainers = with maintainers; [renesat];
  };
}
