Here’s a Python script that **takes a list of XML file paths from a `.txt` file**, searches for a given string in those XML files, and **saves the results to another `.txt` file**.

---

### **🔹 Python Script:**
```python
import os

def search_in_xml(file_list, search_string):
    matching_files = []
    output_file = f"{search_string}_search_results.txt"
    search_string_lower = search_string.lower()

    with open(output_file, "w", encoding="utf-8") as output:
        with open(file_list, "r", encoding="utf-8") as f:
            xml_files = [line.strip() for line in f.readlines() if line.strip()]

        for file_path in xml_files:
            if not os.path.exists(file_path):
                print(f"Skipping (not found): {file_path}")
                continue

            try:
                with open(file_path, "r", encoding="utf-8", errors="ignore") as xml_file:
                    file_content = xml_file.read().lower()
                    if search_string_lower in file_content:
                        matching_files.append(file_path)
                        output.write(file_path + "\n")
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

    return output_file, matching_files

if __name__ == "__main__":
    file_list = input("Enter the path of the TXT file containing XML file paths: ")
    search_string = input("Enter the search string: ")

    output_file, result = search_in_xml(file_list, search_string)

    if result:
        print(f"Matching XML files saved in {output_file}")
    else:
        print("No matching XML files found.")
```

---

### **🔹 How It Works:**
1. **Reads a list of XML file paths** from a user-provided `.txt` file.
2. **Checks if each XML file exists** and reads it.
3. **Searches for a case-insensitive string match** in each file.
4. **Saves the matching file paths** into `<search_string>_search_results.txt`.

---

### **🔹 Example Usage:**
#### **Step 1: Create a text file (`xml_file_list.txt`) with XML file paths**
```
C:\data\file1.xml
C:\data\subfolder\file2.xml
C:\logs\file3.xml
```
---
#### **Step 2: Run the Script**
```shell
Enter the path of the TXT file containing XML file paths: xml_file_list.txt
Enter the search string: error
```

✅ **Output File:** `error_search_results.txt`
```
C:\data\file1.xml
C:\logs\file3.xml
```

---

### **🔹 Features:**
✔ **Handles missing files** by skipping them.  
✔ **Works with both absolute & relative paths.**  
✔ **Searches case-insensitively.**  
✔ **Handles encoding errors gracefully.**  

Let me know if you need modifications! 🚀
