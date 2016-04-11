structure SquashRules : SQUASH_RULES =
struct
  open RefinerKit OperatorData CttOperatorData SortData
  infix @@ $ \ @>
  infix 2 //
  infix 4 >>
  infix 3 |>

  fun destSquash m =
    case out m of
         CTT (SQUASH tau) $ [_\a] => (tau, a)
       | _ =>
           raise Fail
             @@ "Expected Squash but got "
              ^ DebugShowAbt.toString m

  fun TypeEq _ (G |> H >> TRUE (P, _)) =
    let
      val (tau,a,b,univ) = destEq P
      val (_, a') = destSquash a
      val (_, b') = destSquash b
      val _ = destUniv univ
      val eq =
        check
          (#metactx H)
          (CTT (EQ tau) $ [([],[]) \ a', ([],[]) \ b', ([],[]) \ univ], EXP)
      val (goal, _, _) =
        makeGoal @@
          [] |> H >> TRUE (eq, EXP)
      val psi = T.empty @> goal
    in
      (psi, fn rho =>
        makeEvidence G H makeAx)
    end
    | TypeEq _ _ = raise Match

  fun Intro _ (G |> H >> TRUE (P, _)) =
    let
      val (tau, Q) = destSquash P
      val (goal, _, _) =
        makeGoal @@
          [] |> H >> TRUE (Q, tau)
      val psi = T.empty @> goal
    in
      (psi, fn rho =>
        makeEvidence G H makeAx)
    end
    | Intro _ _ = raise Match

  fun Unhide h _ (G |> H >> TRUE (P, tau)) =
    let
      val _ = destEq P
      val (Q, sigma) = Ctx.lookup (#hypctx H) h
      val (tau', Q') = destSquash Q
      val H' =
        {metactx = #metactx H,
         symctx = #symctx H,
         hypctx = Ctx.modify h (fn _ => (Q', tau')) (#hypctx H)}

      val (goal, _, _) =
        makeGoal @@
          [] |> H' >> TRUE (P, tau)

      val psi = T.empty @> goal
    in
      (psi, fn rho =>
        makeEvidence G H @@
          T.lookup rho (#1 goal) // ([], []))
    end
    | Unhide _ _ _ = raise Match

end