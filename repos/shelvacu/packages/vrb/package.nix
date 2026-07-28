{
  writers,
  ruby_3_4,
  shellvaculib,
  replaceVars,
}:
let
  ruby = ruby_3_4.withPackages (p: [
    p.activesupport
    p.nokogiri
  ]);
in
(writers.writeBashBin "vrb" (
  replaceVars ./script.bash {
    shellvaculib = shellvaculib.file;
    irb = "${ruby}/bin/irb";
  }
)).overrideAttrs
  (oldAttrs: {
    buildCommand = (oldAttrs.buildCommand or "") + ''
      ln -s ${ruby}/bin/ruby $out/bin/vruby
    '';
  })
