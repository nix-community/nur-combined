{
  lib,
  fetchFromGitHub,
  rigs-of-rods,
  angelscript,
}:

# Community native macOS / Apple Silicon port of Rigs of Rods.
# Sources:
#   https://github.com/RigsOfRods/rigs-of-rods/issues/2981
#   https://github.com/RigsOfRods/rigs-of-rods/issues/3465
#   https://github.com/RigsOfRods/rigs-of-rods/pull/3484
#   https://github.com/aasaasaasss/rigs-of-rods-apple-silicon
#
# Upstream closed #3484 for AI_POLICY.md; the changes remain the working
# community Apple Silicon port (Cocoa lifecycle, _NSGetExecutablePath,
# OpenAL Soft headers, GLSL fallbacks without Cg, CMake Apple wiring).
#
# The fork tracks a post-2026.01 tree whose vendored angelscript_addons need
# AngelScript 2.38 (GetStringFactory / asINT32); stock rigs-of-rods stays on
# angelscript_2_35_1.
(rigs-of-rods.override {
  angelscript_2_35_1 = angelscript;
}).overrideAttrs
  (old: {
    pname = "rigs-of-rods_patched";
    version = "2026.01-unstable-2026-10-21";

    src = fetchFromGitHub {
      owner = "aasaasaasss";
      repo = "rigs-of-rods-apple-silicon";
      # PR #3484 head (macOS port commits + merge of RigsOfRods/master).
      rev = "3749713f1f81704843222e66263d89f618fb65a5";
      hash = "sha256-JBsiwCkUdMRVgQRAwGB4s3lTtbMNYojW6LmF0OF/AG0=";
    };

    # Nix packaging patches from rigs-of-rods, plus C++17 auto_ptr fix for the
    # vendored PagedGeometry ImpostorPage (needed on Apple libc++).
    patches = (old.patches or [ ]) ++ [ ./fix-auto-ptr.patch ];

    meta = (old.meta or { }) // {
      description = "Rigs of Rods with community native macOS / Apple Silicon port patches";
      homepage = "https://github.com/aasaasaasss/rigs-of-rods-apple-silicon";
      platforms = with lib.platforms; linux ++ darwin;
    };
  })
