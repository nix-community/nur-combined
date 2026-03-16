{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "oci-utils";
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
    sdnotify
    python-daemon
    netaddr
  ];

  # The setup.py tries to install into absolute system paths (/etc, /usr/lib/systemd, etc.)
  # Patch it to use prefix-relative paths instead.
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
    # Remove migration tools (packaged separately as oci-image-migrate)
    rm -f $out/bin/oci-image-migrate \
          $out/bin/oci-image-migrate-import \
          $out/bin/oci-image-migrate-upload

    # Build a PYTHONPATH covering this package and all propagated deps.
    # makeWrapper --add-flags bypasses the normal generated wrapper that sets
    # PYTHONPATH, so we must supply it explicitly for every Python wrapper we
    # create. Without this, propagated deps (daemon, oci, requests, sdnotify)
    # are invisible at runtime.
    pythonPath="${python3.pkgs.makePythonPath propagatedBuildInputs}:$out/${python3.sitePackages}"

    sitePackages=$out/${python3.sitePackages}

    # The upstream bin/ scripts are sh wrappers that discover the oci_utils.impl path
    # at runtime via python. Replace them with proper wrappers pointing to the Nix store.
    for script in $out/bin/oci-*; do
      name=$(basename "$script")
      # derive the main python module name: oci-public-ip -> oci-public-ip-main.py
      mainpy="$sitePackages/oci_utils/impl/$name-main.py"
      if [ -f "$mainpy" ]; then
        rm "$script"
        makeWrapper ${python3.interpreter} "$script" \
          --add-flags "$mainpy" \
          --set PYTHONPATH "$pythonPath"
      fi
    done

    # oci-kvm: its main module lives under impl/virt/, not impl/
    rm -f $out/bin/oci-kvm
    makeWrapper ${python3.interpreter} $out/bin/oci-kvm \
      --add-flags "$sitePackages/oci_utils/impl/virt/oci-kvm-main.py" \
      --set PYTHONPATH "$pythonPath"

    # oci-notify: pure bash script (no Python main); replace upstream wrapper
    # (which hardcodes /etc paths) with a patchShebangs-fixed copy from source.
    install -Dm755 bin/oci-notify $out/bin/oci-notify
    patchShebangs $out/bin/oci-notify

    # Install libexec helpers; wrap the Python-based ones properly so they
    # resolve oci_utils at the Nix store path instead of using runtime discovery.
    mkdir -p $out/libexec/oci-utils

    # ocid daemon (Python)
    makeWrapper ${python3.interpreter} $out/libexec/oci-utils/ocid \
      --add-flags "$sitePackages/oci_utils/impl/ocid-main.py" \
      --set PYTHONPATH "$pythonPath"

    # oci-growfs and oci-image-cleanup are bash scripts; install and patch shebangs
    install -Dm755 libexec/oci-growfs $out/libexec/oci-utils/oci-growfs
    install -Dm755 libexec/oci-image-cleanup $out/libexec/oci-utils/oci-image-cleanup
    patchShebangs $out/libexec/oci-utils/oci-growfs
    patchShebangs $out/libexec/oci-utils/oci-image-cleanup

    # oci-utils-config-helper (sh script, install as-is)
    install -Dm755 libexec/oci-utils-config-helper $out/libexec/oci-utils/oci-utils-config-helper
    patchShebangs $out/libexec/oci-utils/oci-utils-config-helper

    # awk helper used by oci_vcn_iface
    install -Dm644 libexec/oci_vcn_iface.awk $out/libexec/oci-utils/oci_vcn_iface.awk
  '';

  doCheck = false;

  meta = with lib; {
    description = "Oracle Cloud Infrastructure instance utilities (ocid, oci-metadata, oci-network-config, oci-public-ip, and more)";
    homepage = "https://github.com/oracle/oci-utils";
    license = licenses.upl;
    sourceProvenance = [sourceTypes.fromSource];
    mainProgram = "oci-metadata";
    maintainers = [];
    platforms = platforms.linux;
  };
}
