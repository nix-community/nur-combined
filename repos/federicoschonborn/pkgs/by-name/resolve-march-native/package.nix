{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
}:

let
  version = "5.1.0";
in

python3.pkgs.buildPythonApplication {
  pname = "resolve-march-native";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hartwork";
    repo = "resolve-march-native";
    rev = version;
    hash = "sha256-02d7ip5E/vkOMkkeHOx1m7FdpurXT9O6HdwrygNPHdY=";
  };

  build-system = [ python3.pkgs.setuptools ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/resolve-march-native \
      --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}
  '';

  pythonImportsCheck = [ "resolve_march_native" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "resolve-march-native";
    description = "Tool to determine what GCC flags -march=native would resolve into";
    homepage = "https://github.com/hartwork/resolve-march-native";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
