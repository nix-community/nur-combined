{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "smtc-mpris-bridge-host";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "wshowlyrics";
    repo = "smtc-mpris-bridge";
    rev = "3b27747a821006ae01ee3b974183c81e858521de";
    hash = "sha256-Y+WMgRivWW9zKdEt1xMVdFpfoKpNdvX5sfPnOaCt7/0=";
  };

  cargoHash = "sha256-5zq6RmgEzHoWJhmC3LONr7Jp4zBQYbaRNr863KpqBH4=";

  # workspace 에는 Windows 전용 guest 가 같이 있다. 호스트 데몬만 빌드·테스트한다.
  #   guest 의 windows crate 는 cfg(windows) 의존이라 빌드되지 않지만, vendoring 은 Cargo.lock 전체를
  #   받으므로 cargoHash 에는 들어간다.
  cargoBuildFlags = [ "-p" "smtc-mpris-bridge-host" ];
  cargoTestFlags = [ "-p" "smtc-mpris-bridge-host" ];

  meta = {
    description = "Linux host side of smtc-mpris-bridge: republishes Windows guest SMTC sessions as MPRIS players";
    homepage = "https://github.com/wshowlyrics/smtc-mpris-bridge";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "smtc-mpris-bridge-host";
    platforms = lib.platforms.linux;
    # 의존성(zbus 6·uuid 1.28)의 MSRV 가 1.89 다. build.yml 매트릭스의 nixos-25.05 는 rustc 1.86 이라
    #   빌드가 "rustc 1.86.0 is not supported" 로 죽는다(2026-10-23 실측). broken 이면 ci.nix 가 건너뛴다.
    broken = lib.versionOlder rustc.version "1.89";
  };
}
