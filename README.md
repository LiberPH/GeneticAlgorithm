GeneticAlgorithm
================

Genetic Algorithm for finding parameters in  BioNetGen models

Requirements:

-Linux (Unix can be used with minor editions in sed and other commands. Complete documentation for Unix coming soon.)

-R

-Perl

-BioNetGen (Older versions of BioNetGen are non compatible with ln() mathematical functions). I you have an outdated linux, it may be incompatible with the latest version of BioNetGen. In that case just change ln()'s in the example to the equivalent in log() usage.

The genetic algorithm per-se is coded in BASH shell script for linux. Please consider that before to use it in unix, some changes (as in sed commands) may be needed.

Algorithm sections

IMPORTANT GLOBAL VARIABLES
Variables that affect all the generations:

-GENERATION Current generation

-POOL_SIZE Number of candidates alive at once

-MAX_GENERATIONS Maximum number of generations to run the algorithm


HELPER SCRIPTS
The files GA.sh and GA_Elitist.sh are the pipelines for running the algorithm. Most of the components with determined numeric functions are included as R-scripts read from command line. Check that the paths are correct prior to running the Genetic Algorithm.  
