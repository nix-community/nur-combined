{-# LANGUAGE QuasiQuotes #-}

import Control.Monad.Extra (concatMapM)
import Data.Functor ((<&>))
import Data.List (intercalate, isPrefixOf, isSuffixOf)
import System.Directory (
  doesDirectoryExist,
  doesFileExist,
  listDirectory,
  removeDirectoryRecursive, removeFile,
 )
import System.FilePath (takeBaseName, (</>))
import System.Process (rawSystem)
import Text.Printf (printf)
import Text.RawString.QQ (r)

mesonTemplate :: String
mesonTemplate =
  [r|project(
  'cuda-samples',
  'cpp',
)

# headers
%s

# libriary
%s

pkg = import('pkgconfig')
pkg.generate(
  subdirs: 'cuda-samples',
  filebase: 'cuda-samples',
  version: '@version@',
  name : meson.project_name(),
  description : 'Samples for CUDA Developers which demonstrates features in CUDA Toolkit',
  libraries: [%s],
)
|]

getFilesRecursive :: FilePath -> IO [FilePath]
getFilesRecursive f = do
  isFile <- doesFileExist f
  if isFile
    then return [f]
    else do
      fs <- listDirectory f <&> map (f </>)
      concatMapM getFilesRecursive fs

listDirectoryWithExtension :: String -> FilePath -> IO [FilePath]
listDirectoryWithExtension ext d = listDirectory d <&> filter (ext `isSuffixOf`) <&> map (d </>)

main :: IO ()
main = do
  files <- listDirectory "Common" <&> filter (\x -> ".h" `isSuffixOf` x || ".cpp" `isSuffixOf` x)
  removeDirectoryRecursive "Common/GL"
  removeDirectoryRecursive "Common/data"
  removeDirectoryRecursive "Common/lib"
  listDirectory "Common" <&> filter ("rendercheck_d3d" `isPrefixOf`) <&> map ("Common" </>) >>= mapM_ removeFile
  mapM_
    ( \x ->
        rawSystem "sed" (["-i", printf "s/<%s>/\"%s\"/g" x x] <> map ("Common" </>) files)
    )
    files
  headerFiles <- listDirectoryWithExtension ".h" "Common"
  nppHeaderFiles <- listDirectoryWithExtension ".h" "Common/UtilNPP"
  cppFiles <- listDirectoryWithExtension ".cpp" "Common"
  let
    cppPart = unlines $ map (\x -> printf [r|%s = library('%s', '%s', install : true)|] (takeBaseName x) (takeBaseName x) x) cppFiles
    headerPart = unlines $ map (\x -> printf [r|install_headers('%s', subdir : 'cuda-samples/Common')|] x) headerFiles
    nppHeaderPart = unlines $ map (\x -> printf [r|install_headers('%s', subdir : 'cuda-samples/Common/UtilNPP')|] x) nppHeaderFiles
    libraryPart = intercalate "," (map takeBaseName cppFiles)
    mesonContent :: String = printf mesonTemplate (headerPart <> "\n" <> nppHeaderPart) cppPart libraryPart
  putStr mesonContent
