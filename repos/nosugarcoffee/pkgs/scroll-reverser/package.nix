{ scroll-reverser }:
# nixpkgs' undmg leaves AppleDouble sidecars (._Foo) inside the app
# bundle. Those files are not in the Developer ID seal, so Gatekeeper
# rejects the bundle with "damaged." Deleting them restores the seal;
# no re-signing needed.
scroll-reverser.overrideAttrs (o: {
  postFixup = (o.postFixup or "") + ''
    find "$out/Applications/Scroll Reverser.app" -name '._*' -delete
  '';
})
