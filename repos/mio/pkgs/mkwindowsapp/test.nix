{
  nixpkgs ? <nixpkgs>,
}:
let
  pkgs = import nixpkgs { };
  writeScript = pkgs.writeScript;

  assertFileExist = path: ''
    test -f "${path}" || echo "ERROR: ${path} is supposed to exist."
  '';

  assertDirectoryExist = path: ''
    test -d "${path}" || echo "ERROR: ${path} is supposed to exist."
  '';

  assertNotExist = path: ''
    test ! -e "${path}" || echo "ERROR: ${path} is not supposed to exist."
  '';

  assertIsSymlink = target: source: ''
    test $(readlink "${source}") == "${target}" || echo "ERROR: ${source} is supposed to be a symlink to ${target}"
  '';

  assertHasContent = text: path: ''
    test $(cat "${path}") == "${text}" || echo "ERROR: ${path} is supposed to contain the content: ${text}"
  '';
in
{
  map_file = pkgs.writeShellScript "map-file-test.bash" ''
    ${builtins.readFile (
      import ./filemap.nix {
        inherit writeScript;
        rsync = pkgs.rsync;
      }
    )}

    declare -i count
    count=1

    setup () {
      echo "TEST $count ------------------------------------------------"
      count+=1  
      fake_root=$(mktemp -d)
      mkdir -p "$fake_root/data"
      mkdir -p "$fake_root/wineprefix/drive_c"
      export WINEPREFIX="$fake_root/wineprefix"
    }

    tearDown () {
      rm -fR "$fake_root"
    }

    # 1. Ensure that when neither of the mapped paths exist that they are not created accidently.
    setup
    map_file "$fake_root/data/path" "drive_c/path"
    persist_file "drive_c/path" "$fake_root/data/path"
    ${assertNotExist "$fake_root/data/path"}
    ${assertNotExist "$fake_root/wineprefix/drive_c/path"}
    tearDown

    # 2. Ensure that when a file exists on the inside (WINEPREFIX) but not on the outside, that the file is copied out and then replaced with a symlink to the outside file.
    setup
    touch "$fake_root/wineprefix/drive_c/file.txt"
    map_file "$fake_root/data/dir/file.txt" "drive_c/file.txt"
    ${assertIsSymlink "$fake_root/data/dir/file.txt" "$fake_root/wineprefix/drive_c/file.txt"}
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    persist_file "drive_c/file.txt" "$fake_root/data/dir/file.txt" 
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    tearDown

    # 3. Ensure that when a directory exists on the inside (WINEPREFIX) but not on the outside, that the directory is copied out and then replaced with a symlink to the outside directory.
    setup
    mkdir -p "$fake_root/wineprefix/drive_c/dir1/dir2"
    touch "$fake_root/wineprefix/drive_c/dir1/file.txt"
    map_file "$fake_root/data/willexist/dir1" "drive_c/dir1"
    touch "$fake_root/wineprefix/drive_c/dir1/dir2/file2.txt"
    ${assertIsSymlink "$fake_root/data/willexist/dir1" "$fake_root/wineprefix/drive_c/dir1"}
    ${assertFileExist "$fake_root/data/willexist/dir1/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/willexist/dir1/dir2"} 
    ${assertFileExist "$fake_root/data/willexist/dir1/dir2/file2.txt"} 
    persist_file "drive_c/dir1" "$fake_root/data/willexist/dir1"
    ${assertFileExist "$fake_root/data/willexist/dir1/file.txt"} 
    ${assertFileExist "$fake_root/data/willexist/dir1/dir2/file2.txt"} 
    ${assertDirectoryExist "$fake_root/data/willexist/dir1/dir2"} 
    tearDown

    # 4. Ensure that when a file exists on the outside but not on the inside (WINEPREFIX), that a symlink is created to the outside file.
    setup
    touch "$fake_root/data/file.txt"
    map_file "$fake_root/data/file.txt" "drive_c/dir/file.txt"
    ${assertIsSymlink "$fake_root/data/file.txt" "$fake_root/wineprefix/drive_c/dir/file.txt"}
    ${assertFileExist "$fake_root/data/file.txt"} 
    persist_file "drive_c/dir/file.txt" "$fake_root/data/file.txt" 
    ${assertFileExist "$fake_root/data/file.txt"} 
    tearDown

    # 5. Ensure that when a directory exists on the outside but not on the inside (WINEPREFIX), that a symlink is created to the outside directory.
    setup
    mkdir -p "$fake_root/data/dir/dir2"
    touch "$fake_root/data/dir/file.txt"
    map_file "$fake_root/data/dir" "drive_c/somewhereelse/dir"
    ${assertIsSymlink "$fake_root/data/dir" "$fake_root/wineprefix/drive_c/somewhereelse/dir"}
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/dir/dir2"} 
    persist_file "drive_c/somewhereelse/dir" "$fake_root/data/dir" 
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/dir/dir2"} 
    tearDown

    # 6. Ensure that when a file exists on the outside and on the inside (WINEPREFIX), that the inside file is replaced with a symlink to the outside file.
    setup
    echo "hello" > "$fake_root/data/file.txt"
    echo "world" > "$fake_root/wineprefix/drive_c/file.txt"
    map_file "$fake_root/data/file.txt" "drive_c/file.txt"
    ${assertIsSymlink "$fake_root/data/file.txt" "$fake_root/wineprefix/drive_c/file.txt"}
    ${assertFileExist "$fake_root/data/file.txt"} 
    ${assertHasContent "hello" "$fake_root/data/file.txt"} 
    persist_file "drive_c/file.txt" "$fake_root/data/file.txt" 
    ${assertFileExist "$fake_root/data/file.txt"} 
    ${assertHasContent "hello" "$fake_root/data/file.txt"} 
    tearDown

    # 7. Ensure that when a directory exists on the outside and on the inside (WINEPREFIX), that files that don't exist on the outside are copied out, file that already exist on the outside are left intact, and the inside directory is replaced with a symlink to the outside.
    setup
    mkdir -p "$fake_root/data/dir1"
    mkdir -p "$fake_root/wineprefix/drive_c/dir1/dir2"
    echo "hello" > "$fake_root/data/dir1/file1.txt"
    echo "hola" > "$fake_root/data/dir1/file2.txt"
    echo "world" > "$fake_root/wineprefix/drive_c/dir1/file1.txt"
    touch "$fake_root/wineprefix/drive_c/dir1/dir2/file3.txt"
    map_file "$fake_root/data/dir1" "drive_c/dir1"
    ${assertIsSymlink "$fake_root/data/dir1" "$fake_root/wineprefix/drive_c/dir1"}
    ${assertDirectoryExist "$fake_root/data/dir1/dir2"} 
    ${assertHasContent "hello" "$fake_root/data/dir1/file1.txt"}
    ${assertHasContent "hola" "$fake_root/data/dir1/file2.txt"}
    ${assertFileExist "$fake_root/data/dir1/dir2/file3.txt"}
    persist_file "drive_c/dir1" "$fake_root/data/dir1" 
    ${assertDirectoryExist "$fake_root/data/dir1/dir2"} 
    ${assertHasContent "hello" "$fake_root/data/dir1/file1.txt"}
    ${assertHasContent "hola" "$fake_root/data/dir1/file2.txt"}
    ${assertFileExist "$fake_root/data/dir1/dir2/file3.txt"}
    tearDown

    # 8. Ensure that when a file exists on the inside (WINEPREFIX) but not on the outside, and the file names are different, that the file is copied out and then replaced with a symlink with the appropriate name to the outside file.
    setup
    touch "$fake_root/wineprefix/drive_c/file.txt"
    map_file "$fake_root/data/dir/anotherfile.txt" "drive_c/file.txt"
    ${assertIsSymlink "$fake_root/data/dir/anotherfile.txt" "$fake_root/wineprefix/drive_c/file.txt"}
    ${assertFileExist "$fake_root/data/dir/anotherfile.txt"} 
    persist_file "drive_c/file.txt" "$fake_root/data/dir/anotherfile.txt" 
    ${assertFileExist "$fake_root/data/dir/anotherfile.txt"} 
    tearDown

    # 9. Ensure that when a file exists on the outside but not on the inside (WINEPREFIX), and the file names are different, that a symlink is created to the outside file using the correct name.
    setup
    touch "$fake_root/data/file.txt"
    map_file "$fake_root/data/file.txt" "drive_c/dir/anotherfile.txt"
    ${assertIsSymlink "$fake_root/data/file.txt" "$fake_root/wineprefix/drive_c/dir/anotherfile.txt"}
    ${assertFileExist "$fake_root/data/file.txt"} 
    persist_file "drive_c/dir/anotherfile.txt" "$fake_root/data/file.txt" 
    ${assertFileExist "$fake_root/data/file.txt"} 
    tearDown

    # 10. Ensure that when a directory exists on the inside (WINEPREFIX) but not on the outside, and the directory names are different, that the directory is replaced with a symlink to the outside directory using the correct name.
    setup
    mkdir -p "$fake_root/wineprefix/drive_c/dir1/dir2"
    touch "$fake_root/wineprefix/drive_c/dir1/file.txt"
    map_file "$fake_root/data/willexist/somedir" "drive_c/dir1"
    ${assertIsSymlink "$fake_root/data/willexist/somedir" "$fake_root/wineprefix/drive_c/dir1"}
    ${assertFileExist "$fake_root/data/willexist/somedir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/willexist/somedir/dir2"} 
    persist_file "drive_c/dir1" "$fake_root/data/willexist/somedir"
    ${assertFileExist "$fake_root/data/willexist/somedir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/willexist/somedir/dir2"} 
    #tearDown

    # 11. Ensure that when a directory exists on the outside but not on the inside (WINEPREFIX), and the directory names are different, that a symlink is created to the outside directory using the correct name.
    setup
    mkdir -p "$fake_root/data/dir/dir2"
    touch "$fake_root/data/dir/file.txt"
    map_file "$fake_root/data/dir" "drive_c/somewhereelse/somedir"
    ${assertIsSymlink "$fake_root/data/dir" "$fake_root/wineprefix/drive_c/somewhereelse/somedir"}
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/dir/dir2"} 
    persist_file "drive_c/somewhereelse/somedir" "$fake_root/data/dir" 
    ${assertFileExist "$fake_root/data/dir/file.txt"} 
    ${assertDirectoryExist "$fake_root/data/dir/dir2"} 
    tearDown

    # 12. Ensure that when a file exists on the outside and on the inside (WINEPREFIX), and the file names are different, that the inside file is replaced with a symlink to the outside file with the correct name.
    setup
    echo "hello" > "$fake_root/data/file.txt"
    echo "world" > "$fake_root/wineprefix/drive_c/somefile.txt"
    map_file "$fake_root/data/file.txt" "drive_c/somefile.txt"
    ${assertIsSymlink "$fake_root/data/file.txt" "$fake_root/wineprefix/drive_c/somefile.txt"}
    ${assertFileExist "$fake_root/data/file.txt"} 
    ${assertHasContent "hello" "$fake_root/data/file.txt"} 
    persist_file "drive_c/file.txt" "$fake_root/data/file.txt" 
    ${assertFileExist "$fake_root/data/file.txt"} 
    ${assertHasContent "hello" "$fake_root/data/file.txt"} 
    tearDown

    # 13. Ensure that when a directory exists on the outside and on the inside (WINEPREFIX), and the directory names are different, that files that don't exist on the outside and copied out, file that already exist on the outside are left intact, and the inside directory is replaced with a symlink to the outside using the correct name.
    setup
    mkdir -p "$fake_root/data/dir1"
    mkdir -p "$fake_root/wineprefix/drive_c/somedir1/dir2"
    echo "hello" > "$fake_root/data/dir1/file1.txt"
    echo "hola" > "$fake_root/data/dir1/file2.txt"
    echo "world" > "$fake_root/wineprefix/drive_c/somedir1/file1.txt"
    touch "$fake_root/wineprefix/drive_c/somedir1/dir2/file3.txt"
    map_file "$fake_root/data/dir1" "drive_c/somedir1"
    ${assertIsSymlink "$fake_root/data/dir1" "$fake_root/wineprefix/drive_c/somedir1"}
    ${assertDirectoryExist "$fake_root/data/dir1/dir2"} 
    ${assertHasContent "hello" "$fake_root/data/dir1/file1.txt"}
    ${assertHasContent "hola" "$fake_root/data/dir1/file2.txt"}
    ${assertFileExist "$fake_root/data/dir1/dir2/file3.txt"}
    persist_file "drive_c/somedir1" "$fake_root/data/dir1" 
    ${assertDirectoryExist "$fake_root/data/dir1/dir2"} 
    ${assertHasContent "hello" "$fake_root/data/dir1/file1.txt"}
    ${assertHasContent "hola" "$fake_root/data/dir1/file2.txt"}
    ${assertFileExist "$fake_root/data/dir1/dir2/file3.txt"}
    tearDown

    # 14. Ensure that when neither of the mapped paths exist when mapped, but are created before "unmapping", that they are persisted.
    setup
    map_file "$fake_root/data/file1" "drive_c/file1"
    map_file "$fake_root/data/dir" "drive_c/dir"
    ${assertNotExist "$fake_root/data/file1"}
    ${assertNotExist "$fake_root/data/dir"}
    ${assertNotExist "$fake_root/wineprefix/drive_c/file1"}
    ${assertNotExist "$fake_root/wineprefix/drive_c/dir"}
    touch "$fake_root/wineprefix/drive_c/file1"
    mkdir -p "$fake_root/wineprefix/drive_c/dir"
    touch "$fake_root/wineprefix/drive_c/dir/file2"
    persist_file "drive_c/file1" "$fake_root/data/file1" 
    persist_file "drive_c/dir" "$fake_root/data/dir" 
    ${assertFileExist "$fake_root/data/file1"}
    ${assertDirectoryExist "$fake_root/data/dir"}
    ${assertFileExist "$fake_root/data/dir/file2"}
    tearDown
  '';
}
