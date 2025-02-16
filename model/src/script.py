from collect_imgs import generate_images
from create_dataset import create_dataset
from train_classifier import train_model
from inference_classifier import run_model


def main():
    while True:
        print("Please enter the number corresponding to the function you want to run:")
        print("1. Generate Images")
        print("2. Create Dataset")
        print("3. Train Model")
        print("4. Run Model")
        print("5. Exit")
        user_input = input()

        if user_input == '1':
            generate_images()
        elif user_input == '2':
            create_dataset()
        elif user_input == '3':
            train_model()
        elif user_input == '4':
            run_model()
        elif user_input == '5':
            break
        else:
            print("Invalid input. Please enter a number between 1 and 5.")

main()