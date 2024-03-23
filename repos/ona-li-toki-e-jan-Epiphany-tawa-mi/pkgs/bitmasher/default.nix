{ python3
, fetchFromGitHub
, lib
}:

python3.pkgs.buildPythonApplication rec {
  pname   = "bitmasher";
  version = "4.3853256532";
  format  = "setuptools";

  # The latest version (0.1.0) has build errors, which were fixed in this
  # commit.
  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "BitMasher";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-VkKQ3h+cOPSdl975VTpML3C36DQBAu7yuS/+KPfCtBk=";
  };

  meta = with lib; {
    description = "A fast-paced text adventure game inside a ransomware-infected computer";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/BitMasher";
    license     = licenses.mit;
    mainProgram = "bitmasher";
  };
}
