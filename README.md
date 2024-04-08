# TAEFS-Matlab
Balancing Different Optimization Difficulty Between Objectives in Multi-Objective Feature Selection

This code is written by Zhenshou Song (songzhenshou@gmail.com), and supported by Dr. Ruwang Jiao. This implementation is based on the framework of PlatEMO.

It is essential to specifically emphasize that only the non-dominated feature subsets from the training data are selected for calculating the HV and MCER values on test data.
A common oversight is to select the whole population obtained on the training set to calculate their classification errors on the test set. and then according to test errors of the whole population to calculate these metrics.
