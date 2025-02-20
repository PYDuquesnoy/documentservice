import argparse
import requests
import base64
import sys

def download_file(base_url, username, password, reference):
    url = f"{base_url}/document/{reference}"
    auth = (username, password)  # Replace with your credentials

    try:
        response = requests.get(url, auth=auth)
        response.raise_for_status()
        content_base64 = response.json().get('content')

        if content_base64:
            with open(reference, "wb") as file:
                file.write(base64.b64decode(content_base64))
            print(f"File downloaded successfully to {reference}")
        else:
            print("Error: No content received.")

    except Exception as e:
        print(f"Error downloading file: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Post a base64-encoded file to the REST service.")
    parser.add_argument("base_url", help="Base URL of the REST service (e.g., http://localhost:52773/csp/restdemo2/docdemo/v1)")
    parser.add_argument("username", help="Username for basic authentication")
    parser.add_argument("password", help="Password for basic authentication")
    parser.add_argument("reference", help="reference of the file to be downloaded")

    args = parser.parse_args()
    download_file(args.base_url, args.username, args.password, args.reference)
