{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "listparser";
  version = "0.20";

  src = fetchFromGitHub {
    owner = "kurtmckee";
    repo = "listparser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eg9TrjDgvHsYt/0JQ7MK/uGc3KK3uGr3jRxzG0FlySg=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
  ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    lxml
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "listparser"
  ];

  doCheck = true;
  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Parse OPML subscription lists in Python";
    homepage = "https://github.com/kurtmckee/listparser";
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.colinsane ];
    platforms = platforms.linux;
  };
})
