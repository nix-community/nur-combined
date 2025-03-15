{
  writeScriptBin,
  python3,
  lib,
}:
let
  py = python3.withPackages (p: with p; [ tinytag ]);
in
writeScriptBin "rename_music" ''
#!${lib.getExe py}
import tinytag
import sys
import os

basepath = os.path.abspath(sys.argv[1])

def scandir(path):
    with os.scandir(path) as entries:
        for entry in entries:
            if entry.is_file():
                file_ext = os.path.splitext(entry.name)[-1]
                if file_ext in tinytag.TinyTag.SUPPORTED_FILE_EXTENSIONS:
                    try:
                        tag = tinytag.TinyTag.get(entry.path)
                        new_file_name = f"{str(tag.track).zfill(2)} - {tag.artist} - {tag.album} - {tag.title}{file_ext}"
                        if entry.name != new_file_name:
                            os.rename(entry.path,os.path.join(path,new_file_name))
                            print(f"rename {new_file_name} success!")
                    except tinytag.tinytag.TinyTagException:
                        print(f"Please add metadata to the file before using this script. {entry.name}")
                        pass
                    except:
                        print(f"Error processing file {entry.name}")
                        pass
            elif entry.is_dir():
                scandir(entry.path)

scandir(basepath)
''
