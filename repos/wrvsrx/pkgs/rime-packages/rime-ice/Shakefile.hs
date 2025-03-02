{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}

module Shakefile (main) where

import Data.Aeson ((.=))
import Data.Aeson qualified as A
import Data.Aeson.KeyMap qualified as A
import Data.ByteString qualified as B
import Data.ByteString.UTF8 qualified as BU
import Data.Function ((&))
import Data.List.Extra (intercalate, replace)
import Data.Maybe (fromJust)
import Data.Tree qualified as Tr
import Data.Yaml qualified as Y
import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util
import Text.Printf (printf)
import Text.RawString.QQ (r)

type Component = Tr.Tree (String, Action ())

main :: IO ()
main = shakeArgs shakeOptions $ do
  want ["all"]
  renderComponentClosure all'
  renderComponent all'
  renderComponentToNix all'
  phony "nix" $ do
    let
      allName = filter (/= "all-nix") (map fst (Tr.flatten all'))
    need (map (<> "-nix") allName)
    copyFileChanged "Shakefile.hs" (buildDir </> "nix" </> "Shakefile.hs")
    writeFileChanged
      (buildDir </> "nix" </> "default.nix")
      $ printf
        [r|{ source }:
self:
{
%s
}
|]
        ( unlines $
            map
              ( \name -> printf [r|%s = self.callPackage ./%s { inherit source; };|] ("rime-ice-" <> name) ("rime-ice-" <> name)
              )
              allName
        )
 where
  buildDir = "build"
  renderComponentClosure :: Component -> Rules ()
  renderComponentClosure (Tr.Node (name, act) children) = do
    phony (name <> "-closure") $ do
      need (map ((<> "-closure") . fst . Tr.rootLabel) children)
      act
    mapM_ renderComponentClosure children
  renderComponent :: Component -> Rules ()
  renderComponent (Tr.Node (name, act) children) = do
    phony name act
    mapM_ renderComponent children

  cnDicts' = Tr.Node ("cn_dicts", copyFolderAction "cn_dicts" "*.dict.yaml") []
  enDicts' = Tr.Node ("en_dicts", copyFolderAction "en_dicts" "*.dict.yaml") []
  lua' =
    Tr.Node
      ( "lua"
      , do
          copyFolderAction "lua" "*.lua"
          writeFileChanged (buildDir </> "lua" </> "force_gc.lua") "local function force_gc()\ncollectgarbage(\"step\")\nend\nreturn force_gc"
      )
      []
  opencc' = Tr.Node ("opencc", copyFolderAction "opencc" "*") []
  common' =
    Tr.Node
      ( "common"
      , do
          cnt <- readFile' "default.yaml"
          let
            bs = BU.fromString cnt
            obj = bs & Y.decodeEither' & either (error . show) id :: Y.Object
            obj' = obj & A.filterWithKey (\k _ -> k == "punctuator")
          copyFileChanged "symbols_caps_v.yaml" (buildDir </> "symbols_caps_v.yaml")
          writeFileChanged (buildDir </> "rime_ice_common.yaml") (BU.toString (Y.encode obj'))
          writeFileChanged
            (buildDir </> "rime_ice_default_patch.yaml")
            ( BU.toString
                ( Y.encode
                    ( A.object
                        [ "switcher/save_options/+"
                            .= ( [ "ascii_mode"
                                 , "emoji"
                                 , "search_single_char"
                                 , "traditionalization"
                                 ] ::
                                  [String]
                               )
                        , "recognizer/patterns/uppercase" .= A.Null
                        , "punctuator" .= A.object ["__include" .= ("rime_ice_common:/punctuator" :: String)]
                        ]
                    )
                )
            )
      )
      []
  meltEngStr = "melt_eng"
  meltEngSchema' =
    Tr.Node
      ( meltEngStr
      , do
          copyFileChanged "melt_eng.dict.yaml" (buildDir </> "melt_eng.dict.yaml")
          copyFileChanged "melt_eng.schema.yaml" (buildDir </> "melt_eng.schema.yaml")
      )
      [enDicts']
  radicalPinyinStr = "radical_pinyin"
  radicalPinyinSchema' =
    let
      dict = radicalPinyinStr <> ".dict.yaml"
      schema = radicalPinyinStr <> ".schema.yaml"
     in
      Tr.Node
        ( radicalPinyinStr
        , do
            copyFileChanged dict (buildDir </> dict)
            copyFileChanged schema (buildDir </> schema)
        )
        []
  rimeIceDict' = Tr.Node ("pinyin-dict", copyFileChanged "rime_ice.dict.yaml" (buildDir </> "rime_ice.dict.yaml")) [cnDicts']
  doubleFly' =
    let
      name = "flypy"
     in
      Tr.Node
        ( name
        , do
            cnt <- readFile' ("double_pinyin_" <> name <> ".schema.yaml")
            let
              radicalDerivedId = radicalPinyinStr <> "_" <> name
              melgEngDerivedId = meltEngStr <> "_" <> name
              cnt' =
                cnt
                  & replace ("double_pinyin_" <> name) ("rime_ice_double_pinyin_" <> name)
                  & replace ("- " <> meltEngStr) ("- " <> melgEngDerivedId)
                  & replace
                    (printf "%s:\n  dictionary: %s" meltEngStr meltEngStr)
                    (printf "%s:\n  prism: %s\n  dictionary: %s" meltEngStr melgEngDerivedId meltEngStr)
                  & replace ("- " <> radicalPinyinStr) ("- " <> radicalDerivedId)
                  & replace
                    (printf "  dictionary: %s" radicalPinyinStr)
                    (printf "  prism: %s\n  dictionary: %s" radicalDerivedId radicalPinyinStr)
                  & replace
                    ("@" <> radicalPinyinStr)
                    ("@" <> radicalDerivedId)
              radicalDerivedCnt :: String =
                printf
                  [r|
schema:
  schema_id: radical_pinyin_%s
__include: radical_pinyin.schema:/
__patch:
  "speller/algebra":
    __include: radical_pinyin.schema:/algebra_%s
  "translator/prism": radical_pinyin_%s
|]
                  name
                  name
                  name
              melgEngDerivedCnt :: String =
                printf
                  [r|
schema:
  schema_id: melt_eng_%s
__include: melt_eng.schema:/
__patch:
  "speller/algebra":
    __include: melt_eng.schema:/algebra_%s
  "translator/prism": melt_eng_%s
|]
                  name
                  name
                  name
            writeFileChanged (buildDir </> "rime_ice_double_pinyin_" <> name <> ".schema.yaml") cnt'
            writeFileChanged (buildDir </> radicalDerivedId <> ".schema.yaml") radicalDerivedCnt
            writeFileChanged (buildDir </> melgEngDerivedId <> ".schema.yaml") melgEngDerivedCnt
            let
              cnEnUserDict = "en_dicts" </> "cn_en_" <> name <> ".txt"
            copyFileChanged cnEnUserDict (buildDir </> cnEnUserDict)
        )
        [ lua'
        , common'
        , opencc'
        , rimeIceDict'
        , meltEngSchema'
        , radicalPinyinSchema'
        ]
  all' = Tr.Node ("all", pure ()) [doubleFly']
  copyFolderAction dir pattern = do
    dictList <- getDirectoryFiles "" [dir </> pattern]
    mapM_ (\x -> copyFileChanged x (buildDir </> x)) dictList
  renderComponentToNix :: Component -> Rules ()
  renderComponentToNix (Tr.Node (name, act) children) = do
    phony (name <> "-nix") $
      do
        let
          nixCnt :: String =
            printf
              [r|
{
  stdenvNoCC,
  haskellPackages,
  rimeDataBuildHook,
  librime,
  # we need default.yaml provided by rime-prelude
  rime-prelude,
  source,
  %s
}:
let
  src_ =
    stdenvNoCC.mkDerivation {
      inherit (source) src;
      version = "0-unstable-" + source.date;
      pname = "rime-ice-%s";
      propagatedBuildInputs = [ rime-prelude %s ];
      nativeBuildInputs = [
        (haskellPackages.ghcWithPackages (
          ps: with ps; [
            shake
            yaml
            utf8-string
            raw-strings-qq
          ]
        ))
      ];
      env.LC_CTYPE = "C.UTF-8";
      postPatch = ''
        cp ${../Shakefile.hs} Shakefile.hs
      '';
      buildPhase = ''
        shake %s
      '';
      installPhase = ''
        mkdir -p $out/share/rime-data
        mkdir -p build
        cp -r build/. $out/share/rime-data/
      '';
    };
in
  stdenvNoCC.mkDerivation {
    inherit (src_)
      pname
      version
      propagatedBuildInputs;
    src = "${src_}/share/rime-data";
    nativeBuildInputs = [
      rimeDataBuildHook
      librime
    ];
    installPhase = ''
      rm -rf rime_data_deps/
      mkdir -p $out/share/rime-data/
      cp -r . $out/share/rime-data/
    '';
  }
|]
              (intercalate ", " (map (("rime-ice-" <>) . fst . Tr.rootLabel) children))
              name
              (unwords (map (("rime-ice-" <>) . fst . Tr.rootLabel) children))
              name
         in
          writeFileChanged (buildDir </> "nix" </> "rime-ice-" <> name </> "default.nix") nixCnt
    mapM_ renderComponentToNix children
