import os

reps = {
    'Тамақ': 'Корма',
    'Ойыншықтар': 'Игрушки',
    'Аксессуарлар': 'Аксессуары',
    'Киімдер': 'Одежда'
}

for root, _, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            original_content = content
            for k, v in reps.items():
                content = content.replace(k, v)
            if content != original_content:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(content)
