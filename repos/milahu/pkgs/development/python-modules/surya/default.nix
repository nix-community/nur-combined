{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "surya";
  version = "0.17.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "datalab-to";
    repo = "surya";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VzugHhR4di+WCfiZDbiNJ+kA6lkAjjcWZV/4oG0sjxs=";
  };

  postPatch = ''
    sed -i -E 's/([a-z0-9])(==|>=)[0-9.]+(,<[0-9.]+)?"/\1"/; s/"(=|==|>=|\^)[0-9.]+(,<[0-9.]+)?"/"*"/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    click
    einops
    filetype
    opencv-python-headless
    pillow
    platformdirs
    pre-commit
    pydantic
    pydantic-settings
    pypdfium2
    python-dotenv
    torch
    transformers
  ];

  pythonImportsCheck = [
    "surya"
  ];

  # doCheck = false; # no effect
  dontUsePytestCheck = true;

  meta = {
    description = "OCR, layout analysis, reading order, table recognition in 90+ languages";
    homepage = "https://github.com/datalab-to/surya";
    license = with lib.licenses; [
      gpl3Only
      gpl3Plus
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "surya";
  };
})
