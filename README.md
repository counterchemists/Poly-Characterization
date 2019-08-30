# Polymerization Characterization


## What?
This code allows characterizing pressure and stretch sensors by measuring:
- their resistance (with the [Fluke 8846A](http://assets.fluke.com/manuals/884xa___pmeng0000.pdf) digital multimeter)
- the force exerced on it (with the [PCE DFG 500](https://www.pce-instruments.com/f/t/data-sheet/data_sheet-force-gauge-pce-dfg-series-en.pdf) force gauge)


## How?


### Measures

The code uses processing, it can be downloaded here: https://processing.org

To run it, open this file:

    evalCode/evalCode.pde


### Evaluation

The measure program will generate csv files in the evalCode/data folder.

To analyse them, you can use the following R code:

    evalCode/data/plot.r

