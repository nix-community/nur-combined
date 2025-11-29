{ fetchgit, glfw3 }:
glfw3.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "glfw3-minecraft";

    patchSrc = fetchgit {
      url = "https://aur.archlinux.org/glfw-wayland-minecraft-cursorfix.git";
      hash = "sha256-u7GJMbBs5SGQ5MmNEOM7yLx3WlpwbHhcAYx6mFHwcpY=";
    };

    patches =
      previousAttrs.patches or [ ]
      ++ map (p: "${finalAttrs.patchSrc}/${p}") [
        "0001-Key-Modifiers-Fix.patch"
        "0002-Fix-duplicate-pointer-scroll-events.patch"
        "0003-Implement-glfwSetCursorPosWayland.patch"
        "0004-Fix-Window-size-on-unset-fullscreen.patch"
        "0005-Add-warning-about-being-an-unofficial-patch.patch"
        "0006-Avoid-error-on-startup.patch"
        "0007-Fix-fullscreen-location.patch"
        "0008-Fix-forge-crash.patch"
      ];

    meta = previousAttrs.meta // {
      description = "GLFW 3 with patches for Minecraft on wayland";
      homepage = "https://aur.archlinux.org/packages/glfw-wayland-minecraft-cursorfix";
    };
  }
)
