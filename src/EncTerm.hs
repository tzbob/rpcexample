module EncTerm(EncTerm(..), EncValue, subst, substs) where


import Term(Location)

--
type EncValue = EncTerm -- Var x, Lam a xs m, Const i

data EncTerm = 
        Const Int
    | Var String
    | Lam Location [String] EncTerm 
    | Call EncValue  [EncValue]
    | Req EncValue [EncValue]
    | Let String EncTerm EncTerm 
    | LetApp String EncValue [EncValue] EncTerm 
    | LetReq String EncValue [EncValue] EncTerm 

--
subst :: EncTerm -> String -> EncValue -> EncTerm 
subst m@(Const i) x v = m
subst m@(Var y) x v = 
    if x == y then v else m
subst m@(Call f ws) x v = Call (subst f x v) (map (\w -> subst w x v) ws)
subst m@(Req f ws) x v = Req (subst f x v) (map (\w -> subst w x v) ws)
subst m@(Let y m1 m2) x v = 
    Let y (subst m1 x v) 
        (if x == y then m2 else subst m2 x v)
subst m@(LetApp y f ws m1) x v = 
    LetApp y (subst f x v) (map (\w -> subst w x v) ws) 
        (if x == y then m1 else subst m1 x v)
subst m@(LetReq y f ws m1) x v = 
    LetReq y (subst f x v) (map (\w -> subst w x v) ws) 
        (if x == y then m1 else subst m1 x v)


substs :: EncTerm -> [String] -> [EncValue] -> EncTerm 
substs m [] [] = m 
substs m (x:xs) (v:vs) = substs (subst m x v) xs vs 
substs m _ _ = error ("Error in substs: the lengths of vars and vals are different")

