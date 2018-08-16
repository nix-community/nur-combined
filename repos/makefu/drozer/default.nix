{ pkgs, lib, fetchFromGitHub, pythonPackages, jre, jdk }:

pythonPackages.buildPythonApplication rec {
  name = "drozer-${version}";
  version = "2.4.3";
  buildInputs = [ jdk ];
  propagatedBuildInputs = with pythonPackages; [
    protobuf
    pyopenssl
    pyyaml
    service-identity
  ] ++ [
    jre
    twisted
  ];
  src = fetchFromGitHub {
    owner = "mwrlabs";
    repo = "drozer";
    rev = version;
    sha256 = "1z437y7rr53dhpi95yc2c3x8g4aix90y7zf52avcdsvhlp4iip3q";
  };
  prePatch = ''
    sed -i 's#^exec java #exec ${jre}/bin/java #' ./src/drozer/lib/dx
    patchShebangs ./src/drozer/lib/dx
    patchelf $(cat $NIX_CC/nix-support/dynamic-linker) ./src/drozer/lib/aapt
    echo starting build
  '';

  meta = {
    homepage = https://github.com/mwrlabs/drozer/;
    description = "The Leading Security Assessment Framework for Android";
    license = lib.licenses.bsd2;
  };
}
