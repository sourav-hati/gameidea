import os

def search_files(directory, search_string):
    matching_files = []
    output_file = f"{search_string}_search_results.txt"
    search_string_lower = search_string.lower()
    
    with open(output_file, "w") as output:
        for root, _, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', errors='ignore') as f:
                        file_content = f.read().lower()
                        if search_string_lower in file_content:
                            matching_files.append(file_path)
                            output.write(file_path + "\n")
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    return output_file, matching_files

if __name__ == "__main__":
    directory = input("Enter the directory path: ")
    search_string = input("Enter the search string: ")
    
    output_file, result = search_files(directory, search_string)
    
    if result:
        print(f"Files containing the string are saved in {output_file}")
    else:
        print("No matching files found.")
