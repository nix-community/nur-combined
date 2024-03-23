{ python3
, fetchFromGitHub
, lib
}:

python3.pkgs.buildPythonApplication rec {
  pname   = "bitmasher";
  version = "5.74351224532";
  format  = "setuptools";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "BitMasher";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-2jZZOf3vhKVo2JvXQDsW0lpUySTGGTHNbpoxvOwiiiI=";
  };

  meta = with lib; {
    description = "A fast-paced text adventure game inside a ransomware-infected computer";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/BitMasher";
    license     = licenses.mit;
    mainProgram = "bitmasher";
  };
}
