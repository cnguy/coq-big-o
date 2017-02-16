Require Complexity.Util.Admitted.
Require Import Complexity.BigO.Notation.
Require Import Complexity.Util.DecField.
Require Import MathClasses.interfaces.abstract_algebra.
Require Import MathClasses.interfaces.orders.
Require Import MathClasses.interfaces.vectorspace.
Require Import MathClasses.orders.dec_fields.

(**
  Informal proof/overview:
  Assume x ∈ Θ(y). Then
    - x ∈ O(y): ∃ k_O > 0 and ∃ n_O > 0 such that ∀ n > n_O, x(n) ≤ k_O ⋅ y(n). 
    - x ∈ Ω(y): ∃ k_Ω > 0 and ∃ n_Ω > 0 such that ∀ n > n_Ω, k_Ω ⋅ y(n) ≤ x(n). 

  [ y ∈ O(x) ]
  By assumption, we have
    - ∀ n > n_Ω, k_Ω ⋅ y(n) ≤ x(n)
  so
    - ∀ n > n_Ω, y(n) ≤ 1/k_Ω ⋅ x(n)

  [ y ∈ Ω(x) ]
  By assumption, we have
    - ∀ n > n_O, y(n) ≤ k_O ⋅ x(n)
  so
    - ∀ n > n_O, 1/k_O ⋅ y(n) ≤ x(n)
  *)

Section BigThetaSymmetry.
  Context `{@SemiNormedSpace
              K V
              Ke Kle Kzero Knegate Kabs Vnorm Ke Kplus Kmult Kzero Kone Knegate Krecip
              Ve Vop Vunit Vnegate smkv
           }.
  Context `{!FullPseudoSemiRingOrder Kle Klt}.
  Context `{forall x y : K, Decision (x = y)}.

  Lemma big_Theta_sym: symmetric _ big_Theta.
    unfold symmetric.
    intros f g big_Theta_f_g.
    unfold big_Theta in *.
    split.
    { (* big_O x y /\ big_Omega x y -> big_O y x *)
      unfold big_O.
      destruct big_Theta_f_g as [HO HΩ].

      (* Unfurl our hypotheses *)
      unfold big_Omega in HΩ.
      destruct HΩ as [k_Ω HΩ].
      destruct HΩ as [k_Ω_gt_0 HΩ].
      destruct HΩ as [n0_Ω HΩ].
      destruct HΩ as [n0_Ω_gt_0 HΩ].

      exists (/k_Ω).
      split.
      {(* 1/k_O > 0 *)
        now apply MathClasses.orders.dec_fields.pos_dec_recip_compat.
      }
      { (* ∃ n0, etc. *)
        exists n0_Ω.
        split; try assumption.
        intros n n_geq_n0_Ω.

        assert (mult_inv_eq_1 : (/ k_Ω) * k_Ω = 1) by
          (now apply dec_recip_inverse_ge_0).

        assert (inv_k_Ω_gt_0 : 0 < / k_Ω) by
            (now apply MathClasses.orders.dec_fields.pos_dec_recip_compat).

        (* y n -> k_O / k_O * y n *)
        setoid_replace (∥g n∥) with (1 * ∥g n∥) by (now rewrite left_identity).
        (* This is awkward, but causes Coq not to automagically multiply
            (/ k_O) * k_O *)
        rewrite <- mult_inv_eq_1.

        rewrite <- associativity.
        apply order_preserving.
        - now apply (order_preserving_mult (/ k_Ω)).
        - now apply HΩ.
      }
    }
    { (* big_O x y /\ big_Omega x y -> big_Omega y x *)
      unfold big_Omega.
      (* Unfurl our assumptions *)
      destruct big_Theta_f_g as [HO HΩ].
      unfold big_O in HO.
      destruct HO as [k_O HO].
      destruct HO as [k_O_gt_0 HO].
      destruct HO as [n0_O HO].
      destruct HO as [n0_O_gt_0 HO].

      exists (/k_O).
      split.
      {(* 1/k_O > 0 *)
        now apply MathClasses.orders.dec_fields.pos_dec_recip_compat.
      }
      {
        (* ∃ n0, etc. *)
        exists n0_O.
        split; try assumption.
        intros n n_geq_n0_O.

        assert (inv_k_Ω_gt_0 : 0 < / k_O) by
            (now apply MathClasses.orders.dec_fields.pos_dec_recip_compat).

        (* y n -> k_O / k_O * y n *)
        setoid_replace (∥g n∥) with (1 * ∥g n∥) by (now rewrite left_identity).
        (* This is awkward, but causes Coq not to automagically multiply
            (/ k_O) * k_O*)
        assert (mult_inv_eq_1 : (/ k_O) * k_O = 1) by
          (now apply dec_recip_inverse_ge_0).
        rewrite <- mult_inv_eq_1.

        rewrite <- associativity.
        apply order_preserving.
        - now apply (order_preserving_mult (/ k_O)).
        - now apply HO.
      }
    }
  Qed.
End BigThetaSymmetry.