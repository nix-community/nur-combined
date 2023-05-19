{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "logseq-doctor";
  version = "0.1.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "andreoliwa";
    repo = "logseq-doctor";
    rev = "v${version}";
    hash = "sha256-/fejxDUAUuk4gSy7Q56k0Zk0H5NT46vCO37N8Rnb6/s=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    mistletoe
  ];

  postInstall = ''
    mv $out/bin/lsd $out/bin/logseq-doctor
  '';

  meta = with lib; {
    description = "Heal your Markdown files: convert to outline, list tasks and more tools to come";
    homepage = "https://github.com/andreoliwa/logseq-doctor";
    changelog = "https://github.com/andreoliwa/logseq-doctor/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ meain ];
  };
}

