import pandas as pd
import matplotlib.pyplot as plt
from googletrans import Translator
import time

# Load Excel data
file_path = "ASLearning_Survey.xlsx"
df = pd.read_excel(file_path, sheet_name='Răspunsuri la formular 1')

# Initialize translator
translator = Translator()

def safe_translate(text, src='ro', dest='en', retries=3, delay=1):
    for _ in range(retries):
        try:
            translated = translator.translate(text, src=src, dest=dest)
            if translated and translated.text:
                return translated.text
        except Exception as e:
            print(f"Translation error for '{text}': {e}")
        time.sleep(delay)
    # Fallback to original text if translation fails
    return text

# Columns to visualize
columns_to_plot = {
    "An de studiu": "Year of Study",
    "Statut": "Status",
    "Ai avut nevoie până acum să cunoști limbajul semnelor?": "Needed to Know Sign Language",
    "Ai mai folosit până acum o aplicație de învățare a limbilor vorbite?": "Used Language Learning App",
    "Considerați ca exercițiile interactive v-ar ajuta în procesul de învățare al unui limbaj nou?": "Would Interactive Exercises Help?",
    "Care este principalul motiv pentru care ai vrea să înveți ASL?": "Motivation to Learn ASL",
    "Ce te-a împiedicat să înveți ASL până acum?": "Barriers to Learning ASL",
    "Ce ți-ar plăcea să găsești într-o aplicație de învățare a limbajului semnelor?": "Desired Features in ASL App",
    "Cum ai prefera să înveți în aplicație?": "Preferred Learning Method",
    "Ce te-ar motiva cel mai mult să folosești aplicația regulat?": "Motivation to Use App Regularly",
    "Ce feature-uri ai vedea utile?": "Useful Features",
    "Crezi ca va fi utila?": "Do You Think It Will Be Useful?",
    "Daca nu, de ce?": "If Not, Why?"
}

# Color palette
colors = plt.cm.Paired.colors

# Loop through questions
for i, (column, title) in enumerate(columns_to_plot.items()):
    answers = df[column].dropna().astype(str)

    # Handle multiple answers separated by ", "
    if answers.str.contains(", ").any():
        answers = answers.str.split(", ").explode()
    
    counts = answers.value_counts()
    total = counts.sum()

    # Translate labels one by one safely
    unique_labels = counts.index.tolist()
    translated_labels = [safe_translate(label) for label in unique_labels]
    translation_map = dict(zip(unique_labels, translated_labels))
    counts.index = [translation_map[val] for val in counts.index]

    if i < 2:
        # Group values under 6% into "Others"
        percentages = (counts / total) * 100
        major = counts[percentages >= 6]
        minor = counts[percentages < 6]
        if not minor.empty:
            major["Others"] = minor.sum()
        labels = major.index
        sizes = major.values

        fig, ax = plt.subplots(figsize=(8, 6))
        wedges, _, autotexts = ax.pie(
            sizes,
            autopct='%1.1f%%',
            startangle=140,
            colors=colors[:len(sizes)],
            wedgeprops=dict(width=0.5),
            textprops={'fontsize': 15}
        )
        ax.axis('equal')
        plt.title(title, fontsize=14)
        plt.legend(wedges, labels, title="Categories", loc="center left", bbox_to_anchor=(1, 0.5))
        plt.tight_layout()
        plt.show()

    else:
        # Horizontal bar plot
        counts = counts.sort_values(ascending=True)
        plt.figure(figsize=(10, 6))
        plt.barh(counts.index, counts.values, color='cornflowerblue', textprops={'fontsize': 15})
        plt.title(title, fontsize=14)
        plt.xlabel("Number of Mentions")
        plt.tight_layout()
        plt.show()
