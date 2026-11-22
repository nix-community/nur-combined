{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  msitools,
  gcab,
  perl,
  git,
  unzip,
  coreutils,
  cacert,
  config,
}:

let
  pname = "msvc-wine-toolchain";

  # The MSVC Build Tools payload version (the installed directory is
  # VC/Tools/MSVC/14.52.37025) and the Windows SDK it pairs with.
  msvcVersion = "14.52.37029";
  msvcToolsetVersion = "14.52.37025";
  sdkVersion = "10.0.26100.0";

  # Microsoft's build tools are not redistributable, so this is gated on an
  # explicit opt-in rather than on nixpkgs' generic unfree switch.
  licenseAccepted = config.microsoftVisualStudioLicenseAccepted or false;
in
stdenv.mkDerivation {
  inherit pname msvcVersion sdkVersion;

  version = msvcVersion;

  src = fetchFromGitHub {
    owner = "mstorsjo";
    repo = "msvc-wine";
    rev = "5dd115047b7ddcbb53cbc8b5b14163a20f4334fe";
    hash = "sha256-7EHHCZcFKJL5GVRBwxdcbbY2LRKY6jyheFwzc5NZtjQ=";
  };

  # vsdownload.py unpacks the Visual Studio installers with msitools; the
  # lowercasing/fixinclude helpers install.sh runs are perl scripts.
  nativeBuildInputs = [
    python3
    msitools
    gcab
    perl
    git
    unzip
    coreutils
    cacert
  ];

  # vsdownload.py fetches the manifests and payloads over https with urllib;
  # inside the sandbox it only trusts what we point it at.
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  dontConfigure = true;

  # Refuse to build unless the (non-redistributable) Microsoft license was
  # accepted. This is checked here rather than by throwing during evaluation,
  # because a throw would break `packages` enumeration for every consumer of
  # the flake, whether or not it needs this toolchain.
  preBuild = lib.optionalString (!licenseAccepted) ''
    echo "${pname}: Microsoft's MSVC/ATL/MFC/Windows SDK are not redistributable." >&2
    echo "Read https://go.microsoft.com/fwlink/?LinkId=2086102 and set" >&2
    echo "  config.microsoftVisualStudioLicenseAccepted = true;" >&2
    exit 1
  '';

  # The wrappers are upstream's bash scripts with `#!/usr/bin/env bash`, and
  # the payload is Windows PE binaries. Nix's default fixup would rewrite the
  # shebangs to a store bash (fixed-output derivations must not reference
  # store paths) and strip the tools, so ship the tree exactly as installed;
  # bash is on PATH for the consumers of these wrappers.
  dontPatchShebangs = true;
  dontStrip = true;

  # install.sh renames bin/HostX64 to bin/Hostx64 (the path the wrappers use),
  # which fails on a case-insensitive filesystem: there `mv HostX64 Hostx64`
  # resolves the destination back to the source directory ("cannot move ...
  # to a subdirectory of itself") and `set -e` aborts the install. Renaming
  # through an unambiguous name gives the same layout on every filesystem.
  postPatch = ''
    substituteInPlace install.sh \
      --replace-fail 'mv HostX64 Hostx64' 'mv HostX64 HostX64.renaming && mv HostX64.renaming Hostx64' \
      --replace-fail 'mv HostARM64 Hostarm64' 'mv HostARM64 HostARM64.renaming && mv HostARM64.renaming Hostarm64' \
      --replace-fail 'mv HostArm64 Hostarm64' 'mv HostArm64 HostArm64.renaming && mv HostArm64.renaming Hostarm64' \
      --replace-fail 'mv Hostarm64/ARM64 Hostarm64/arm64' 'mv Hostarm64/ARM64 Hostarm64/ARM64.renaming && mv Hostarm64/ARM64.renaming Hostarm64/arm64'
  '';

  buildPhase = ''
    runHook preBuild

    # install.sh picks the wrapper host directory from `uname -m` (and would
    # look for a Hostarm64 toolchain on aarch64 builders, which MSVC does not
    # ship). Pin it so the wrapper layout, and therefore the fixed-output
    # hash, is the same on every builder.
    mkdir -p uname-shim
    cat > uname-shim/uname <<EOF
    #!/bin/sh
    if [ "\$1" = "-m" ]; then echo x86_64; else exec ${coreutils}/bin/uname "\$@"; fi
    EOF
    chmod +x uname-shim/uname

    # ATL and MFC are not part of the default selection but anything using
    # MFC needs them; the SDK/CRT/compiler come by default. Only the x64
    # target is installed (the full selection is ~7.6 GiB, this is ~4 GiB),
    # and the DIA SDK is a debugger-only component. The download cache lives
    # in $TMPDIR so a retry does not re-fetch the payloads.
    python3 vsdownload.py \
      --accept-license \
      --dest "$TMPDIR/msvc" \
      --cache "$TMPDIR/vs-cache" \
      --architecture x64 \
      --with-msvc yes \
      --with-atl yes \
      --with-mfc yes \
      --with-sdk yes \
      --with-dia no

    # The MSVC payload also ships arm/arm64/arm64ec libs even for an x64-only
    # selection, but without that target's CRT, so install.sh's case-alias
    # loop leaves dangling LIBCMT.lib etc. symlinks there. Nothing here
    # targets those architectures; drop them instead of keeping broken links.
    rm -rf "$TMPDIR"/msvc/VC/Tools/MSVC/*/lib/arm \
           "$TMPDIR"/msvc/VC/Tools/MSVC/*/lib/arm64 \
           "$TMPDIR"/msvc/VC/Tools/MSVC/*/lib/arm64ec

    # No wine in PATH here, so install.sh skips building msvctricks.exe (its
    # pretty-printer for wine output); the wrappers fall back to plain wine
    # invocation, which is what the tracker build uses.
    PATH="$PWD/uname-shim:$PATH" ./install.sh "$TMPDIR/msvc"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a "$TMPDIR/msvc/." $out/
    chmod -R u+w $out

    # .NET probes for private assemblies next to the executable, and MSBuild.exe's
    # own directory does not carry this one even though the payload ships it with
    # the compiler; without it MSBuild aborts before running any target.
    install -m 644 $out/vc/tools/msvc/*/bin/Hostx64/x64/Microsoft.VisualStudio.Telemetry.dll \
      $out/MSBuild/Current/Bin/amd64/

    # ATL/MFC ship resource scripts whose 2-byte units are partly big-endian;
    # rc.exe reads them as UTF-16LE and stops with RC2255 ("named STRINGTABLEs
    # are not allowed"). Every ASCII byte is paired with a zero half, so dropping
    # the zero bytes recovers the text whatever endianness a line used. Healed
    # once here, so rc.exe accepts them for every consumer of the toolchain.
    python3 - $out <<'PY'
    import glob, sys
    for path in glob.glob(sys.argv[1] + "/VC/Tools/MSVC/*/atlmfc/include/*.rc"):
        with open(path, "rb") as f:
            data = f.read()
        body = data[2:] if data[:2] in (b"\xff\xfe", b"\xfe\xff") else data
        text = bytes(b for b in body if b).decode("latin-1")
        with open(path, "w", encoding="latin-1") as f:
            f.write(text)
    PY

    runHook postInstall
  '';

  # ~4 GiB of unpacked toolchain: only build this when it is actually needed.
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-a2QQjdhmkx9E/EtHz6M7joag4Z7peeIUe6EOOfDgIOg=";
  passthru = {
    inherit msvcVersion msvcToolsetVersion sdkVersion;
  };

  meta = {
    description = "MSVC + ATL/MFC + Windows SDK unpacked for Wine-based cross builds";
    longDescription = ''
      Downloads and unpacks Microsoft's x64 MSVC Build Tools, ATL, MFC and the
      Windows SDK through msvc-wine's vsdownload.py, then installs its wrapper
      scripts. The result is a 4 GiB, non-redistributable toolchain meant to be
      driven with Wine (cl.exe, lib.exe, link.exe and rc.exe run as Windows
      PE files); nothing in it is redistributable.
    '';
    homepage = "https://github.com/mstorsjo/msvc-wine";
    license = lib.licenses.unfree;
    maintainers = [ "maydayv7" ]; # The wrappers drive x86_64 PE binaries through Wine, which needs an
    # x86_64 Wine host: natively on x86_64, via Rosetta on Apple Silicon.
    # aarch64 Linux would need an x86_64 emulator, so it is not listed.
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
