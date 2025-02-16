import pickle

from sklearn.ensemble import RandomForestClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import ConfusionMatrixDisplay
from sklearn.model_selection import GridSearchCV
import matplotlib.pyplot as plt
import numpy as np
param_grid = {
    'n_estimators': [50, 100, 200],  # numărul de arbori
    'max_depth': [None, 10, 20, 30]  # adâncimea maximă a arborilor
}


def train_model():
    data_dict = pickle.load(open('../data.pickle', 'rb'))

    data = np.asarray(data_dict['data'])
    labels = np.asarray(data_dict['labels'])
    x_train, x_test, y_train, y_test = train_test_split(data, labels, test_size=0.2, shuffle=True, stratify=labels)

    rfc = RandomForestClassifier(random_state=42)

    # Crearea GridSearchCV
    grid_search = GridSearchCV(estimator=rfc, param_grid=param_grid, cv=5)

    # Antrenarea modelului cu GridSearchCV
    grid_search.fit(x_train, y_train)

    # Afișarea celor mai buni parametri
    print(grid_search.best_params_)

    y_predict = grid_search.predict(x_test)
    cm = confusion_matrix(y_test, y_predict)
    ConfusionMatrixDisplay(confusion_matrix=cm).plot()
    plt.show()
    score = accuracy_score(y_predict, y_test)

    print('{}% of samples were classified correctly !'.format(score * 100))
    print("The accuracy was: {}".format(score))

    f = open('../model.p', 'wb')
    pickle.dump({'model': grid_search}, f)
    f.close()