module Evaluator.Util where
import Control.Monad.State
import Data.Base

evalBOp :: Monad m => (t1 -> t1 -> b) -> t -> t -> (t -> m t1) -> m b
evalBOp f x y e = do {x' <- e x; y' <- e y; return (f x' y')}

evalUOp :: Monad m => (t -> b) -> t1 -> (t1 -> m t) -> m b
evalUOp f x e   = do {x' <- e x; return (f x')}

assignFirst :: String -> BooleanExpr ->  (BooleanExpr -> (StateT (Env2D) IO (Bool))) -> (StateT (Env2D) IO (Bool))
assignFirst st x e = e x >>= \y -> state $ \s -> (y,(setEnv s st y))
  where setEnv (b, d) st x = ((st, x):(removeVar st b),d)

assignSecond :: String -> NumericExp ->  (NumericExp -> (StateT (Env2D) IO (Double))) -> (StateT (Env2D) IO (Double))
assignSecond st x e = e x >>= \y -> state $ \s -> (y,(setEnv s st y))
  where setEnv (b, d) st x = (b,(st, x):(removeVar st d))

lookup' x env =  maybe (error varNotFound) id (lookup x env)

getVar :: String -> (Env2D -> Env b) -> (StateT (Env2D) IO (b))
getVar x f = state $ \s -> (lookup' x (f s),s)

removeVar :: String -> Env a -> Env a
removeVar s env = filter (matchVar s) env
  where matchVar s (k, v) = (k/=s)