{ lib, ... }:
let
  fs = lib.fileset;
  templateRoot = fs.toSource {
    root = ./.;
    fileset = fs.fileFilter ({ hasExt, ... }: !(hasExt "nix")) ./.;
  };
  resumeFolder = fs.toSource {
    root = ./jobs.shelvacu.com;
    fileset = ./jobs.shelvacu.com/shelvacu-resume.pdf;
  };
  commonConfig = domain: ''
    handle / {
      header Content-Type "text/html; encoding=utf-8"
      templates {
        root ${templateRoot}
      }
      respond `{{include "${domain}/index.html.caddytemplate"}}` 200
    }
  '';
in
{
  "shelvacu.com" = commonConfig "shelvacu.com";
  "jobs.shelvacu.com" = ''
    ${commonConfig "jobs.shelvacu.com"}
    file_server /shelvacu-resume.pdf {
      root ${resumeFolder}
    }
    handle /email {
      header Content-Type text/plain
      respond "Thank you. Send an email with your job offer to jobs-81567@shelvacu.com" 200
    }
  '';
}
