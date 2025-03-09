from collect_imgs import generate_images
from create_dataset import create_dataset
from train_classifier import train_model
from inference_classifier import run_model

import pickle

def main():
    # while True:
    #     print("Please enter the number corresponding to the function you want to run:")
    #     print("1. Generate Images")
    #     print("2. Create Dataset")
    #     print("3. Train Model")
    #     print("4. Run Model")
    #     print("5. Exit")
    #     user_input = input()

    #     if user_input == '1':
    #         generate_images()
    #     elif user_input == '2':
    #         create_dataset()
    #     elif user_input == '3':
    #         train_model()
    #     elif user_input == '4':
    #         run_model()
    #     elif user_input == '5':
    #         break
    #     else:
    #         print("Invalid input. Please enter a number between 1 and 5.")
    
    coordinates = [0.6455868482589722,0.7171601057052612,0.7386432290077209,0.6588346362113953,0.8001978993415833,0.5868890881538391,0.8616681098937988,0.5240550637245178,0.9325359463691711,0.4751032590866089,0.5504602193832397,0.5133945345878601,0.4805181324481964,0.4327835440635681,0.4248968362808228,0.3834053874015808,0.3736501932144165,0.3381298184394836,0.4722208380699158,0.5264908075332642,0.3783525228500366,0.4374953806400299,0.3187315464019775,0.3783570528030396,0.2698618173599243,0.32662433385849,0.4187009632587433,0.556281566619873,0.325499415397644,0.4744796454906464,0.2808124423027039,0.4201366007328033,0.244547575712204,0.3708807528018951,0.3801374137401581,0.5995117425918579,0.308182418346405,0.5430063009262085,0.2739400267601013,0.5025440454483032,0.2470305860042572,0.4615496397018433]
    model_dict = pickle.load(open('../model.p', 'rb'))
    model = model_dict['model']
    prediction = model.predict([coordinates])
    print(prediction)
    

main()