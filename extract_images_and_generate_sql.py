import re

# 1. Extract URLs from old_provider.txt
try:
    with open('old_provider.txt', 'r', encoding='utf-16le', errors='ignore') as f:
        content = f.read()
except:
    with open('old_provider_utf8.txt', 'r', encoding='utf-16le', errors='ignore') as f:
        content = f.read()

blocks = re.split(r'Product\(', content)[1:]
urls = []
for b in blocks:
    u = re.search(r"imageUrl:\s*['\"](.*?)['\"]", b)
    if u:
        urls.append(u.group(1))

# Generate SQL using id instead of name to avoid any encoding issues
if len(urls) == 75:
    sql = '-- SQL script to update original image URLs by ID\n\n'
    for i, url in enumerate(urls, 1):
        url_escaped = url.replace("'", "''")
        sql += f"UPDATE public.products SET image_url = '{url_escaped}' WHERE id = 'p{i}';\n"
    
    with open('supabase_update_images.sql', 'w', encoding='utf-8') as f:
        f.write(sql)
    print('Generated new SQL with IDs.')
else:
    print(f'Found {len(urls)} urls, expected 75. Cannot map safely.')
