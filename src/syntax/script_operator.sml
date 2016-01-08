structure ScriptOperator : OPERATOR =
struct
  open ScriptOperatorData SortData

  structure Arity = Arity

  type 'i t = 'i script_operator

  local
    fun * (a, b) = (a, b) (* symbols sorts, variable sorts *)
    fun <> (a, b) = (a, b) (* valence *)
    fun ->> (a, b) = (a, b) (* arity *)
    fun ^ (x, n) = List.tabulate (n, fn _ => x)
    infix 5 <> ->>
    infix 6 * ^
  in
    fun arity (BIND {bindings}) =
          [ [] * [] <> TAC
          , (EXP ^ bindings) * [] <> TAC
          ] ->> TAC
      | arity (PAR) =
          [ [] * [] <> VEC TAC
          ] ->> TAC
      | arity (FOCUS _) =
          [ [] * [] <> TAC
          ] ->> TAC
      | arity (INTRO ({hasTerm,...}, _)) =
          (if hasTerm then [[] * [] <> EXP] else [])
            ->> TAC
      | arity (ELIM ({hasTerm,...}, _)) =
          (if hasTerm then [[] * [] <> EXP] else [])
            ->> TAC
      | arity (HYP _) =
          [] ->> TAC
  end

  fun support (ELIM ({target,...}, _)) = [(target, EXP)]
    | support (HYP ({target}, _)) = [(target, EXP)]
    | support _ = []

  structure Presheaf =
  struct
    type 'i t = 'i t
    fun map f (BIND p) = BIND p
      | map f PAR = PAR
      | map f (FOCUS p) = FOCUS p
      | map f (INTRO p) = INTRO p
      | map f (ELIM ({target, hasTerm}, m)) =
          ELIM ({target = f target, hasTerm = hasTerm}, m)
      | map f (HYP ({target}, m)) =
          HYP ({target = f target}, m)
  end

  structure Eq =
  struct
    type 'i t = 'i t
    fun eq f (BIND p1, BIND p2) = p1 = p2
      | eq f (PAR, PAR) = true
      | eq f (FOCUS p1, FOCUS p2) = p1 = p2
      | eq f (INTRO (p1, _), INTRO (p2, _)) = p1 = p2
      | eq f (ELIM (p1, _), ELIM (p2, _)) =
          f (#target p1, #target p2) andalso
            #hasTerm p1 = #hasTerm p2
      | eq f (HYP (p1, _), HYP (p2, _)) =
          f (#target p1, #target p2)
      | eq _ _ = false
  end

  structure Show =
  struct
    type 'i t = 'i t
    fun toString f (BIND _) = "bind"
      | toString f PAR = "par"
      | toString f (FOCUS {focus,...}) = "focus{" ^ Int.toString focus ^ "}"
      | toString f (INTRO _) = "intro"
      | toString f (ELIM ({target,...}, _)) = "elim[" ^ f target ^ "]"
      | toString f (HYP ({target}, _)) = "hyp[" ^ f target ^ "]"
  end
end