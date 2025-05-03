import pickle

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, ConfusionMatrixDisplay
import coremltools as ct
import matplotlib.pyplot as plt
import numpy as np


def train_model():
    data_dict = pickle.load(open('../data.pickle', 'rb'))

    data = np.asarray(data_dict['data'])
    labels = np.asarray(data_dict['labels'])
    x_train, x_test, y_train, y_test = train_test_split(data, labels, test_size=0.2, shuffle=True, stratify=labels)

    # Define a simple RandomForestClassifier with fixed parameters
    rfc = RandomForestClassifier(n_estimators=100, max_depth=None, random_state=42)

    # Train the model
    rfc.fit(x_train, y_train)

    # Make predictions
    y_predict = rfc.predict(x_test)

    # Compute confusion matrix
    cm = confusion_matrix(y_test, y_predict)
    ConfusionMatrixDisplay(confusion_matrix=cm).plot()
    plt.show()

    # Calculate accuracy
    score = accuracy_score(y_test, y_predict)
    print('{}% of samples were classified correctly!'.format(score * 100))
    print("The accuracy was: {}".format(score))

    # Save the trained model
    with open('../model.p', 'wb') as f:
        pickle.dump({'model': rfc}, f)

    # Convert to Core ML model and save
    core_ml_model = ct.converters.sklearn.convert(rfc)
    core_ml_model.save('ASLClassifier.mlmodel')