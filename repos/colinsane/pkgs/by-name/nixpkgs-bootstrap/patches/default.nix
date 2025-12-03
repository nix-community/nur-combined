# track PRs on their way to master: <https://nixpk.gs/pr-tracker.htm>
{ vendorPatch }:
let
  maybePatchNames = builtins.map
    (name: builtins.match "(.*)\\.patch" name)
    (builtins.attrNames (builtins.readDir ./.))
  ;
  nestedPatchNames = builtins.filter (v: v != null) maybePatchNames;
  patchNames = builtins.map (matches: builtins.head matches) nestedPatchNames;
in
  builtins.listToAttrs (
    builtins.map
      (name: {
        inherit name;
        value = vendorPatch { inherit name; };
      })
      patchNames
  )

# # (fetchpatch' {
# #   name = ''nixos/bind: add an "extraArgs" option'';
# #   # saneCommit = "ab65c92241bd4acab25aad19d0fea4873c1bc3b7";
# #   prUrl = "https://github.com/NixOS/nixpkgs/pull/414825";
# #   hash = "sha256-Hs3uKT3b5D4hkipEgD19j+bv5k63Eba8jMdENaE1Plg=";
# # })

# (fetchpatch' {
#   name = "zelda64recomp: init at 1.2.0";
#   prUrl = "https://github.com/NixOS/nixpkgs/pull/313013";
#   hash = "sha256-VCFRNWDTxQqQ0f/ddAcMwj35BpmTTwtDje95oYy8pK4=";
# })

# (fetchpatch' {
#   # TODO: push upstream
#   name = "pyright: fix cross compilation";
#   saneCommit = "b6ee8063d934123df51fc894908577bb1a305392";
#   hash = "sha256-1QNBEh/yCzbR0spMUFXkP27bZWDgKYMq8yP5GyTbJ6w=";
# })

# (fetchpatch' {
#   name = "libshumate: fix vapi file generation when cross compiling";
#   prUrl = "https://github.com/NixOS/nixpkgs/pull/449044";
#   # saneCommit = "ddeb72ba7d8dc166c1b51648c0e974a0c48f8bb3";
#   hash = "sha256-mmI1QT/vW7/V2Nh+tIa4VsLcjxMxEVEjZVHw9OrZLeI=";
# })

# # (fetchpatch' {
# #   # TODO: apply this to *everything* in the python-packages scope, then send for PR
# #   name = "python3Packages.llvmlite: fix cross compilation";
# #   saneCommit = "2d2616e640f7b01b71d50f7df3dd149b8b22805a";
# #   hash = "sha256-aM7EbBL7nt5iZ7i/Hg/tS4iUKr0EgGPsKgpNCJbAjuI=";
# # })

# # (fetchpatch' {
# #   name = "opencv: fix cross compilation for enablePython = true";
# #   prUrl = "https://github.com/NixOS/nixpkgs/pull/454018";
# #   hash = "sha256-4Sec5wzVs7EyZJm9IYzZHHWxoYNCRLTsxYU+eOQnEW4=";
# # })

# # (fetchpatch' {
# #   name = "onnxruntime: fix cross compilation";
# #   prUrl = "https://github.com/NixOS/nixpkgs/pull/450107";
# #   hash = "sha256-NUaBoaaPDygkyzep82lJA99rTjlzgC/cbUjcLl0JaGc=";
# # })

# # (fetchpatch' {
# #   # TODO: send upstream (`pr-onnxruntime-cross`) once deployed
# #   # (or, share as comment at https://github.com/NixOS/nixpkgs/pull/450107).
# #   # N.B.: doesn't actually fix cross compilation!
# #   name = "onnxruntime: fix cross compilation";
# #   saneCommit = "fc1a583d6ece7e850b7edb36747890bf2258670a";
# #   hash = "sha256-4KApDHRUEJD98LlEGtcb0suEQLe190zEzlm/D0ceQhk=";
# # })

# # (fetchpatch' {
# #   name = "python313Packages.magika: disable imports on aarch64";
# #   prUrl = "https://github.com/NixOS/nixpkgs/pull/452980";
# #   hash = "sha256-uu0NawFEfrGRb05mb972wVKox8AML/ewF0UOn8mrGeE=";
# # })
# # TODO: enable, once i can tolerate a mass rebuild
# # (fetchpatch' {
# #   name = "libpcap: enable dbus, rdma, bluetooth features";
# #   prUrl = "https://github.com/NixOS/nixpkgs/pull/429225";
# #   hash = "sha256-cALgj+7eXd3H4WAmW6CIcxWRC3D4PoY2PWNsDxK+G9g=";
# # })
