{ lib
, python3Packages
, fetchFromGitHub
, zlib
, openssl
, libssh
, openssh
, git
, octoprint
, pythonAtLeast
}:

python3Packages.buildPythonPackage rec {
  pname = "ssh-python";
  version = "0.10.0";
  disabled = pythonAtLeast "3.11";

  src = fetchFromGitHub {
    owner = "ParallelSSH";
    repo = "ssh-python";
    rev = version;
    sha256 = "sha256-53o7Wx1kVIL4W8bG2r0I0GhCpHrQwrvyzQWyum4Tp6k=";
    leaveDotGit = true;
    deepClone = true;
  };

  patches = [ ./fix-versioneer.patch ./fix-fix_version-script.patch ];

  postPatch = ''
    substituteInPlace tests/embedded_server/openssh.py \
      --replace '/usr/sbin/sshd' '${openssh}/bin/sshd'
  '';

  SYSTEM_LIBSSH = 1;

  nativeBuildInputs = [ git ];
  buildInputs = [ zlib openssl libssh ];
  checkInputs = [ octoprint python3Packages.pytest ];


  preConfigure = ''
    python ci/appveyor/fix_version.py . ${version}
  '';

  doCheck = false;

  meta = with lib; {
    description = "Bindings for libssh C library";
    homepage = "https://github.com/ParallelSSH/ssh-python";
    license = licenses.lgpl21Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
