import os
import cv2

data_directory = '../data'
number_of_signs = 5
number_of_images_per_sign = 200
cap = cv2.VideoCapture(0)

sign_dictionary = {
    0: "I Love You",
    1: 'Yes',
    2: 'No',
    3: 'Hello',
    4: 'Wow'
}


def generate_images():
    if not os.path.exists(data_directory):
        os.makedirs(data_directory)

    for j in range(number_of_signs):
        if not os.path.exists(os.path.join(data_directory, str(sign_dictionary[j]))):
            os.makedirs(os.path.join(data_directory, str(sign_dictionary[j])))

        done = False
        while True:
            ret, frame = cap.read()
            cv2.putText(frame, 'Ready? Press "Q" ! :)', (100, 100), cv2.FONT_HERSHEY_SIMPLEX,
                        1.3,
                        (0, 255, 0),
                        3,
                        cv2.LINE_AA)
            cv2.putText(frame, 'Collecting data for class {}'.format(sign_dictionary[j]), (100, 50),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.3,
                        (0, 255, 0),
                        3,
                        cv2.LINE_AA)
            cv2.imshow('frame', frame)
            if cv2.waitKey(25) == ord('q'):
                break

        counter = 0
        info_text = 'Collecting data for class {}'.format(sign_dictionary[j])
        while counter < number_of_images_per_sign:
            ret, frame = cap.read()
            cv2.putText(frame, info_text, (100, 50), cv2.FONT_HERSHEY_SIMPLEX,
                        1.3,
                        (0, 255, 0),
                        3,
                        cv2.LINE_AA)
            cv2.imshow('frame', frame)
            cv2.waitKey(25)
            cv2.imwrite(os.path.join(data_directory, str(sign_dictionary[j]), '{}.jpg'.format(counter)), frame)

            counter += 1

    cap.release()
    cv2.destroyAllWindows()
