--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import qualified Data.Set as S
import           Text.Pandoc.Options
import           Control.Monad (liftM)
import           Data.Ord (comparing)
import           Data.List (sortBy, sort)
import           Data.Char (toUpper)
import           System.FilePath
import Debug.Trace


--------------------------------------------------------------------------------
deployConfig = defaultConfiguration {deployCommand =  "git stash && git checkout develop && stack exec website clean && stack exec website build && git fetch --all && git checkout -b master --track origin/master && cp -a _site/. . && git add -A && git commit -m \"Publish.\" && git push origin master:master && git checkout develop && git branch -D master && git stash pop" }


main :: IO ()
main = hakyllWith deployConfig $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown", "index.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "notes/**" $ do
        route $ setExtension "html"
        compile $ pandocMathCompiler
            >>= loadAndApplyTemplate "templates/notes.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

--    create ["notes.html"] $ do
--        route idRoute
--        compile $ do
--            cats <- buildCategories "notes/**" fromFilePath
--            let catsMap = tagsMap cats
--            let ctxs = fmap ((\(cat, items) -> constField "name" (capitalize cat) `mappend`
--                                               listField "values" defaultContext (traverse load items) `mappend`
--                                               defaultContext)) catsMap
--
--            let notesCtx = constField "title" "Notes" `mappend`
--                           defaultContext
--
--            makeItem ""
--                >>= templateFold "templates/dump.html" ctxs
--                >>= loadAndApplyTemplate "templates/default.html" notesCtx
--                >>= relativizeUrls

    create ["notes.html"] $ do
        route idRoute
        compile $ do
            hier <- buildHier "notes/**"
            let ctxs = hierarchyContext hier

            let ctx = constField "title" "Notes" `mappend` defaultContext

            makeItem "" >>= templateHierarchyFold ctxs >>= loadAndApplyTemplate "templates/default.html" ctx >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

pandocMathCompiler =
    let mathExtensions = [Ext_tex_math_dollars, Ext_tex_math_double_backslash,
                          Ext_latex_macros]
        defaultExtensions = writerExtensions defaultHakyllWriterOptions
        newExtensions = foldr enableExtension defaultExtensions mathExtensions
        writerOptions = defaultHakyllWriterOptions {
                          writerExtensions = newExtensions,
                          writerHTMLMathMethod = MathJax ""
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions


getDir :: FilePath -> Pattern
getDir = fromGlob .  (++ "/*") . takeWhile (/= '/') . drop 1 .dropWhile  (/= '/') . show

sortByM f xs = liftM (map fst . sortBy (comparing snd)) $ mapM (\x -> liftM (\y -> (x,y)) (f x)) xs

sortCategories :: MonadMetadata m => [Item a] -> m [Item a]
sortCategories = sortByM (\x -> getMetadataField' (itemIdentifier x) "category")

--foldM with the arguments rearranged since it is slightly nicer to have the initial item as the last argument
mfold f [] i = return i
mfold f (x:xs) i = f x i >>= mfold f xs

templateFold temp cs = mfold (\c i -> loadAndApplyTemplate temp c i) cs

capitalize :: String -> String
capitalize [] = ""
capitalize (s:str) = toUpper s : str


data Hierarchy a = Leaf a
                 | Node String [Hierarchy a]
                 deriving (Eq, Show)


{-
To build up the hierarchy for the directory have to
  collect all the files in the directory
  associate the directories to the actual file
  organize them into the hierarchy by grouping them properly by the directory structure
  will get something like
  Node "root" [Node "top1" [Leaf "file1"], Leaf "other"]

then latter once hierarchy is built flatten it into the templates for display
-}
--a bit of an odd function, but its what I have to build from
--take the heat of the directory list
--all the ones that share this form a node where the rest of the list can be further transformed
--any with empty lists are a leaf

stripHeads xs = fmap (\(cats, val) -> if cats == [] then ([],([], val)) else (head cats, (tail cats, val))) xs
groupHeads [] = []
groupHeads (x:xs) = go (fst x) [snd x] (xs)
  where
    go name acc [] = [(name, acc)]
    go name acc (x:xs)
      | fst x == name = go name (snd x : acc) xs
      | otherwise = (name, acc) : go (fst x) [snd x] (xs)
makeHier xs = go xs
  where
    --first strip out leaves from processing
    go [] = []
    go xs = let leaves = fmap (\(_, v) -> Leaf v) $ filter (\(a,_) -> a == []) xs
                nodes = filter (\(a,_) -> a /=[]) xs
            in leaves ++ makeNodes nodes
    makeNodes xs = fmap (\(name, items) -> Node name (go items)) $ groupHeads $ stripHeads xs

buildHier pattern = do
  ids <- getMatches pattern
  let info = fmap (\f -> (drop 1 . splitDirectories . takeDirectory . toFilePath $ f, f)) ids
  return (Node "notes" $ makeHier info)


{-
For flattening to apply the templates
at nodes apply
  node_start
    templates to items
  node_end
-}
--templateHierFold (Leaf item) = let leafCtx = loadAndApplyTemplate "templates/value.html" leafCtx
--templateHierFold (Node name values) = loadAndApplyTemplate "templates/node_start.html" nodeCtx >>= mfold templateHierFold values >>= loadAndApplyTemplate "templates/node_end.html" nodeCtx
--
--templateHierarchyFold :: Hierarchy Identifier -> Item String -> Compiler (Item String)
--templateHierarchyFold (Leaf item) i = let leafCtx = urlField (toFilePath item) `mappend` bodyField (itemBody i) in trace (show item) (loadAndApplyTemplate "templates/value.html" leafCtx i)
--templateHierarchyFold (Node name values) i = let nodeCtx = constField "name" name `mappend` defaultContext
--                                             in return i
--                                                  >>= loadAndApplyTemplate "templates/node_start.html" nodeCtx
--                                                  >>= mfold templateHierarchyFold values
--                                                  >>= loadAndApplyTemplate "templates/node_end.html" defaultContext


{-
Seems like the contexts aren't being passed along properly for some reason
  seems to be when defaultContext becomes instantiated
have to flatten into contexts to apply templates to like in the first iteration?
have to be able to switch between node_start, value, and node_end
-}

hierarchyContext :: Hierarchy Identifier -> [(Identifier, Context String)]
hierarchyContext (Leaf item) = [("templates/value.html", listField "stuff" defaultContext (sequence [load item]) `mappend` defaultContext)]
hierarchyContext (Node "notes" values) = concatMap hierarchyContext values
hierarchyContext (Node name values) = [("templates/node_start.html", constField "name" (capitalize name) `mappend` defaultContext)] ++ concatMap hierarchyContext values ++ [("templates/node_end.html", defaultContext)]

templateHierarchyFold :: [(Identifier, Context String)] -> Item String -> Compiler (Item String)
templateHierarchyFold cs = mfold (\(temp, c) i -> loadAndApplyTemplate temp c i) cs