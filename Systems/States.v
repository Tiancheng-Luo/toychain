From mathcomp.ssreflect
Require Import ssreflect ssrbool ssrnat eqtype ssrfun seq fintype.
From mathcomp
Require Import path.
Require Import Eqdep Relations.
From HTT
Require Import pred prelude idynamic ordtype pcm finmap unionmap heap.
From Toychain
Require Import SeqFacts Chains Blocks Forests Protocol.
Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Module Type BLOCKCHAIN_STATE (Import BC : BLOCKCHAIN) (Import BCF : BLOCKCHAIN_FACTS BC) (Import BCP : BLOCKCHAIN_PROTOCOL BC BCF).

Definition Address_ordMixin := fin_ordMixin Address.
Canonical Address_ordType := Eval hnf in OrdType Address Address_ordMixin.

Definition StateMap := union_map [ordType of Address] State.

Definition initState' s : StateMap := foldr (fun a m => (a \\-> Init a) \+ m) Unit s.

(* Master-lemma, proving a conjunction of two mutually-necessary facts *)
Axiom initStateValidDom : forall s,
  uniq s -> dom (initState' s) =i s /\ valid (initState' s).

Axiom valid_initState' : forall s, uniq s -> valid (initState' s).

Axiom dom_initState' : forall s, uniq s -> dom (initState' s) =i s.

Definition initState := initState' (enum Address).

End BLOCKCHAIN_STATE.

Module BlockChainState (Import BC : BLOCKCHAIN) (Import BCF : BLOCKCHAIN_FACTS BC) (Import BCP : BLOCKCHAIN_PROTOCOL BC BCF) : BLOCKCHAIN_STATE BC BCF BCP.

Definition Address_ordMixin := fin_ordMixin Address.
Canonical Address_ordType := Eval hnf in OrdType Address Address_ordMixin.

Definition StateMap := union_map [ordType of Address] State.

Definition initState' s : StateMap := foldr (fun a m => (a \\-> Init a) \+ m) Unit s.

(* Master-lemma, proving a conjunction of two mutually-necessary facts *)
Lemma initStateValidDom s :
  uniq s -> dom (initState' s) =i s /\ valid (initState' s).
Proof.
elim: s => /=[|a s']; first by rewrite valid_unit dom0.
move => IH.
move/andP => [H_ni H_u].
move/IH: H_u => [H1 H2] {IH}.
split; last first.
- case: validUn; rewrite ?um_validPt ?H2//.
  move=>k; rewrite um_domPt inE=>/eqP Z; subst k.
  rewrite H1.
  by move/negP: H_ni.
- move=>z; rewrite domUn !inE !um_domPt !inE.
  rewrite H1.
  case validUn.
  * by move/negP => H_v; case: H_v; rewrite um_validPt.
  * by move/negP.
  * move => k.
    rewrite H1.
    rewrite um_domPt inE=>/eqP H_eq.
    rewrite -H_eq => H_in.
    by move/negP: H_ni.
  * move => Hv1 Hv2 H_d.
    by rewrite eq_sym.
Qed.

Lemma valid_initState' s : uniq s -> valid (initState' s).
Proof. by move => H_u; case: (initStateValidDom H_u). Qed.

Lemma dom_initState' s : uniq s -> dom (initState' s) =i s.
Proof. by move => H_u; case: (initStateValidDom H_u). Qed.

Definition initState := initState' (enum Address).

End BlockChainState.
