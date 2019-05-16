{-# LANGUAGE OverloadedStrings #-}
import qualified Control.Foldl as Fold
import qualified Data.Graph as Graph
import qualified Data.List as List
import qualified Data.List.NonEmpty as List.NonEmpty
import qualified Data.Set as Set
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text.Enc
import qualified Pangraph as Pangraph
import qualified Pangraph.Containers as Pangraph.Graph
import qualified Pangraph.GraphML.Parser as Pangraph.GraphML
import Turtle

buildUnfreeArgs :: Text -> [Text]
buildUnfreeArgs buildUnfree = ["--arg", "buildUnfree", buildUnfree]

getInstantiateArgs :: [Text] -> IO [Text]
getInstantiateArgs args = do
  buildUnfree <- need "BUILD_UNFREE"
  pure $ args ++ maybe [] buildUnfreeArgs buildUnfree

trimOutput :: Text -> Text
trimOutput = fst . Text.breakOn "!"

getDerivationsAndOuts ::
  Turtle.FilePath -> [Text] -> Shell Turtle.FilePath
getDerivationsAndOuts path args = do
  let path' = format fp path
  let args' = path' : "--show-trace" : args
  instantiated <- inprocWithErr "nix-instantiate" args' empty
  either ((*> empty) . err) (pure . fromText . format l) instantiated

getDerivationGraph ::
  [Text] -> IO (Either Text (Maybe (
    Graph.Graph,
    Graph.Vertex -> (Pangraph.Vertex, Pangraph.VertexID, [Pangraph.VertexID]),
    Pangraph.VertexID -> Maybe Graph.Vertex
  )))
getDerivationGraph paths = do
  (graphmlExit, graphml, graphmlErr) <-
    procStrictWithErr "nix-store" ("-q" : "--graphml" : "--" : paths) empty
  if graphmlExit /= ExitSuccess then pure (Left graphmlErr) else do
    stderr (select $ textToLines graphmlErr)
    pure $ Right (Pangraph.Graph.convert <$>
      Pangraph.GraphML.parse (Text.Enc.encodeUtf8 graphml))

derivationBuildOrder ::
  (Ord a) => Set.Set a -> Graph.Graph -> (v -> Maybe a) ->
    (Graph.Vertex -> v) -> Either v [a]
derivationBuildOrder drvs graph drvFromVertex enrichVertex =
  (reverse . filter (`Set.member` drvs)) <$> sequenceA
    ((\v -> maybe (Left v) Right (drvFromVertex v)) . enrichVertex <$>
      Graph.topSort graph)

drvFromVertex :: Pangraph.Vertex -> Maybe Text
drvFromVertex v =
  Text.Enc.decodeUtf8 <$> lookup "id" (Pangraph.vertexAttributes v)

main :: IO ()
main = do
  args <- arguments
  (path, args') <- maybe (die "No path provided.") pure $ List.uncons args
  instantiateArgs <- getInstantiateArgs args'
  let drvsAndOuts = getDerivationsAndOuts (fromText path) args'
  drvs <- fold (uniq $ (trimOutput . format fp) <$> drvsAndOuts) Fold.list
  let drvsSet = Set.fromList drvs
  (drvGraph, drvEnrichVertex, drvLookupVertexId) <-
    (getDerivationGraph drvs) >>=
    (either (die . ("nix-store can't gen GraphML:\n" <>)) pure) >>=
    (maybe (die "GraphML to Pangraph conversion error.") pure)
  drvBuildOrder <- either
    (\v -> die (format ("Couldn't pull derivation from: "%w) v))
    pure
    (derivationBuildOrder drvsSet drvGraph drvFromVertex
      ((\(x, _, _) -> x) . drvEnrichVertex))
  stdout $ select . concatMap (List.NonEmpty.toList . textToLines) $
    drvBuildOrder
