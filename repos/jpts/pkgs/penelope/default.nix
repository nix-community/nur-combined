{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
}:
buildPythonPackage rec {
  name = "penelope";
  version = "0.9.2";
  owner = "brightio";
  repo = name;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "v${version}";
    sha256 = "sha256-KlbB7i009UttTp+/MaF3y9CGUkAGEQQq/W+hQYKk9CY=";
  };

  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup

    setup(
      name='penelope',
      version='${version}',
      scripts=[
        'penelope.py',
      ],
    )
    EOF
  '';

  installPhase = "install -Dm755 $src/penelope.py $out/bin/penelope";

  meta = {
    homepage = "https://github.com/brightio/penelope";
    changelog = "https://github.com/brightio/penelope/tag/v${version}";
    description = "Reverse Shell Handler";
    longDescription = ''
      Penelope is a shell handler designed to be easy to use and intended to replace netcat when exploiting RCE vulnerabilities. It is compatible with Linux and macOS and requires Python 3.6 or higher. It is a standalone script that does not require any installation or external dependencies, and it is intended to remain this way.
    '';
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
