{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
  qemu,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "oci-image-migrate";
  version = "0.11.6";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "oci-utils";
    rev = "release-${version}";
    hash = "sha256-WqDJPlvQfF3XRR8CJZTt7U2jFHS3fooaisENVb1xXhU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3.pkgs; [
    oci
    requests
  ];

  # Same path fixes as oci-utils; also needed because setup.py is shared.
  postPatch = ''
    substituteInPlace setup.py \
      --replace '("/etc/systemd/system",' '(os.path.join(sys.prefix, "lib/systemd/system"),' \
      --replace '("/etc/oci-utils",' '(os.path.join(sys.prefix, "etc/oci-utils"),' \
      --replace '("/etc/oci-utils.conf.d",' '(os.path.join(sys.prefix, "etc/oci-utils.conf.d"),' \
      --replace '("/usr/lib/systemd/system-preset",' '(os.path.join(sys.prefix, "lib/systemd/system-preset"),' \
      --replace '(os.path.join("/opt", "oci-utils", "tools"),' '(os.path.join(sys.prefix, "share/oci-utils/tools"),' \
      --replace '(os.path.join("/opt", "oci-utils", "tools", "execution"),' '(os.path.join(sys.prefix, "share/oci-utils/tools/execution"),' \
      --replace '(os.path.join("/opt", "oci-utils", "tests"),' '(os.path.join(sys.prefix, "share/oci-utils/tests"),' \
      --replace '(os.path.join("/opt", "oci-utils", "tests", "data"),' '(os.path.join(sys.prefix, "share/oci-utils/tests/data"),'
  '';

  postInstall = ''
    # Remove non-migrate tools (packaged separately as oci-utils)
    rm -f $out/bin/oci-public-ip \
          $out/bin/oci-metadata \
          $out/bin/oci-iscsi-config \
          $out/bin/oci-network-config \
          $out/bin/oci-network-inspector \
          $out/bin/oci-kvm \
          $out/bin/oci-notify

    # Replace upstream sh wrappers with proper Nix store wrappers.
    sitePackages=$out/${python3.sitePackages}
    for name in oci-image-migrate oci-image-migrate-import oci-image-migrate-upload; do
      mainpy="$sitePackages/oci_utils/impl/migrate/$name-main.py"
      if [ -f "$mainpy" ]; then
        rm -f "$out/bin/$name"
        makeWrapper ${python3.interpreter} "$out/bin/$name" \
          --add-flags "$mainpy" \
          --prefix PATH : ${lib.makeBinPath [ qemu ]}
      fi
    done
  '';

  doCheck = false;

  meta = with lib; {
    description = "Oracle Cloud Infrastructure utilities to migrate on-premises images to OCI";
    homepage = "https://github.com/oracle/oci-utils";
    license = licenses.upl;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "oci-image-migrate";
  };
}
