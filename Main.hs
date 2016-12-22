module Main where
import Control.Applicative (Alternative(..))
import Control.Monad.State
import Control.Monad
import Parser.Base
import Parser.NumericParser
import Parser.BoolParser
import Data.Base
import Parser.Util
import Evaluator.StatementEval
import Data.Char
import Parser.StatementParser



parseAll :: String -> Statement
parseAll s = parseResult parseStatement (dropWhile isSpace s)

eval :: String -> IO ((), Env2D)
eval s =(runStateT  (evalStatement (parseAll s)) emptyEnv2D)

main :: IO ()
main = do {x <- readFile "AlphiExamples/demo2.alp";
           putStrLn $ show $  parseAll x;
            y <- eval x ;
           putStrLn $ show $  y;;}
