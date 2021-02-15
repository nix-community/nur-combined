# limit what users can do in the system. 
self: super: {
   callNixPackage = throw "cannot use callNixPackage here, since it would add extra packages beyond what is defined in the overlays";
   pkgs = self;
   lib = builtins.removeAttrs super.lib ["srcs" "overlays" "pkgsrc"];
}
