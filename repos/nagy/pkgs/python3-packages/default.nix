{ callPackage }:

{
  asyncer = callPackage ./asyncer { };
  dbussy = callPackage ./dbussy { };
  colorpedia = callPackage ./colorpedia { };
  ssort = callPackage ./ssort { };
  extcolors = callPackage ./extcolors { };
  convcolors = callPackage ./convcolors { };
  rembg = callPackage ./rembg { };
  warctools = callPackage ./warctools { };
  blender-file = callPackage ./blender-file { };
  blender-asset-tracer = callPackage ./blender-asset-tracer { };
  jtbl = callPackage ./jtbl { };
  git-remote-rclone = callPackage ./git-remote-rclone { };
  oauth2token = callPackage ./oauth2token { };
  images-upload-cli = callPackage ./images-upload-cli { };
  imagehash = callPackage ./imagehash { };
  pipe21 = callPackage ./pipe21 { };
  pystitcher = callPackage ./pystitcher { };
  makeelf = callPackage ./makeelf { };
}
