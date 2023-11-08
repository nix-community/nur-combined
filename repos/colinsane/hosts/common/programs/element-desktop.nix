# debugging tips:
# - if element opens but does not render:
#   - `element-desktop --disable-gpu --in-process-gpu`
#     - <https://github.com/vector-im/element-desktop/issues/1029#issuecomment-1632688224>
#   - `rm -rf ~/.config/Element/GPUCache`
#     - <https://github.com/NixOS/nixpkgs/issues/244486>
{ ... }:
{
  sane.programs.element-desktop = {
    # creds/session keys, etc
    persist.byStore.private = [ ".config/Element" ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
