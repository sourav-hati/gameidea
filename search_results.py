import os

def search_files(directory, search_string, output_file="search_results.txt"):
    matching_files = []
    
    with open(output_file, "w") as output:
        for root, _, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', errors='ignore') as f:
                        if search_string in f.read():
                            matching_files.append(file_path)
                            output.write(file_path + "\n")
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    return matching_files

if __name__ == "__main__":
    directory = input("Enter the directory path: ")
    search_string = input("Enter the search string: ")
    
    result = search_files(directory, search_string)
    
    if result:
        print("Files containing the string are saved in search_results.txt")
    else:
        print("No matching files found.")
