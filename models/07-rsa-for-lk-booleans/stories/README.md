## How do I generate counterfactual structures?

The basic system here for creating counterfactual structures is to take every causal link that exists in the actual structure (LINK) and every pair of variables with no causal parents (ROOT_PAIR) and toggle whether or not there's a causal link there in the counterfactual world.

### How to counterfactualize a LINK

If there exists a LINK in the actual world, this means that some variable B's state depends on the state of some other variable A. Let fn be the function such that state(B) = fn( state(A), ... ). With probability 0.5, this will be the function for generating B. With probability 0.5, B will deterministically take whatever value it holds in the actual world.

actual world:
A=T ---> B=T

counterfactual structures:
0.50		A ---> B
0.50		A      B=T

### How to counterfactualize a ROOT_PAIR

If there is some ROOT_PAIR, that is, there are two variables A and B that have no causal parents under the actual causal structure, then with probability 0.5 the actual structure will be chosen, with probability 0.25 B will deterministically match A, and with probability 0.25 A will deterministically match B.

Things to check:
* These are not always equivalent because the prior probabilities of A and B might be different.
* All structural and prior variables are independent of one another. Knowing the value of one does not tell you the value of another (without any observations). Each variables will be marginalized out in some contexts where its state does not affect the observables and therefore cannot be observed.

actual causal structure:
A      B

counterfactual structures:
0.50		A      B
0.25		A ---> B=A
0.50		B ---> A=B
