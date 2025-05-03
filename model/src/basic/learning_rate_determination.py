import pickle

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import numpy as np

import matplotlib.pyplot as plt

data_dict = pickle.load(open('../data.pickle', 'rb'))

data = np.asarray(data_dict['data'])
labels = np.asarray(data_dict['labels'])

# Split data into training, validation, and test sets
X_train, X_temp, y_train, y_temp = train_test_split(data, labels, stratify=labels, test_size=0.3, random_state=1)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, stratify=y_temp, test_size=0.5, random_state=1)

learning_rates = [0.1, 0.01, 0.001, 0.0001]
train_accuracies = []
val_accuracies = []

for lr in learning_rates:
    clf = MLPClassifier(hidden_layer_sizes=(100, 100), max_iter=1000, random_state=1, learning_rate="constant", learning_rate_init=lr)
    clf.fit(X_train, y_train)
    # Calculate training accuracy
    y_train_pred = clf.predict(X_train)
    train_accuracy = accuracy_score(y_train, y_train_pred)
    train_accuracies.append(train_accuracy)

    # Calculate validation accuracy
    y_val_pred = clf.predict(X_val)
    val_accuracy = accuracy_score(y_val, y_val_pred)
    val_accuracies.append(val_accuracy)

# Plot training accuracies
plt.plot(learning_rates, train_accuracies, label='Training Accuracy')
# Plot validation accuracies
plt.plot(learning_rates, val_accuracies, label='Validation Accuracy')

plt.xscale('log')
plt.xlabel('Learning Rate')
plt.ylabel('Accuracy')
plt.title('Accuracy vs Learning Rate')
plt.legend()
plt.show()