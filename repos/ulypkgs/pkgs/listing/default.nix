{
  lib,
  writeTextFile,
  ulypkgsPackages,
  repoName ? "ulypkgs",
  repoBaseUrl ? "https://github.com/UlyssesZh/ulypkgs/blob/master",
  basePath ? toString ../..,
  packages ? ulypkgsPackages,
}:

# must use writeTextFile instead of writeText to avoid evaluating the text just to evaluate this package
writeTextFile {
  name = "listing.html";
  text = ''
    <!DOCTYPE html>
    <html lang="en-US">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${repoName}</title>
      </head>
      <body>
        <h1>${repoName}</h1>
        <p>Here is a list of all packages added by ${repoName}.</p>
        <ul>
          ${lib.concatMapAttrsStringSep "\n" (
            attr: package:
            if lib.isDerivation package then
              ''
                <li id="${attr}"><details>
                  <summary><code>${attr}</code> (${package.name})</summary>
                  ${lib.optionalString (package ? meta.description) "<p>${package.meta.description}</p>"}
                  ${lib.optionalString
                    (package ? meta.homepage || package ? meta.changelog || package ? meta.downloadPage)
                    ''
                      <p>
                        ${lib.optionalString (
                          package ? meta.homepage
                        ) "<a href=\"${package.meta.homepage}\" target=\"_blank\">Homepage</a>"}
                        ${lib.optionalString (
                          package ? meta.changelog
                        ) "<a href=\"${package.meta.changelog}\" target=\"_blank\">Changelog</a>"}
                        ${lib.optionalString (
                          package ? meta.downloadPage
                        ) "<a href=\"${package.meta.downloadPage}\" target=\"_blank\">Download</a>"}
                      </p>
                    ''
                  }
                  ${lib.optionalString (package ? meta.license.fullName)
                    "<p>License: ${
                      if package ? meta.license.url then
                        "<a href=\"${package.meta.license.url}\" target=\"_blank\">${package.meta.license.fullName}</a>"
                      else
                        package.meta.license.fullName
                    }</p>"
                  }
                  <p>Outputs: ${lib.concatMapStringsSep ", " (o: "<code>\"${o}\"</code>") package.outputs}</p>
                  ${lib.optionalString (package ? meta.position)
                    "<p>Defined at ${
                      let
                        match = builtins.match "(.+):([0-9]+)" package.meta.position;
                        file = builtins.elemAt match 0;
                        line = builtins.elemAt match 1;
                        relativeFile = lib.removePrefix basePathSlash file;
                        basePathSlash = "${basePath}/";
                      in
                      if lib.hasPrefix basePathSlash file then
                        "<a href=\"${repoBaseUrl}/${relativeFile}#L${line}\" target=\"_blank\"><code>${relativeFile}:${line}</code></a>"
                      else
                        "<code>${package.meta.position}</code>"
                    }</p>"
                  }
                </details></li>
              ''
            else
              ''
                <li><code>${attr}</code> (not a derivation)</li>
              ''
          ) packages}
        </ul>
      </body>
    </html>
  '';

  meta.description = "HTML file listing all packages in this repository with their descriptions and links";
}
