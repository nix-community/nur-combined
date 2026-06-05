{
  flatpak-xdg-utils,
  linkBinIntoOwnPackage,
}:
# N.B.: using `flatpak-xdg-utils` instead of stock `xdg-utils` due to better cross-compilation support.
linkBinIntoOwnPackage flatpak-xdg-utils "xdg-open"
