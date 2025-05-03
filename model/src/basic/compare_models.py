import matplotlib.pyplot as plt
import numpy as np
import pickle
from sklearn.svm import LinearSVC, SVC, NuSVC
from sklearn.ensemble import GradientBoostingClassifier, RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split

models_array = [
    RandomForestClassifier, LinearSVC, SVC, NuSVC, 
    GradientBoostingClassifier, DecisionTreeClassifier, 
    RandomForestClassifier, KNeighborsClassifier
]

data_dict = pickle.load(open('../data.pickle', 'rb'))
data = np.asarray(data_dict['data'])
labels = np.asarray(data_dict['labels'])
x_train, x_test, y_train, y_test = train_test_split(data, labels, test_size=0.2, shuffle=True, stratify=labels, random_state=42)

score_array = []
model_names = []

for model in models_array:
    model_instance = model()
    model_instance.fit(x_train, y_train)
    score = model_instance.score(x_test, y_test)
    score_array.append(score)
    model_names.append(model.__name__)  # Collect model names
    print(f'{model.__name__} accuracy: {score * 100:.2f}%')

# Fix: Use bar plot instead of line plot
plt.figure(figsize=(10, 10))
plt.bar(model_names, score_array, color='b', alpha=0.7)
plt.ylim(0.97, 1.0)
# Add labels and title
plt.xlabel('Model')
plt.ylabel('Accuracy')
plt.title('Model Accuracy Comparison')
plt.xticks(rotation=30)  # Rotate model names for better visibility
plt.grid(axis='y')
plt.savefig('../model_accuracy_comparison.png')

# Show the plot
plt.show()
