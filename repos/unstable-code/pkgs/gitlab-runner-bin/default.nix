{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gitlab-runner-bin";
  version = "19.4.1";

  # ⚠️ 소스 빌드가 아니라 **upstream 공식 바이너리**를 쓴다. 이유는 nixpkgs 의 갱신 지연이다.
  #   nixpkgs 의 gitlab-runner 는 2026-09-14 기준 master 까지 19.2.1 인데 upstream 은 19.3.2 였고,
  #   직전 bump PR(NixOS/nixpkgs#530039, 19.1.1 -> 19.2.1)은 머지까지 석 달이 걸렸다.
  #   공식 바이너리는 **정적 링크 Go ELF** 라 patchelf 없이 그대로 돈다(2026-09-14 file(1) 실측).
  #
  #   nixpkgs 파생이 붙이는 패치가 빠지는데, 소비자(nix-configurations 의 shell executor 러너) 기준으로
  #   영향이 없음을 확인했다:
  #     fix-shell-path.patch   = `su -s /bin/<shell>` 을 PATH 검색으로 바꾼다. 그런데 이 분기는
  #                              shells/bash.go 의 `info.User == ""` 조기 반환 **뒤**에 있어, 잡을 다른
  #                              유저로 su 할 때(`run --user`)만 탄다. NixOS 모듈은 --user 를 안 준다.
  #     remove-bash-test.patch = 테스트 비활성화뿐 — 바이너리와 무관.
  #     clear-docker-cache     = nixpkgs 는 postInstall 로 같이 설치하지만, 모듈은 이 경로를
  #                              cfg.package 가 아니라 pkgs.gitlab-runner 에서 참조한다(docker executor 전용).
  #   즉 이 패키지는 `services.gitlab-runner.package` 로 CLI(register/verify/list/run)만 대체한다.
  #
  #   갱신 절차: ./update.sh (GitLab releases API 의 최고 semver 를 보고 아래 version/hash 를 교체).
  src = fetchurl {
    url = "https://gitlab-runner-downloads.s3.amazonaws.com/v${finalAttrs.version}/binaries/gitlab-runner-linux-amd64";
    hash = "sha256-WhWbNsX/VP2pJI4AuwzftiwREqs3QfUoLASkHpTaEwY=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/gitlab-runner
    runHook postInstall
  '';

  # 받은 바이트를 그대로 둔다 — 해시는 upstream release.sha256 과 대조한 값이라, strip 으로
  #   바이트가 바뀌면 "공식 바이너리와 동일" 이라는 전제가 깨진다(정적 ELF 라 patchelf 할 것도 없다).
  dontStrip = true;
  dontPatchELF = true;

  # 버전 관문. URL 에 버전이 박히긴 하지만, update.sh 가 버전만 올리고 해시를 못 바꿨거나 그 반대인
  #   경우는 fetchurl 해시 불일치로 먼저 죽는다. 이 관문은 **S3 경로와 실제 바이너리 버전이 어긋나는
  #   경우**(업로드 사고)를 잡는다 — `gitlab-runner --version` 출력에 version 이 있어야 통과한다.
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  #   실행 파일 경로도 명시한다 — meta.mainProgram 만으로는 build.yml 매트릭스의 nixos-25.05 에서 깨진다.
  #   그 판의 mkDerivation 은 mainProgram 을 NIX_MAIN_PROGRAM 으로 내보내지 않고 훅도 versionCheckProgram
  #   과 pname 만 봐서, pname(gitlab-runner-bin)으로 bin/gitlab-runner-bin 을 찾다 실패했다(ce871f7 CI).
  versionCheckProgram = "${placeholder "out"}/bin/gitlab-runner";
  #   인자를 명시하는 건 군더더기가 아니다 — 비워두면 훅이 `--version` 실패 시 `--help` 로 폴백하는데,
  #   gitlab-runner 의 --help 도 VERSION 을 찍어서 --version 이 깨져도 조용히 통과해 버린다.
  versionCheckProgramArg = "--version";

  meta = {
    description = "GitLab Runner, the continuous integration executor of GitLab (upstream prebuilt binary)";
    homepage = "https://docs.gitlab.com/runner";
    changelog = "https://gitlab.com/gitlab-org/gitlab-runner/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "gitlab-runner";
  };
})
