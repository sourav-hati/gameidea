import os
from zeep import Client
from zeep.transports import Transport
from requests.auth import HTTPBasicAuth
import requests

# SOAP API Configuration
WSDL_URL = "https://example.com/service?wsdl"  # Replace with actual WSDL URL
USERNAME = "your_username"
PASSWORD = "your_password"

# Directories
INPUT_DIR = "input_xml_files"
OUTPUT_DIR = "output_responses"

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Set up SOAP Client with Basic Auth
session = requests.Session()
session.auth = HTTPBasicAuth(USERNAME, PASSWORD)
client = Client(WSDL_URL, transport=Transport(session=session))

def process_xml_file(input_file):
    """Read input XML, send SOAP request, and save response."""
    with open(input_file, "r", encoding="utf-8") as f:
        xml_data = f.read()
    
    # Call the SOAP method (replace 'YourMethod' with actual method name)
    try:
        response = client.service.YourMethod(_soapheaders={"SOAPAction": "YourSOAPAction"}, xml_data=xml_data)
        
        # Save response
        output_file = os.path.join(OUTPUT_DIR, os.path.basename(input_file).replace(".xml", "_response.xml"))
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(response)
        
        print(f"Processed: {input_file} → {output_file}")
    except Exception as e:
        print(f"Error processing {input_file}: {e}")

# Process all XML files in input directory
for file_name in os.listdir(INPUT_DIR):
    if file_name.endswith(".xml"):
        process_xml_file(os.path.join(INPUT_DIR, file_name))



-------------


import os
from zeep import Client
from zeep.transports import Transport
from requests import Session
from requests.auth import HTTPBasicAuth

def test_soap_api(wsdl_url, username, password, input_folder, output_folder):
    # Set up a session with Basic Authentication
    session = Session()
    session.auth = HTTPBasicAuth(username, password)
    transport = Transport(session=session)

    # Create a client for the SOAP API
    client = Client(wsdl=wsdl_url, transport=transport)

    # Ensure output folder exists
    os.makedirs(output_folder, exist_ok=True)

    # Iterate over all XML files in the input folder
    for filename in os.listdir(input_folder):
        if filename.endswith('.xml'):  # Process only XML files
            input_path = os.path.join(input_folder, filename)
            output_path = os.path.join(output_folder, f"output_{filename}")

            try:
                # Read the input XML
                with open(input_path, 'r') as file:
                    input_data = file.read()

                # Call the SOAP API
                response = client.service.operation_name(input_data)

                # Save the output to the specified location
                with open(output_path, 'w') as file:
                    file.write(response)

                print(f"Processed: {filename} -> Saved to: {output_path}")
            except Exception as e:
                print(f"Error processing {filename}: {e}")

# Replace these with actual values
wsdl_url = "https://example.com/your-soap-api?wsdl"  # Replace with the actual WSDL URL
username = "your_username"  # Replace with your username
password = "your_password"  # Replace with your password
input_folder = "path/to/input_folder"  # Replace with the folder containing input XML files
output_folder = "path/to/output_folder"  # Replace with the folder to save output XML files

if __name__ == "__main__":
    test_soap_api(wsdl_url, username, password, input_folder, output_folder)

