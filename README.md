# B0_sim-mapping

## Step 1
### Downloads
To recreate all the simulations make sure to download: 

* The modified data for the Zubal phantom. The simulation is not using the raw data from [Zubal phantom](https://noodle.med.yale.edu/zubal/info.htm). Make sure to download the right one from ***Eva Alonso Ortiz*** and to use the **startup.m** function to add it to your Matlab path.

* https://github.com/evaalonsoortiz/Fourier-based-field-estimation.git and add it to your MATLAB path using **startup.m**

## Step 2
### Clone or Fork

You'll need to copy this repository to your local machine and run the function startup.m. It will automatically add the different files to your matlab path.

## Step 3 
Choose one of the function below to simulate a field map and the graph error for different SNR:

* zubal_simulation.m
* shepplogan_simulation.m
* spherical_simulaiton.m
* cylindrical_simulaiton.m
