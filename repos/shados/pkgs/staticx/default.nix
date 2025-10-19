{
  lib,
  buildPythonApplication,
  runCommand,
  writeBash,
  pins,
  scons,
  musl,
  stdenvNoLibc,
  python,
  setuptools,
  pyelftools,
  makeWrapper,
  glibc,
  binutils,
  patchelf,
}:
let
  muslCross = musl.override { stdenv = stdenvNoLibc; };
  # A hack to work-around the fact that staticx doesn't ensure its temporary
  # copies of the executables/shared objects are actually *writeable* before
  # attempting to patchelf them.
  wrappedPatchElf =
    runCommand "patchelf-chmod"
      {
        nativeBuildInputs = [
          makeWrapper
        ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper \
          ${lib.escapeShellArg (lib.getExe patchelf)} $out/bin/patchelf \
          --run '${chmodAbsPaths} "$@"'

      '';
  chmodAbsPaths = writeBash "chmod-abs-paths" ''
    for arg in "$@"; do
      if [[ $arg == /* ]]; then
        chmod u+w "$arg"
      fi
    done
  '';
in
buildPythonApplication rec {
  pname = "staticx";
  version = pins.staticx.rev;
  pyproject = true;

  src = pins.staticx.outPath;

  nativeBuildInputs = [
    scons
    muslCross
    python

    makeWrapper
  ];
  env.BOOTLOADER_CC = lib.getExe' muslCross.dev "musl-gcc";

  propagatedBuildInputs = [
    setuptools
    pyelftools
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        binutils
        wrappedPatchElf
      ]
    }"
    "--set-default STATICX_LDD ${lib.escapeShellArg (lib.getExe' glibc "ldd")}"
  ];

  meta = with lib; {
    description = "Create static executable from dynamic executable";
    homepage = "https://github.com/JonathonReinhart/staticx";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl2;
  };
}
