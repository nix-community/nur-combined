// vim: set shiftwidth=2 :

export type autodetect = enum {
  EXISTING,
  EXISTING_FILE,
  EXISTING_FILE_OR_PARENT,
  EXISTING_OR_PARENT,
  PARENT,
};

fn autodetect_fromstr(v: str) (autodetect | error) = {
  return switch (v) {
    case "existing" => yield autodetect::EXISTING;
    case "existingFile" => yield autodetect::EXISTING_FILE;
    case "existingFileOrParent" => yield autodetect::EXISTING_FILE_OR_PARENT;
    case "existingOrParent" => yield autodetect::EXISTING_OR_PARENT;
    case "parent" => yield autodetect::PARENT;
    case => yield error;
  };
};

