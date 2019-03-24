{ stdenv, lib, fetchFromGitHub, python27Packages, nasm, libelf
, kernel ? null, withDriver ? false }:
python27Packages.buildPythonApplication rec {
  name = "chipsec-${version}";
  version = "1.3.7";

  src = fetchFromGitHub {
    owner = "chipsec";
    repo = "chipsec";
    rev = if (version == "1.3.7") then version else "v${version}";
    sha256 = "00hwhi5f24y429zazhm77l1pp31q7fmx7ks3sfm6d16v89zbcp9a";
  };

  nativeBuildInputs = [
    nasm
  ];

  buildInputs = [
    libelf
  ];

  setupPyBuildFlags = lib.optional (!withDriver) "--skip-driver";

  checkPhase = "python setup.py build "
             + lib.optionalString (!withDriver) "--skip-driver "
             + "test";

  KERNEL_SRC_DIR = lib.optionalString withDriver "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  meta = with stdenv.lib; {
    description = "Platform Security Assessment Framework";
    license = licenses.gpl2;
    homepage = https://github.com/chipsec/chipsec;
    maintainers = with maintainers; [ johnazoidberg ];
    # This package description is currently unable to build the MacOS or
    # Windows kernel drivers. But the other functionality should work on all
    # platforms.
    platforms = platforms.all;
  };
}
