import pickle

import cv2
import mediapipe as mp

import time

model_dict = pickle.load(open('../model.p', 'rb'))
model = model_dict['model']

threshold = 0.5

previous_prediction = None
prediction_start_time = None
duration_threshold = 3  # 3 seconds

message_start_time = None
message_duration = 1  # 2 seconds
message = ''

cap = cv2.VideoCapture(0)

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

hands = mp_hands.Hands(static_image_mode=True, min_detection_confidence=0.3)


def run_model():
    while True:
        ret, frame = cap.read()
        H, W, _ = frame.shape
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(frame_rgb)
        cv2.putText(frame, 'Press q to exit!', (100, 50), cv2.FONT_HERSHEY_SIMPLEX,
                    1.3,
                    (0, 0, 0),
                    3,
                    cv2.LINE_AA)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

        if not results.multi_hand_landmarks:
            previous_prediction = None
            prediction_start_time = None
            message = ''
            message_start_time = None
            pass
        else:
            for hand_landmarks in results.multi_hand_landmarks:
                mp_drawing.draw_landmarks(
                    frame,  # image to draw
                    hand_landmarks,  # model output
                    mp_hands.HAND_CONNECTIONS,  # hand connections
                    mp_drawing_styles.get_default_hand_landmarks_style(),
                    mp_drawing_styles.get_default_hand_connections_style())

                min_y = min(landmark.y for landmark in hand_landmarks.landmark)
                min_x = min(landmark.x for landmark in hand_landmarks.landmark)
                max_y = max(landmark.y for landmark in hand_landmarks.landmark)
                max_x = max(landmark.x for landmark in hand_landmarks.landmark)

                data_aux = [(landmark.y - min_y, landmark.x - min_x) for landmark in hand_landmarks.landmark]

                x1 = int(min_x * W) - 10
                y1 = int(min_y * H) - 10

                x2 = int(max_x * W) - 10
                y2 = int(max_y * H) - 10

                flattened_data_aux = [item for sublist in data_aux for item in sublist]
                print(flattened_data_aux)
                prediction = model.predict([flattened_data_aux])
                prediction_proba = model.predict_proba([flattened_data_aux])
                prediction_proba = prediction_proba.max()
                score = prediction_proba if prediction_proba > threshold else 'Inconclusive'
                predicted_character = prediction[0] if score != 'Inconclusive' else ""

                if previous_prediction == predicted_character:
                    if time.time() - prediction_start_time >= duration_threshold:
                        with open('signs.txt', 'a') as f:
                            f.write(predicted_character + '\n')
                        message = 'Character Recorded: ' + predicted_character
                        message_start_time = time.time()
                        previous_prediction = None
                        prediction_start_time = None
                else:
                    previous_prediction = predicted_character
                    prediction_start_time = time.time()
                if message and time.time() - message_start_time < message_duration:
                    cv2.putText(frame, message, (100, 100), cv2.FONT_HERSHEY_SIMPLEX, 1.3, (0, 0, 0), 3, cv2.LINE_AA)
                else:
                    message = ''
                    message_start_time = None
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 0), 4)
                cv2.putText(frame, predicted_character + ' ' + str(score), (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 1.3,
                            (0, 0, 0), 3,
                            cv2.LINE_AA)

        cv2.imshow('frame', frame)
        cv2.waitKey(1)

    cap.release()
    cv2.destroyAllWindows()
