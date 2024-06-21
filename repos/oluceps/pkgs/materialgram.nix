{
  tdesktop,
  lib,
  xdg-utils,
  stdenv,
  fetchFromGitHub,
}:
tdesktop.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "materialgram";
    version = "5.1.7.1-unstable-2024-05-18";

    src = fetchFromGitHub {
      owner = "kukuruzka165";
      repo = "materialgram";
      rev = "2fa4ffed4b9983a9104f3644631ff04885f388b6";
      fetchSubmodules = true;
      hash = "sha256-ULIh/uvdNqnRV7TG+dq/IcZDWoAJVz5I+1haehaQGU0=";
    };

    postFixup =
      lib.optionalString stdenv.isLinux ''
        # This is necessary to run Telegram in a pure environment.
        # We also use gappsWrapperArgs from wrapGAppsHook.
        wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
          "''${gappsWrapperArgs[@]}" \
          "''${qtWrapperArgs[@]}" \
          --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
      ''
      + lib.optionalString stdenv.isDarwin ''
        wrapQtApp $out/Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS/${finalAttrs.meta.mainProgram}
      '';

    meta = previousAttrs.meta // {
      mainProgram = "materialgram";
    };
  }
)
