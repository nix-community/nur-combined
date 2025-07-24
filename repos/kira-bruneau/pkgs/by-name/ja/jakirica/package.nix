{
  lib,
  habitica,
  jq,
  writeShellScript,
  writeText,
  ...
}:

let
  branding = writeShellScript "jakirica-branding.sh" ''
    find website/common/locales -type f -name "*.json" -exec sh '${lib.getExe jq} -c -f ${writeText "jakirica-branding.jq" ''
      walk(
        if type == "string" then
          gsub("\\bHabitica"; "Jakirica") |
          gsub("\\bhabitica"; "jakirica")
        else
          .
        end
      )
    ''} "$1" > "$1.tmp" && mv "$1.tmp" "$1"' "" {} \;
  '';
in
habitica.overrideAttrs (attrs: {
  pname = "jakirica";

  patches = (attrs.patches or [ ]) ++ [
    ./keep-completed-todos.patch
  ];

  postPatch = (attrs.postPatch or "") + branding;
})
// {
  client = habitica.client.overrideAttrs (attrs: {
    pname = "jakirica-client";

    postPatch = (attrs.postPatch or "") + ''
      chmod +w -R ../common
      (cd ../..; ${branding})
    '';
  });
}
