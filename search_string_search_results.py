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
