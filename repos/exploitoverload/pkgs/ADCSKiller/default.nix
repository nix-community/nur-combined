{ lib, fetchFromGitHub, python3 }:

let pyenv = python3.withPackages (pp: with pp; [
  ldap3
]);

in 

python3.pkgs.buildPythonApplication rec {
  pname = "ADCSKiller";
  version = "d74bfea91f24a09df74262998d60f213609b45c6";
  format = "other";
  src = fetchFromGitHub {
    owner = "grimlockx";
    repo = "ADCSKiller";
    rev = "d74bfea91f24a09df74262998d60f213609b45c6";
    hash = "sha256-ekyGDM9up3h6h21uLEstgn33x+KngX4tOLMhL4B6BA8=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    ldap3
  ];
  doCheck = false;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share/${pname}

    cp -r . $out/share/${pname}

    makeWrapper ${pyenv.interpreter} $out/bin/${pname} --add-flags "$out/share/${pname}/adcskiller.py"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ADCSKiller is a Python-based tool designed to automate the process of discovering and exploiting Active Directory Certificate Services (ADCS) vulnerabilities. It leverages features of Certipy and Coercer to simplify the process of attacking ADCS infrastructure.";
    homepage = "https://github.com/grimlockx/ADCSKiller";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
