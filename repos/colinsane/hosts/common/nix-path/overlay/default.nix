# XXX: NIX_PATH=...:nixpkgs-overlays=... will import every overlay in the directory
# so we prefer to give it a directory with just this *one* overlay, otherwise it imports conflicting overlays
# and gets stuck in a loop until it OOMs
import ../../../../overlays/all.nix
