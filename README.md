# ConstrainedInferenceSparseCoding
This repository contains the code to implement the model described in the manuscript "Constrained inference in sparse coding reproduces contextual effects and predicts laminar neural dynamics".

- We define a sparse coding model to encode natural visual scenes
- Different from the _standard_ sparse coding (by Olshausen and Field), this model takes into account spatial dependencies among features that encode non-overlapping regions of an image
- We derive a biologically realistic inference scheme (i.e. a neural dynamics) under the constraint that neurons have direct access to only local image information
- The scheme can be interpreted as a network in primary visual cortex where two neural populations are organized in different layers within orientation hypercolumns that are connected by local, short-range and long-range recurrent interactions
- We use this to investigate contextual processing in the early visual system

## Learning connectivity structures 
When trained with natural images, the model predicts
1) feature vectors that resemble Gabor filters, having spatial properties similar to those of V1 receptive fields;
2) a connectivity structure linking neurons with similar orientation preferences matching the typical patterns found for long-ranging horizontal axons and feedback projections in visual cortex.
Such quantities are sufficient to specify completely the connectivity of the network.

To run the algorithm to learn the receptive fields (_dictionary_) and the long-range interactions, execute the function ```Job01_LearnDictionary``` and ```Job02_LearnLongRange```

## Running context-modulation experiments
Subjected to contextual stimuli typically used in empirical studies, our model replicates several hallmark effects of
contextual processing
1) surround suppression
2) modulations dependent on the orientation of the surround
3) luminance-dependent effects
