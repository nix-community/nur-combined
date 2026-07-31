{
  firefoxpwa,
  jq,
  makeWrapper,
  symlinkJoin,
}:

symlinkJoin {
  name = "firefoxpwa-xwayland-${firefoxpwa.version}";
  paths = [ firefoxpwa ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/firefoxpwa" --set MOZ_ENABLE_WAYLAND 0
    wrapProgram "$out/bin/firefoxpwa-connector" --set MOZ_ENABLE_WAYLAND 0

    manifest="$out/lib/mozilla/native-messaging-hosts/firefoxpwa.json"
    rm "$manifest"
    ${jq}/bin/jq \
      --arg path "$out/bin/firefoxpwa-connector" \
      '.path = $path' \
      "${firefoxpwa}/lib/mozilla/native-messaging-hosts/firefoxpwa.json" \
      > "$manifest"
  '';

  passthru = firefoxpwa.passthru // {
    unwrapped = firefoxpwa;
  };

  meta = firefoxpwa.meta // {
    description = "Firefox PWA launcher forced to use XWayland";
  };
}
