module Evaluator.StatementEval (evalStatement) where
import Data.Base
import Control.Monad.State
import Evaluator.Util
import Evaluator.BoolEval
import Evaluator.NumericEval
import Robot.Base
import System.HIDAPI hiding (error)
import MBot hiding (Command)

evalExp :: Exp -> MyState
evalExp (BExp  e) = evalBoolExp e
evalExp (NExp  e) = evalNumExp  e
evalExp (Input c) = evalInput   c

evalInput :: INCommand -> MyState
evalInput LineLeft  = do {d <- getDevice;x <-liftIO (readLine SensorL (getDevice' d)); (return . Boolean) x  }
evalInput LineRight = do {d <- getDevice;x <-liftIO (readLine SensorR (getDevice' d)); (return . Boolean) x  }
evalInput ReadUltra = do {d <- getDevice;x <-liftIO (readUltra (getDevice' d)); (return . Num) x  }

evalStatement :: Statement -> MyState
evalStatement (ExpStatement e)   = evalExp e
evalStatement (Statements s1 s2) = evalStatement s1 >> evalStatement s2
evalStatement (If b s)           = evalStruct b s $ evalStatement s >> return Void
evalStatement (While b s)        = evalStruct b s $ evalStatement s >> evalStatement (While b s)
evalStatement (Assign s e)       = evalAssign s e
evalStatement (Output t e)       = evalCommand t e

evalCommand :: OUTCommand -> Exp -> MyState
evalCommand Print (NExp e)      = evalPrint (evalNumExp e)  getNum
evalCommand Print (BExp e)      = evalPrint (evalBoolExp e) getBool
evalCommand MotorRight e        = evalMotor e MotorR
evalCommand MotorLeft  e        = evalMotor e MotorL



evalInput' :: (Device -> IO a) -> (a -> ReturnValue) -> MyState
evalInput' f c = do {d <- getDevice;x <-liftIO (f (getDevice' d)); (return . c) x  }

evalPrint :: (Show a) => MyState -> (ReturnValue -> a) -> MyState
evalPrint e f = e >>= (liftIO . print . f) >> return Void

evalMotor :: Exp -> Motor ->  MyState
evalMotor e m = do { x <- evalExp e; d <- getDevice;liftIO (move ((floor .getNum) x) m (getDevice' d)); return Void }

evalStruct :: Exp -> Statement -> MyState -> MyState
evalStruct b s f = evalExp b >>= check
  where check (Boolean True)  = f
        check (Boolean False) = return Void
        check x               = error impossibleState

evalAssign :: String -> Exp -> MyState
evalAssign st e = evalExp e >>= insert st
