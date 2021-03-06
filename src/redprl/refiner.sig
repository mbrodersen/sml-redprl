signature REFINER =
sig
  type sign
  type abt
  type catjdg
  type rule
  type tactic
  type hyp
  type opid
  type 'a bview

  val Cut : catjdg -> rule
  val CutLemma : sign -> abt -> rule

  val AutoStep : sign -> tactic
  val NondetStepJdgFromHyp : sign -> tactic
  
  val Elim : sign -> hyp -> tactic
  val Exact : abt -> tactic
  val Rewrite : sign -> hyp Selector.t * Accessor.t list -> abt -> tactic
  val Symmetry : tactic

  val Inversion : hyp -> tactic

  (* synthetic elim rule for nested pi, path and line types *)
  structure MultiArrow : 
  sig
    val Elim : sign -> int -> hyp -> rule
  end

  structure Custom :
  sig
    val UnfoldAll : sign -> opid list -> rule
    val Unfold : sign -> opid list -> hyp Selector.t list -> rule
    val UnfoldPart : sign -> opid list -> hyp Selector.t * Accessor.t list -> rule
  end

  structure Computation :
  sig
    val ReduceAll : sign -> tactic
    val Reduce : sign -> hyp Selector.t list -> rule
    val ReducePart : sign -> hyp Selector.t * Accessor.t list -> rule
  end

  structure Hyp :
  sig
    val Project : hyp -> rule
    val Delete : hyp -> rule
  end

  structure Tactical :
  sig
    val NormalizeGoalDelegate : (abt -> tactic) -> sign -> tactic
    val NormalizeHypDelegate : (abt -> hyp -> tactic) -> sign -> hyp -> tactic
  end

  structure Names : 
  sig
    val Push : hyp list -> rule
    val PopAs : hyp list -> rule
  end

  type rule_name = string
  val lookupRule : sign -> rule_name -> tactic
end
