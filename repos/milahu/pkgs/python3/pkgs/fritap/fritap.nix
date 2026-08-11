{ lib
, python3
, fetchFromGitHub
, frida-tools
}:

python3.pkgs.buildPythonApplication rec {
  pname = "fritap";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fkie-cad";
    repo = "friTap";
    rev = "v${version}";
    hash = "sha256-s1lCOo04KI6FZ6x66NPTF7hAehr4WRB4+0OVv8dKodc=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = (with python3.pkgs; [
    click
    #frida
    frida-python # TODO rename to frida
    hexdump
    scapy
    watchdog
  ]) ++ [
    frida-tools
  ];

  # TODO lowercase?
  #pythonImportsCheck = [ "fritap" ];
  pythonImportsCheck = [ "friTap" ];

  meta = with lib; {
    description = "analyze traffic encapsulated in SSL or TLS";
    homepage = "https://github.com/fkie-cad/friTap";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    # TODO lowercase?
    #mainProgram = "fritap";
    mainProgram = "friTap";
  };
}
