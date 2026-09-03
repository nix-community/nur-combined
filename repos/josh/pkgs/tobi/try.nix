{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ruby,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "try";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "try";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZSt6LSp0AQTbdN86lJGJPWcx6oFR63AFi4s8Vjr5a5o=";
  };

  dontBuild = true;

  postPatch = ''
    substituteInPlace try.rb \
      --replace-fail "/usr/bin/env ruby" "${lib.getExe ruby}" \
      --replace-fail "& ruby " "& '${lib.getExe ruby}' "
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 try.rb $out/bin/try
    cp -r lib $out/bin/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    shell-integration =
      runCommand "test-try-shell-integration"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          try --version 2>&1 | grep -F "try ${finalAttrs.version}"

          testRoot="$PWD"
          mkdir tries
          eval "$(try exec --path "$testRoot/tries" . package-test)"
          test "$PWD" = "$testRoot/tries/$(date +%Y-%m-%d)-package-test"

          try init /tmp/tries | grep -F "${lib.getExe ruby}"
          touch $out
        '';
  };

  meta = {
    description = "Manage date-stamped directories for programming experiments";
    homepage = "https://github.com/tobi/try";
    license = lib.licenses.mit;
    mainProgram = "try";
    platforms = lib.platforms.unix;
  };
})
