{ lib
, stdenvNoCC
, makeWrapper
, chatgpt
}:

# `chatgpt-wayland` provides the same `chatgpt` command as the `chatgpt` package,
# but forces the native Wayland (Ozone) backend instead of the default XWayland.
# Install exactly one of the two; both ship a `bin/chatgpt`.
stdenvNoCC.mkDerivation {
  pname = "chatgpt-wayland";
  version = chatgpt.version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    makeWrapper ${chatgpt}/bin/chatgpt $out/bin/chatgpt \
      --add-flags "--ozone-platform=wayland"
    runHook postInstall
  '';

  meta = chatgpt.meta // {
    description = chatgpt.meta.description + ", native Wayland variant";
    mainProgram = "chatgpt";
  };
}
