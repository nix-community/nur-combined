{
  writeScriptBin,
  python3,
}:
let
  py = python3.withPackages (p: with p; [ tinytag ]);
in
writeScriptBin "rename_music" ''
#!${py}/bin/python
import tinytag
import sys
import os

basepath = sys.argv[1]

def scandir(path):
    with os.scandir(path) as entries:
        for entry in entries:
            if entry.is_file():
                filedir = entry.path
                file_ext = os.path.splitext(entry.name)[-1][1:]
                if file_ext in [ "mp1", "mp2", "mp3", "oga", "ogg", "opus", "spx", "wav", "flac", "wma", "m4b", "m4a", "m4r", "m4v", "mp4", "aax", "aaxc", "aiff", "aifc", "aif", "afc" ]:
                    try:
                        tag = tinytag.TinyTag.get(filedir)
                        new_file_name = f"{str(tag.track).zfill(2)} - {tag.artist} - {tag.album} - {tag.title}.{file_ext}"
                        os.rename(filedir,os.path.join(path,new_file_name))
                        print(f"rename {new_file_name} success!")
                    except tinytag.tinytag.TinyTagException:
                        print("Please add metadata to the file before using this script.")
                        pass
            elif entry.is_dir():
                scandir(os.path.join(path, entry.name))

scandir(basepath)
''
