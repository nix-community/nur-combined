{ pkgs, fetchFromGitHub, ... }:
with pkgs.python3Packages;
buildPythonApplication rec {
    name = "airsensor-py-${version}";
    version = "2017-12-05";
    propagatedBuildInputs = [
      pyusb
      click
    ];

    src = fetchFromGitHub {
      owner = "makefu";
      repo = "airsensor-py";
      rev = "7ac5f185dc848fca1b556e4c0396dd73f6a93995";
      sha256 = "0387b025y8kb0zml7916p70hmzc3y18kqh46b9xv5qayljxymq2w";
    };
}
