from pathlib import Path
from pypdf import PdfReader

p = Path(r'c:\Users\vegas\OneDrive\Desktop\Model_logic\out\modelo_logico')
if not p.exists():
    print('Directory not found:', p)
    raise SystemExit(1)

target = p / 'README_tests.pdf'
if not target.exists():
    print('PDF not found:', target)
    raise SystemExit(1)

r = PdfReader(str(target))
text = []
for i, pg in enumerate(r.pages[:20]):
    t = pg.extract_text() or ''
    text.append(t)
combined = '\n\n--- Page Break ---\n\n'.join(text)
print('--- PDF snippet (truncated to 8000 chars) ---\n')
print(combined[:8000])
