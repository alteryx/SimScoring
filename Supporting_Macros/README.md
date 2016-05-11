# About the Simulation Scoring Tool

<img src="../SimScoringIcon.png" width=100 height=100 />



__Insert summary of the Simulation Scoring tool__

_Note: This tool uses the R tool. Install R and the necessary packages by going to Options > Download Predictive Tools._

### Inputs

There are 3 inputs.

1. __Simulation Input__ The simulation data to score. This must contain all of the fields that the associated predictive model was created on.
2. __Validation Input (optional)__ The validation dataset to use. This is an optional input. This should not be connected when the incomming model object has a class of "General Linear Model" or "Linear Model". The Alteryx tools that provide these models are shown below. For other models, a validation dataset must be connected.

    - Count Regression
    - Gamma Regression
    - Linear Regression
    - Count Regression

 

3. __Model Input__ The model object produced by one of the R-based predictive modeling tools.

### Configuration Properties

1. __The number of records to score at a time:__ The tool can break the input data into chunks, scoring a chunk at a time, and thereby avoid R's in-memory processing limitation. This option controls the maximal number of records contained in each such chunk of data.
2. __How many samples from error distribution per iteration:__ The number of draws from the error distribution for each incoming record
3. __Name results of score simulation:__ The field name for the results generated. The field name must start with a letter and may contain letters, numbers, and the special characters period(".") and underscore ("_"). No other special characters are allowed, and R is case sensitive.
4. __Set Random Seed:__ (optional) Set a random seed. This option will be hidden if there is a seed field in the data to be scored.

### Output

1. __D Output__ The incoming data to be scored, along with the simulated score.
