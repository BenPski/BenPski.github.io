--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import qualified Data.Set as S
import           Text.Pandoc.Options
import           Control.Monad (liftM, foldM)
import           Data.Ord (comparing)
import           Data.List (sortBy, sort)
import           Data.Char (toUpper)
import           System.FilePath


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

    match (fromList ["about.markdown", "contact.markdown", "index.markdown"]) $ do
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

    create ["notes.html"] $ do
        route idRoute
        compile $ do
            hier <- buildHier "notes/**"
            let ctxs = hierarchyContext hier
                ctx = constField "title" "Notes" `mappend` defaultContext
            makeItem ""
              >>= templateHierarchyFold ctxs
              >>= loadAndApplyTemplate "templates/default.html" ctx
              >>= relativizeUrls

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

--foldM with the arguments rearranged since it is slightly nicer for its use case
mfold :: (Foldable t, Monad m) => (a -> b -> m b) -> t a -> b -> m b
mfold f xs i = foldM (flip f) i xs

capitalize :: String -> String
capitalize [] = ""
capitalize (s:str) = toUpper s : (subUnderscore str)
  where
    subUnderscore = foldr (\x s -> (if x == '_' then ' ' else x) : s) ""


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

stripHeads :: (Functor f, Eq a) => f ([[a]], b) -> f ([a], ([[a]], b))
stripHeads xs = fmap (\(cats, val) -> if cats == [] then ([],([], val)) else (head cats, (tail cats, val))) xs

groupHeads :: Eq a => [(a, b)] -> [(a, [b])]
groupHeads [] = []
groupHeads (x:xs) = go (fst x) [snd x] (xs)
  where
    go name acc [] = [(name, acc)]
    go name acc (x:xs)
      | fst x == name = go name (snd x : acc) xs
      | otherwise = (name, acc) : go (fst x) [snd x] (xs)

makeHier :: Ord a => [([String], a)] -> [Hierarchy a]
makeHier xs = go xs
  where
    go [] = []
    go xs = let leaves = fmap (\(_, v) -> Leaf v) $ filter (\(a,_) -> a == []) xs
                nodes = filter (\(a,_) -> a /=[]) xs
            in leaves ++ makeNodes nodes
    makeNodes xs = fmap (\(name, items) -> Node name (go items)) $ groupHeads $ stripHeads $ sort xs

buildHier :: MonadMetadata m => Pattern -> m (Hierarchy Identifier)
buildHier pattern = do
  ids <- getMatches pattern
  let info = fmap (\f -> (drop 1 . splitDirectories . takeDirectory . toFilePath $ f, f)) (sort ids)
  return (Node "notes" $ makeHier info)


{-
For flattening to apply the templates
at nodes apply
  node_start
    templates to items
  node_end

Seems like the contexts aren't being passed along properly for some reason
  seems to be when defaultContext becomes instantiated
have to flatten into contexts to apply templates to like in the first iteration?
have to be able to switch between node_start, value, and node_end

Solution is to have the default context be looked up in a listField which is dorky and inelegant, but it works
  definitely seems like there are better ways of doing this, but I'm not seeing them

reverse order of values to get in alphabetical order
-}

hierarchyContext :: Hierarchy Identifier -> [(Identifier, Context String)]
hierarchyContext (Leaf item) = [("templates/value.html", listField "stuff" defaultContext (sequence [load item]) `mappend` defaultContext)]
hierarchyContext (Node "notes" values) = concatMap hierarchyContext values
hierarchyContext (Node name values) = [("templates/node_start.html", constField "name" (capitalize name) `mappend` defaultContext)] ++ concatMap hierarchyContext (reverse values) ++ [("templates/node_end.html", defaultContext)]

templateHierarchyFold :: [(Identifier, Context String)] -> Item String -> Compiler (Item String)
templateHierarchyFold = mfold (\(temp, c) i -> loadAndApplyTemplate temp c i)