Speaker and listener *and literal* (i.e. make sure listener knows that speaker knows that listener knows...) have in common ground:
	* ☑ prob_of_causal_link
	* ☑ parent_prior_prob
	* ☑ causal_strength
	* ☑ effect_background_prior_prob
	* ☑ causal_structure_prior
	* ☑ actual states of A, B, and E

Some of those should be marginalized:
	* ☐ prob_of_causal_link
	* ☐ parent_prior_prob
	* ☐ causal_strength
	* ☐ effect_background_prior_prob

Speaker knows:
	* ☑ causal_structure.AE
	* ☑ causal_structure.BE

## Interpretation Model:

Given "E because A," estimate causal_structure.AE and causal_structure.BE.

## Speaker Model:

Given causal_structure.AE and causal_structure.BE, endorse "E because A," relative to a set of alternative explanations we offer (pick one).

## Unknowns:

* ☐ stickiness parameter
* ☐ speaker rationality (at level ☐ s1 and at level ☐ s2)

## Fixed unknowns:

* lexical presuppositions/entailments (but this is OK if common ground is fixed)
* QUD is cause, because that's the only unknown for the listener
* alternative utterances / alternative explanations


