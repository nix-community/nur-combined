{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-aurora-pinyin";
  version = "0-unstable-2022-08-28";
  src = fetchFromGitHub {
    owner = "hosxy";
    repo = "rime-aurora-pinyin";
    rev = "122b46976401995cbafcfc748806985ff3a437a4";
    hash = "sha256-zLzQXSsKwgr7OsyYllyoLNSF9q4mJA5ZYD7v7oagfaE=";
  };
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp *.yaml $out/share/rime-data/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/hosxy/rime-aurora-pinyin";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "【极光拼音】输入方案";
    homepage = "https://github.com/hosxy/rime-aurora-pinyin";
    license = lib.licenses.asl20;
  };
})
