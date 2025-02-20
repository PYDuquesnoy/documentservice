import os
import base64
import json
import argparse
import requests

def encode_file_to_base64(file_path):
    """
    Reads a binary file and encodes its content in base64.

    :param file_path: Path to the input binary file.
    :return: Base64-encoded string.
    """
    try:
        with open(file_path, "rb") as file:
            return base64.b64encode(file.read()).decode('utf-8')
    except Exception as e:
        print(f"Error encoding file to base64: {e}")
        return None

def post_document(base_url, username, password, file_path):
    """
    Posts a base64-encoded file to the REST service.

    :param base_url: URL of the REST service.
    :param username: Username for basic authentication.
    :param password: Password for basic authentication.
    :param file_path: Path to the input file.
    """
    # Encode file to base64
    base64_content = encode_file_to_base64(file_path)
    if not base64_content:
        return

    # Prepare the JSON payload
    payload = {
        "fileName" : os.path.basename(file_path),
        "content": base64_content
    }

    # Send the POST request
    try:
        response = requests.post(
            f"{base_url}/document",
            json=payload,
            auth=(username, password),
            headers={"Content-Type": "application/json"}
        )
        print("Response Status Code:", response.status_code)
        print("Response Body:", response.json())
    except Exception as e:
        print(f"Error sending request: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Post a base64-encoded file to the REST service.")
    parser.add_argument("base_url", help="Base URL of the REST service (e.g., http://localhost:52773/csp/restdemo2/docdemo/v1)")
    parser.add_argument("username", help="Username for basic authentication")
    parser.add_argument("password", help="Password for basic authentication")
    parser.add_argument("file_path", help="Path to the file to be uploaded")

    args = parser.parse_args()

    post_document(args.base_url, args.username, args.password, args.file_path)
