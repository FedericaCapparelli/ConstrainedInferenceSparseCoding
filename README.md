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

#### [Basic]
To run the algorithm to learn the receptive fields (_dictionary_) and the long-range interactions, execute the functions ```Job01_LearnDictionary``` and ```Job02_LearnLongrange```. The scripts ```param_job01_LearnDictionary``` and ```param_job02_LearnDLongrange``` contain examples of how to structure the parameters.

#### [Basic + Optional]
Aftern learning the dictionary (```job01```) and before learning the long-range interactions (```job02```) one can optionally execute ```Job01optional_FittingGaborToDict```. This script contains a procedure to fit the previously learned dictionary to Gabor functions (this is useful to parametrize the receptive fields in terms of orientation, spatial frequency, position, size, ...). Moreover, such fitting procedure sorts the dictionary elements according to their orientation: running ```job02``` on such sorted dictionary has the advantage of making the structure of the long-range connection matrix more explicit.

## Running context-modulation experiments
Subjected to contextual stimuli typically used in empirical studies, our model replicates several hallmark effects of
contextual processing
1) surround suppression (following _Walker GA, Ohzawa I, Freeman RD. Suppression outside the classical cortical receptive field._)
2) modulations dependent on the orientation of the surround (following _Sengpiel F, Sen A, Blakemore C. "Characteristics of surround inhibition in cat area 17."_)
3) luminance-dependent effects (following _Polat U, Mizobe K, Pettet MW, Kasamatsu T, Norcia AM. Collinear stimuli regulate visual responses depending on cell’s contrast threshold._)

#### [Basic 1-patch surround]
To run the contextual-modulation experiments, first investigate select a subset of cells that responds well to small oriented stimuli centered in the center of the visual field. This is done executing first ```Job03_SizeTuning_1loc``` and then  ```Job04_DataSelectionAndOptimalStimuli```.

The functions ```Job05_AnalysisSizeTuning```, ```Job06_OrientationModulation_1loc``` and ```Job07_ContrastModulation_1loc``` contain the code to perform the experiments mentioned above (each function follows the experimental procedures indicated in the correspondent papers).

#### [Basic 4-patch surround]
To run the contextual-modulation experiments, first investigate select a subset of cells that responds well to small oriented stimuli centered in the center of the visual field. This is done executing first ```Job03_SizeTuning_4loc``` and then  ```Job04_DataSelectionAndOptimalStimuli```.

The functions ```Job05_AnalysisSizeTuning```, ```Job06_OrientationModulation_4loc``` and ```Job07_ContrastModulation_4loc``` contain the code to perform the experiments mentioned above (each function follows the experimental procedures indicated in the correspondent papers).

***

#### For more details or detailed description of the routines, check the help of each function!
