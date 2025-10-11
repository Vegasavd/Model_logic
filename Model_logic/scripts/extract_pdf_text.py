from pathlib import Path
import sys
p = Path(r'c:\Users\vegas\OneDrive\Desktop\Model_logic\out\modelo_logico')
if not p.exists():
    print('Directory not found:', p)
    sys.exit(1)

pdfs = list(p.glob('*.pdf'))
if not pdfs:
    print('No PDFs found in', p)
    sys.exit(1)

try:
    import PyPDF2
    reader_available = True
except Exception:
    reader_available = False

for f in pdfs:
    st = f.stat()
    print('\n====', f.name, '====')
    print('Size:', st.st_size, 'bytes   Modified:', st.st_mtime)
    if reader_available:
        try:
            with open(f, 'rb') as fh:
                r = PyPDF2.PdfReader(fh)
                pages = min(len(r.pages), 20)
                text = []
                for i in range(pages):
                    t = r.pages[i].extract_text() or ''
                    text.append(t)
                combined = '\n'.join(text)
                snippet = combined[:3000]
                if snippet.strip():
                    print('\n--- text snippet (truncated) ---\n')
                    print(snippet)
                else:
                    print('\n[no extractable text found]')
        except Exception as e:
            print('Error reading PDF with PyPDF2:', e)
    else:
        print('[PyPDF2 not installed — cannot extract text]')
        try:
            import os
            print('Path:', f)
            print('To compare content, open the PDF manually or install PyPDF2: pip install pypdf')
        except Exception:
            pass
print('\nDone')
