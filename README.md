# DiscreetAI Swift Library
Swift library to allow decentralized machine learning as a service.

## Installation
To use [CocoaPods](https://cocoapods.org) add the following to your `Podfile`:

```
platform :ios, '13.4'
use_frameworks!

target '<Your Target Name>' do
    pod 'DiscreetAI', '~> 1.0.4'
```

## Using the Demo App
You can try out our library easily by using our demo app. Just complete the following steps:

1. Make an account [here](https://beta.discreetai.com/signup) and create a new repo. You should now be on the repo page.
2. Save the *REPO ID* and *API KEY* you see at the top of the screen on the repo page. You'll need them for step 4.
3. Download our demo app from TestFlight by clicking [here](https://testflight.apple.com/join/jJZON87Y) while on your iPhone.
4. When the status of the repo says *Idle*, login to the demo app with the *REPO ID* and *API KEY* you saved in step 2.
5. The machine learning model that's going to train on your phone is an image classifier that classifies images as one of the digits from 0 to 9. Click on *Training Data* to see the currently empty training set, which consists of bins holding the training data for each of the digits from 0 to 9. 
6. Now you can take some pictures of digits and place them in the corresponding bins! For example, the bin *0* should hold all the pictures of the digit 0. If you prefer, you can use pictures you already have saved on your phone. *Remember, you will need at least one image stored for training on your phone to take place*.
7. Go back one screen and visit the *Training Status*. You will see all training updates on your phone here.
8. Follow the steps on the repo page to launch Explora and open the notebook you will use to start training. This should be named *ExploraMobileImage.ipynb*.
9. In one of the cells, you will see `dataset_id = mnist-sample`. Change this to `dataset_id = mnist`.
10. Now run all the cells to start your session!
