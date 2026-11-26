{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "monotykamary-pi-math";
  version = "0.5.15";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "monotykamary";
    repo = "pi-math";
    rev = "7c351be1854b46383761b8427bba4f02bfdfe824";
    hash = "sha256-/i3+eSRxtLewdPDlIOyYcCclaz+KTr2s6VokrPnmpNw=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-wMIqg9lK0lGc8sNQbOXVnZuvk52eHYBu0lFpa7yGc+A=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/@monotykamary/pi-math/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Render LaTeX as terminal images in Pi's TUI";
    homepage = "https://github.com/monotykamary/pi-math";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
