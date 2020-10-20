# Features of Heart Rate Variability for Neonates (Matlab code)


Quantitative features of the heart rate variability (HRV) for newborn infants, see for
example [Goulding et al. 2015](#references).

---
[Requirements](#requires) | [Functions](#functions) | [Example](#example) |
[References](#references) | [Contact](#contact)


## Requires
Matlab ([Mathworks](http://www.mathworks.co.uk/products/matlab/)) version R2020a or newer
with the statistics toolbox. (Should work on older versions but not tested.)

Add this directory to the Matlab path. See [how to add
path](https://uk.mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html)
for more details.
  

## Main Functions

  * Set parameters in `hrv_EAR.m`
  * Estimate features with `hrv_features.m`

For more information on function type `help <filename.m>`. 


## Features

| feature       | descriptions                                           |
|---------------|--------------------------------------------------------|
| mean\_NN      | mean NN (normalised RR interval)                       |
| SD\_NN        | standard deviation of NN                               |
| VLF\_power    | power in the very low frequency band (0.01 to 0.04 Hz) |
| LF\_power     | power in the low frequency band (0.04 to 0.2 Hz)       |
| HF\_power     | power in the high frequency band (0.2 to 2 Hz)         |
| LF\_HF\_ratio | LF\_power:HF\_power ratio                              |
| TINN          | triangular interpolation of NN interval histogram      |

TINN function from [HRVTool](https://github.com/MarcusVollmer/HRV/).

## Example

Extract the R-peaks from the ECG and store in a structured array. Here, we generate some
fake R-peaks structure using random variables for 2 babies:
```matlab
rr_test_st = fake_hrv_data();
```

Next, generate the feature set:
```matlab
[hrv_feats_tb, hrv_feats_epochs_tb] = hrv_features(rr_test_st);
```

Two outputs in the form of tables:

1. `hrv_feats_tb` are the features averaged (median) over the entire HRV record:
```matlab
head(hrv_feats_tb)
```
```
    code      mean_NN    SD_NN     VLF_power    LF_power    HF_power    LF_HF_ratio     TINN 
  ________    _______    ______    _________    ________    ________    ___________    ______

  {'ID_1'}    530.52     8.4727     191.72       16.312      1.5763       11.632       46.875
  {'ID_2'}    528.77     7.6981     223.51       12.846      1.4657       9.1349       39.062
```


2. `hrv_feats_epochs_tb` is the feature set for each epoch:
```matlab
head(hrv_feats_epochs_tb)
```
```
    mean_NN    SD_NN     VLF_power    LF_power    HF_power    LF_HF_ratio     TINN     baby_ID    start_time_secs
    _______    ______    _________    ________    ________    ___________    ______    _______    _______________

    525.77     8.9454     372.22       23.771      1.6663       14.266       46.875    "ID_1"              0
    534.33     5.8692     96.396       7.7355      1.3898        5.566        31.25    "ID_1"         150.14
    531.85     6.0415      70.58       11.495      1.4131       8.1346       39.062    "ID_1"         300.25
    525.44     6.8949     184.19       16.832      1.3617       12.361       39.062    "ID_1"         449.89
    523.06     6.6994     99.013       13.728      1.4444       9.5049        31.25    "ID_1"          600.2
    520.05     6.0771      137.1       15.028      1.5397       9.7605        31.25    "ID_1"          749.9
    513.21     8.1552     152.14       10.954      1.5769       6.9467       46.875    "ID_1"         899.91
    509.46     6.3929     199.26       10.233      1.5758       6.4939       39.062    "ID_1"         1049.9
```
Epochs are 5 minutes with 50% overalp (set in `hrv_EAR.m`).



## References

1. Goulding RM, Stevenson NJ, Murray DM, Livingstone V, Filan PM, Boylan GB. Heart rate
   variability in hypoxic ischaemic encephalopathy: correlation with EEG grade and
   two-year neurodevelopmental outcome. Pediatr Res. 2015 May;77(5):681-7. doi:
   [10.1038/pr.2015.28](https://doi.org/10.1038/pr.2015.28)


## Contact

John M. O'Toole

Neonatal Brain Research Group,  
[INFANT Research Centre](https://www.infantcentre.ie/),  
Department of Paediatrics and Child Health,  
Room 2.19 UCC Academic Paediatric Unit, Cork University Hospital,  
University College Cork,  
Ireland

- email: jotoole AT ucc _dot ie 
