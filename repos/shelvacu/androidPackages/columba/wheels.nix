{
  lib,
  fetchFromGitHub,
  fetchurl,
  python311,
  runCommand,
}:
let
  buildPython = python311.withPackages (p: [
    p.pip
    p.setuptools
    p.wheel
  ]);
  gitSrcs = [
    (fetchFromGitHub {
      owner = "torlando-tech";
      repo = "Reticulum";
      rev = "5b3a6ee4f25e2925cf84d4a2b108e6a708fbd395";
      hash = "sha256-+1/5YcxvHLz55bj0P/xLEZm1Q2Ccj8RZElC1trbSUSA=";
    })
    (fetchFromGitHub {
      owner = "torlando-tech";
      repo = "LXMF";
      rev = "8912186e48b482a76bf04e2ac4b6c8940991aecc";
      hash = "sha256-W4YbEL7tZHsVP4cjBhk8MYPgJKcWhzy+fq5myTpEDyA=";
    })
    (fetchFromGitHub {
      owner = "torlando-tech";
      repo = "ble-reticulum";
      rev = "07d941304c9a1dc3a8e58087b3b974ff3d229e56";
      hash = "sha256-qtNn2OEcBbjAJprHDRBE4f8HyOavr5mzQrtMkxh1oxE=";
    })
  ];
  chaquo =
    name: hash:
    fetchurl {
      url = "https://chaquo.com/pypi-13.1/${
        lib.replaceStrings [ "_" ] [ "-" ] (lib.head (lib.splitString "-" name))
      }/${name}";
      inherit hash;
    };
  binaryWheels = [
    (chaquo "cryptography-42.0.8-0-cp311-cp311-android_24_arm64_v8a.whl" "sha256-78p18q0rDinixplDFq+YtZ/I8oFhBl5ZmoFmePBhJY4=")
    (chaquo "cryptography-42.0.8-0-cp311-cp311-android_24_armeabi_v7a.whl" "sha256-fkQYP20pfXXkFdog6tE7sZO5kjonqPYcMa9ZL5ZRqys=")
    (chaquo "cryptography-42.0.8-0-cp311-cp311-android_24_x86_64.whl" "sha256-nt75bEGop8SNVl7ppwbLQ2JCpDUxYWp0gZwde/MsZ7g=")
    (chaquo "cffi-1.17.1-1-cp311-cp311-android_24_arm64_v8a.whl" "sha256-h/TTldFNd/PL5lo0aJBLNSFL1oyMNCM7wPxkIqTABSs=")
    (chaquo "cffi-1.17.1-1-cp311-cp311-android_24_armeabi_v7a.whl" "sha256-hJXiHkX6zm9WQ7DFRfoXEXWqQSEMSWSBohGkEIPiN3o=")
    (chaquo "cffi-1.17.1-1-cp311-cp311-android_24_x86_64.whl" "sha256-faRAcGcZ1MzkPeHMrh/roRtVhx4s8nmUmpdXEVWwJTY=")
    (chaquo "chaquopy_libffi-3.3-3-py3-none-android_24_arm64_v8a.whl" "sha256-hoc8L45eQ7B7ciM7814GrY2uQbqY4FViAtYdANetlS8=")
    (chaquo "chaquopy_libffi-3.3-2-py3-none-android_16_armeabi_v7a.whl" "sha256-jpwY2oFzdH/9eibfQItBN+l1b4VqJHxhf6QycPhrrvg=")
    (chaquo "chaquopy_libffi-3.3-3-py3-none-android_24_x86_64.whl" "sha256-v15KUz7+fBsmh8jbM+XJPBAt4SrqQNhgVw5ewR4p3DE=")
    (fetchurl {
      url = "https://files.pythonhosted.org/packages/90/11/0e6f11117525ff0eec40ebac3d313376f102df93ca44ad9e893ee85e4f89/pycparser-3.11-py3-none-any.whl";
      sha256 = "51d5a8ba2be0bbe440b99d2112604c95bbbc3c2748a64260186c541e1729cd80";
    })
    (fetchurl {
      url = "https://files.pythonhosted.org/packages/07/bc/587a445451b253b285629263eb51c2d8e9bcea4fc97826266d186f96f558/pyserial-3.5-py2.py3-none-any.whl";
      sha256 = "c4451db6ba391ca6ca299fb3ec7bae67a5c55dde170964c7a14ceefec02f2cf0";
    })
    (fetchurl {
      url = "https://files.pythonhosted.org/packages/b1/5e/512aeb40fd819f4660d00f96f5c7371ee36fc8c6b605128c5ee59e0b28c6/u_msgpack_python-2.8.0-py2.py3-none-any.whl";
      sha256 = "1d853d33e78b72c4228a2025b4db28cda81214076e5b0422ed0ae1b1b2bb586a";
    })
  ];
in
runCommand "columba-python-wheels" { nativeBuildInputs = [ buildPython ]; } ''
  mkdir $out
  for src in ${lib.escapeShellArgs gitSrcs}; do
    cp -r "$src" build-src
    chmod -R u+w build-src
    pip wheel --no-deps --no-build-isolation --no-index -w $out ./build-src
    rm -rf build-src
  done
  for whl in ${lib.escapeShellArgs binaryWheels}; do
    cp "$whl" "$out/$(stripHash "$whl")"
  done
''
