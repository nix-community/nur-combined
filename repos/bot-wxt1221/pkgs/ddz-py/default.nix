{
  python3Packages,
  fetchFromGitHub,
  lib,
  writeText,
  bash,
}:

python3Packages.buildPythonApplication rec {
  pname = "ddz_py";
  version = "0-unstable-2025-01-27";

  format = "other";

  src = fetchFromGitHub {
    owner = "EarthMessenger";
    repo = "ddz_py";
    rev = "b6e044876182980dd59d4d5bdec74268efa0731b";
    hash = "sha256-+DGSad2WTYUKPurMA/ritf4Bk861oHVgqVmvq9QQ0As=";
  };

  client_deluxe = writeText "a.sh" ''
    #! ${lib.getExe bash}
    python -m ddz_py.client_deluxe "$@"
  '';

  client_vanilla = writeText "a.sh" ''
    #! ${lib.getExe bash}
    python -m ddz_py.client_vanilla "$@"
  '';

  server = writeText "a.sh" ''
    #! ${lib.getExe bash}
    python -m ddz_py.server "$@"
  '';

  dependencies = with python3Packages; [
    colorama
    prompt-toolkit
    wcwidth
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${python3Packages.python.sitePackages}/ddz_py
    cp -r ${src}/ddz_py/* $out/${python3Packages.python.sitePackages}/ddz_py

    install -Dm755 ${client_deluxe} $out/bin/ddz_client_deluxe
    install -Dm755 ${client_vanilla} $out/bin/ddz_client_vanilla
    install -Dm755 ${server} $out/bin/ddz_server

    wrapProgram "$out/bin/ddz_client_vanilla" \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3Packages.python.sitePackages}" \
      --prefix PATH : "${python3Packages.python}/bin"

    wrapProgram "$out/bin/ddz_client_deluxe" \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3Packages.python.sitePackages}" \
      --prefix PATH : "${python3Packages.python}/bin"

    wrapProgram "$out/bin/ddz_server" \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3Packages.python.sitePackages}" \
      --prefix PATH : "${python3Packages.python}/bin"

    runHook postInstall
  '';

  pythonImportsCheck = [
    "ddz_py"
    "ddz_py.client_deluxe"
    "ddz_py.client_vanilla"
    "ddz_py.server"
  ];

  meta = {
    license = lib.licenses.free;
    homepage = "https://github.com/EarthMessenger/ddz_py";
    mainProgram = "ddz_client_deluxe";
    description = "ddz CLI game";
  };
}
