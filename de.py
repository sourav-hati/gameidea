import difflib
import fitz  # PyMuPDF
from PIL import Image, ImageChops
import os

# ---------- TEXT COMPARISON ----------
def compare_pdf_text(pdf1, pdf2):
    """Extract and compare text content of two PDFs (returns HTML diff)"""
    text1, text2 = "", ""
    for page in fitz.open(pdf1):
        text1 += page.get_text()
    for page in fitz.open(pdf2):
        text2 += page.get_text()

    differ = difflib.HtmlDiff()
    diff_html = differ.make_file(
        text1.splitlines(),
        text2.splitlines(),
        fromdesc=os.path.basename(pdf1),
        todesc=os.path.basename(pdf2),
        context=True,
        numlines=3
    )
    return diff_html


# ---------- VISUAL COMPARISON USING PyMuPDF ----------
def render_pdf_pages(pdf_path, dpi=100):
    """Render PDF pages as PIL images using PyMuPDF"""
    doc = fitz.open(pdf_path)
    pages = []
    zoom = dpi / 72  # 72 DPI is default
    mat = fitz.Matrix(zoom, zoom)
    for page in doc:
        pix = page.get_pixmap(matrix=mat, alpha=False)
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        pages.append(img)
    return pages


def compare_pdf_images(pdf1, pdf2, dpi=100, output_dir="diff_images"):
    """Compare visual rendering (pixel-level) of two PDFs using PyMuPDF"""
    os.makedirs(output_dir, exist_ok=True)

    pages1 = render_pdf_pages(pdf1, dpi)
    pages2 = render_pdf_pages(pdf2, dpi)

    html_blocks = []
    for i, (p1, p2) in enumerate(zip(pages1, pages2)):
        p1_path = os.path.join(output_dir, f"{os.path.basename(pdf1)}_page{i+1}.png")
        p2_path = os.path.join(output_dir, f"{os.path.basename(pdf2)}_page{i+1}.png")
        diff_path = os.path.join(output_dir, f"diff_{i+1}_{os.path.basename(pdf1)}_{os.path.basename(pdf2)}.png")

        p1.save(p1_path)
        p2.save(p2_path)

        if p1.size == p2.size:
            diff_img = ImageChops.difference(p1, p2)
            if diff_img.getbbox():
                diff_img.save(diff_path)
                diff_status = f"<b style='color:red;'>Differences found on Page {i+1}</b>"
            else:
                diff_status = f"<b style='color:green;'>No differences on Page {i+1}</b>"
                diff_path = None
        else:
            diff_status = f"<b style='color:orange;'>Page {i+1} sizes differ: {p1.size} vs {p2.size}</b>"
            diff_path = None

        html = f"""
        <h3>Page {i+1}</h3>
        <p>{diff_status}</p>
        <div style="display:flex;gap:20px;">
            <div><p>{os.path.basename(pdf1)}</p><img src="{p1_path}" width="300"></div>
            <div><p>{os.path.basename(pdf2)}</p><img src="{p2_path}" width="300"></div>
            <div><p>Diff</p>{f'<img src="{diff_path}" width="300">' if diff_path else 'N/A'}</div>
        </div>
        <hr>
        """
        html_blocks.append(html)

    return "\n".join(html_blocks)


# ---------- MAIN ----------
if __name__ == "__main__":
    # 🔹 Read PDFs from txt file (pairs of 2 lines)
    with open("pdf_list.txt", "r", encoding="utf-8") as f:
        pdfs = [line.strip() for line in f if line.strip()]

    if len(pdfs) % 2 != 0:
        raise ValueError("❌ pdf_list.txt must contain an even number of lines (pairs of PDFs).")

    # Process pairs
    for i in range(0, len(pdfs), 2):
        pdf1, pdf2 = pdfs[i], pdfs[i+1]
        print(f"🔹 Comparing pair:\n  1) {pdf1}\n  2) {pdf2}")

        text_diff_html = compare_pdf_text(pdf1, pdf2)
        visual_diff_html = compare_pdf_images(pdf1, pdf2)

        final_html = f"""
        <html>
        <head><meta charset="utf-8"><title>PDF Comparison Report</title></head>
        <body>
            <h1>PDF Comparison Report</h1>
            <h2>Comparing:</h2>
            <p>{pdf1}</p>
            <p>{pdf2}</p>
            <h2>Text Differences</h2>
            {text_diff_html}
            <h2>Visual Differences</h2>
            {visual_diff_html}
        </body>
        </html>
        """

        report_name = f"comparison_report_{i//2 + 1}.html"
        with open(report_name, "w", encoding="utf-8") as f:
            f.write(final_html)

        print(f"✅ Report saved as {report_name}")
