{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "vtt2clean-srt";
  version = "2022.02.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "vtt2clean_srt";
    # https://github.com/shironoY6/vtt2clean_srt/pull/1
    rev = "f7fe1aa426c1b65764613e5934a8363bad367293";
    hash = "sha256-/CY/H8sz7Ggr2Y+HhtXF4rbFMC25LJo8KgK7zBayUfA=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
  ];

  propagatedBuildInputs = with python3.pkgs; [
    webvtt-py
  ];

  #pythonImportsCheck = [ "vtt2clean_srt" ];

  meta = with lib; {
    description = "convert vtt to srt subtitles without duplicate lines";
    homepage = "https://github.com/shironoY6/vtt2clean_srt";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "vtt2clean_srt";
  };
}
