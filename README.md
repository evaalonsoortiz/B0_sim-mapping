# B0_sim-mapping

## Step 1
### Downloads
To recreate all the simulations make sure to download: 

* [Zubal phantom](https://noodle.med.yale.edu/zubal/info.htm) 

* https://github.com/evaalonsoortiz/Fourier-based-field-estimation.git 

## Step 2
### Clone or Fork

You'll need to copy this repository to your local machine and run the function startup.m. It will automatically add the different files to your matlab path.

## Step 3 
Choose one of the function below to simulate a field map:

* zubal_simulation.m
* shepplogan_simulation.m
* spherical_simulaiton.m
* cylindrical_simulaiton.m

### Example
If you're using zubal_simulation.m with a SNR of 50, the final result should be something like this: 

**Scaled images of the field mapping techniques**

<img width="757" alt="Capture d’écran, le 2022-08-19 à 18 06 23" src="https://user-images.githubusercontent.com/85508922/185713382-e86396db-bf29-4943-89d8-67c11a112d6f.png">

**Graphs for the absolute and percent error**

<img width="488" alt="Capture d’écran, le 2022-08-19 à 17 38 30" src="https://user-images.githubusercontent.com/85508922/185710752-dd302a9e-2396-487a-ba23-0b3a0cab3f00.png">

<img width="488" alt="Capture d’écran, le 2022-08-19 à 17 36 28" src="https://user-images.githubusercontent.com/85508922/185710621-d09ce759-de39-4469-86e7-b8c0aa98a95c.png">

You can have multiple SNR, example: *list_SNR = [10 15 20 30 50];*, the final scaled image will be the last SNR of your list and the graph for the error should look like this:

<img width="495" alt="Capture d’écran, le 2022-08-19 à 18 03 55" src="https://user-images.githubusercontent.com/85508922/185713163-61550fd7-5d2f-431f-8dd3-43b23fca6875.png">

<img width="493" alt="Capture d’écran, le 2022-08-19 à 18 03 34" src="https://user-images.githubusercontent.com/85508922/185713166-0c07a066-d7fd-4626-9764-93455f77a886.png">


