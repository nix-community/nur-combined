{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nodejs_20,
  pnpm_8,
  customCSS ? null,
}:
let
  # 1.14.0 stable was still based on pnpm 7, which is not available in nixpkgs
  version = "1.14.0-unstable-2025-07-07";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "remark42";
    # tag = "v${version}";
    rev = "eaa64bac45336cc27a8000590890dd3e0374f129";
    sha256 = "sha256-Xrh48FNDW+yGFW61ePVqmOIv6zoSyPHK7LRp0ALI9RY=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "remark42-frontend";
    inherit version src;

    pnpmRoot = "frontend";

    pnpmDeps = pnpm_8.fetchDeps {
      inherit (finalAttrs) pname version src;
      sourceRoot = "${finalAttrs.src.name}/frontend";
      fetcherVersion = 2;
      # Might require more cases...
      hash =
        if stdenv.isDarwin && stdenv.isAarch64 then
          "sha256-2rfhOV+2RQr3A4dcvQkzgTVT8uXIW4l80XYZdPt/WDA=" # Darwin/aarch64
        else
          "sha256-vHv8t1nJqCGFbP7NGBRv2SmdVfl3wlYe0JwpwZqQ6rU="; # Linux/x86_64
    };

    nativeBuildInputs = [
      nodejs_20
      pnpm_8.configHook
    ];

    buildPhase = ''
      runHook preBuild
      cd frontend/apps/remark42
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r public $out
      ${lib.optionalString (customCSS != null) ''
        echo "${customCSS}" >> $out/remark.css
      ''}
      runHook postInstall
    '';
  });
in
buildGoModule rec {
  pname = "remark42";
  inherit version src;
  sourceRoot = "source/backend";
  vendorHash = null;

  preBuild = ''
    cp -r ${frontend}/* ./app/cmd/web/
    find ./app/cmd/web/ -regex '.*\.\(html\|js\|mjs\)$' \
      -exec sed -i "s|{% REMARK_URL %}|http://127.0.0.1:8080|g" {} \;
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.revision=${version}"
  ];

  subPackages = [ "app" ];

  # Skip tests due to flaky webhook test that sometimes fails
  doCheck = false;

  postInstall = ''
    mv $out/bin/app $out/bin/remark42
    install -Dm755 ${src}/backend/scripts/backup.sh $out/bin/backup
    install -Dm755 ${src}/backend/scripts/restore.sh $out/bin/restore
    install -Dm755 ${src}/backend/scripts/import.sh $out/bin/import

    # These are embedded in the binary already. We duplicate them,
    # so they can be served directly by a webserver as well.
    mkdir -p $out/public
    cp -R ${frontend}/* $out/public/
  '';

  meta = with lib; {
    description = "Remark42 comment engine";
    homepage = "https://remark42.com";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "remark42";
  };
}
