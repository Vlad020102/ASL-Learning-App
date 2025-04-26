import os
import pickle

import mediapipe as mp
import cv2
import matplotlib.pyplot as plt

data_directory = '../data'
mp_hands_service = mp.solutions.hands
mp_drawing_service = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
hands_processor = mp_hands_service.Hands(static_image_mode=True, min_detection_confidence=0.3)

data = []
labels = []


def create_dataset():

    for dir_names in os.listdir(data_directory):
        #TODO: add [:1] at the end of next line in order to get only one image per class (for capturing landmarks only)
        for img_path in os.listdir(os.path.join(data_directory, dir_names)):
            img = cv2.imread(os.path.join(data_directory, dir_names, img_path))
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

            results = hands_processor.process(img_rgb)
            if not results.multi_hand_landmarks:
                continue
            for hand_landmarks in results.multi_hand_landmarks:
                mp_drawing_service.draw_landmarks(
                    img_rgb,
                    hand_landmarks,
                    mp_hands_service.HAND_CONNECTIONS,
                    mp_drawing_styles.get_default_hand_landmarks_style(),
                    mp_drawing_styles.get_default_hand_connections_style()
                )

                min_y = min(landmark.y for landmark in hand_landmarks.landmark)
                min_x = min(landmark.x for landmark in hand_landmarks.landmark)

                data_aux = [(landmark.y - min_y, landmark.x - min_x) for landmark in hand_landmarks.landmark]
                flattened_data_aux = [item for sublist in data_aux for item in sublist]

                print(flattened_data_aux)

                data.append(flattened_data_aux)
                labels.append(dir_names)
            # plt.figure()
            # plt.imshow(img_rgb)
    f = open('../data.pickle', 'wb')
    pickle.dump({'data': data, 'labels': labels}, f)
    f.close()
    plt.show()
