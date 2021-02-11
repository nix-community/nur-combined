# this function allows you to lazily import git submodules whenever you need to import them or use them as a package source
# moduleFile is your .gitmodules file, it contains the links to the submodules you want to include
# statusFile is the output of `git submodule`, written in a file. it allows us to use the rev of a git repository, so taht we can pin it
# root is the repository root. It should be the folder where your .gitmodules file is located.
{ moduleFile ? root + "/.gitmodules", statusFile ? root + "/SUBMODULE_STATUS", root }: path:
let
  inherit (builtins) fetchGit filter head isList pathExists readFile replaceStrings split stringLength substring tail trace toString;
  inherit (import ./utils.nix) fix quickElem zipWith;
  fileName = replaceStrings [ ((toString root) + "/") ] [ "" ] (toString path);
  module = readFile moduleFile;
  status = readFile statusFile;
  moduleData = filter isList (split "path = ([^\n]*)\n[ \t]+url = ([^\n]*)" module);
  statusData = filter isList (split "-([0-9a-z]+) ([^\n]*)\n" status);
  findMatchingStatus = quickElem (i: head (filter (quickElem (j: (j 1) == (i 0))) statusData));
  repoData =
    let
      dataList = map (x: x ++ (findMatchingStatus x)) moduleData;
    in
    map (quickElem (i: { path = i 0; url = i 1; rev = i 2; })) dataList;
  repo = fix
    (f: repolist:
      let
        current = head repolist;
        fileStart = substring 0 (stringLength current.path) fileName;
        rest = replaceStrings [ fileStart ] [ "" ] fileName;
      in
      if current.path == fileStart && (substring 0 1 rest) == "/" then current else f (tail repolist))
    repoData;
  newName =
    let
      src = fetchGit { inherit (repo) url rev; };
    in
    replaceStrings [ repo.path ] [ src.outPath ] fileName;
in
if pathExists path then path else newName
