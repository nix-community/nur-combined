{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "glab-bin";
  version = "1.124.0";

  # ⚠️ 소스 빌드가 아니라 **upstream 공식 바이너리**를 쓴다. 이유는 nixpkgs 의 갱신 지연이다 —
  #   gitlab-runner-bin 과 같은 사정이다. nixpkgs 의 glab 은 2026-10-21 기준 master 까지 1.114.0 이고
  #   (마지막 범프 NixOS/nixpkgs#552039, 2026-08-12), upstream 은 매주 화요일 릴리스로 1.124.0 이었다.
  #   공식 tarball 의 bin/glab 은 **정적 링크 Go ELF** 라 patchelf 없이 그대로 돈다(2026-10-21 file(1) 실측).
  #   nixpkgs 판을 `overrideAttrs` 로 올리지 않는 이유: version·src hash 와 함께 vendorHash 를 바꿔야 하는데
  #   vendorHash 는 빌드를 돌려야 나온다 — 매주 사람이 올려야 하는 같은 지연이 모양만 바뀌어 남는다.
  #
  #   nixpkgs 판이 postInstall 에서 해 주는 것 셋 중 둘을 그대로 옮긴다:
  #     셸 자동완성 = tarball 에 없다(bin/glab·README·LICENSE·CHANGELOG 뿐). 바이너리가 만들게 한다.
  #     래퍼        = GLAB_CHECK_UPDATE=0·GLAB_SEND_TELEMETRY=0 을 기본값으로 둔다. 빼면 업데이트 확인과
  #                   텔레메트리가 켜진 상태가 된다 — 패키지를 바꾸는 것만으로 동작이 달라지는 회귀다.
  #   ⚠️ 빠지는 것 하나: **man 페이지.** nixpkgs 는 소스 트리에서 `make manpage` 로 만드는데 tarball 에는
  #   소스가 없고, 바이너리에도 man 을 생성하는 명령이 없다(`glab --help` 실측: completion 만 있다).
  #   `glab <cmd> --help` 가 같은 내용을 준다.
  #
  #   갱신 절차: ./update.sh (GitLab releases API 의 최고 semver 를 보고 아래 version/hash 를 교체).
  src = fetchurl {
    url = "https://gitlab.com/gitlab-org/cli/-/releases/v${finalAttrs.version}/downloads/glab_${finalAttrs.version}_linux_amd64.tar.gz";
    hash = "sha256-Y99oSEKwaX5BhkndZDdNN6wdoPvNy0ItalVXIi+LtA8=";
  };

  # tarball 은 최상위에 bin/ 이 바로 있다(감싸는 디렉터리가 없다).
  sourceRoot = ".";

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/glab $out/bin/glab
    runHook postInstall
  '';

  # 자동완성은 래핑 **전에** 원본으로 만든다. glab 은 HOME 이 없으면 config 디렉터리를 만들다 죽는다
  #   (`env -i bin/glab version` → "mkdir /.config: permission denied", 2026-10-21 실측). 빌드 샌드박스의
  #   HOME 은 존재하지 않는 경로라 TMPDIR 로 돌린다. writableTmpDirAsHomeHook 을 쓰지 않는 이유는 build.yml
  #   매트릭스에 nixos-25.05 가 있어서다 — 훅이 없는 판에서도 같은 식으로 돈다.
  postInstall = ''
    export HOME=$TMPDIR
    installShellCompletion --cmd glab \
      --bash <($out/bin/glab completion -s bash) \
      --fish <($out/bin/glab completion -s fish) \
      --zsh <($out/bin/glab completion -s zsh)

    wrapProgram $out/bin/glab \
      --set-default GLAB_CHECK_UPDATE 0 \
      --set-default GLAB_SEND_TELEMETRY 0
  '';

  # 받은 바이트를 그대로 둔다 — 해시는 upstream checksums.txt 와 대조한 값이라, strip 으로 바이트가
  #   바뀌면 "공식 바이너리와 동일" 이라는 전제가 깨진다. 래퍼는 원본을 .glab-wrapped 로 옮길 뿐 고치지 않는다.
  dontStrip = true;
  dontPatchELF = true;

  # 버전 관문 — 다운로드 경로의 버전과 실제 바이너리 버전이 어긋나는 업로드 사고를 잡는다.
  #   versionCheckHook 을 쓰지 않는다: 훅이 환경을 비우고 실행해 HOME 이 없어지면 glab 이 죽는데, 이를 막는
  #   versionCheckKeepEnvironment 가 nixos-25.05 판 훅에 있다고 장담할 수 없다. 출력 앞머리를 직접 본다
  #   (`glab version` → "glab 1.124.0 (d43ccacec)"). 래퍼를 거쳐 부르므로 래퍼도 함께 검사된다.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    out_ver=$(HOME=$TMPDIR $out/bin/glab version)
    case "$out_ver" in
      "glab ${finalAttrs.version} "*) echo "version ok: $out_ver" ;;
      *) echo "error: 기대 glab ${finalAttrs.version}, 실제: $out_ver" >&2; exit 1 ;;
    esac
    runHook postInstallCheck
  '';

  meta = {
    description = "GitLab CLI tool bringing GitLab to your command line (upstream prebuilt binary)";
    homepage = "https://gitlab.com/gitlab-org/cli";
    changelog = "https://gitlab.com/gitlab-org/cli/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "glab";
  };
})
