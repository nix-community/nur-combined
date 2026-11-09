{
  lib,
  fetchPypi,
  buildPythonApplication,
  setuptools,
  rclone,
  p7zip,
}:

buildPythonApplication (finalAttrs: {
  pname = "git-remote-rclone";
  version = "0.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) version;
    pname = lib.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
    hash = "sha256-zCOnHWvV74iQleEKrqye54R/QpUzXHL4pEX6uP76rRE=";
  };

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    rclone
    p7zip
  ];

  meta = {
    description = "Git remote helper for rclone-supported services";
    homepage = "https://github.com/datalad/git-remote-rclone";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
