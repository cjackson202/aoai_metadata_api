'''
This script is designed to test the MySQL API using eligible GPT models specifically for chat scenarios 
where Retrieval-Augmented Generation (RAG) is not needed.

Updated 9/23/24
'''

import requests  
import json  
import os
from openai import AzureOpenAI
from datetime import datetime, timezone

def get_time():
    # Capture the current date and time in UTC (MySQL Native timezone)
    current_utc_time = datetime.now(timezone.utc)  
    # Format the date and time to the desired string format  
    formatted_time = current_utc_time.strftime('%Y-%m-%d %H:%M:%S') 
    return formatted_time 

while True:
    # Make AOAI request
    api_key = os.getenv("OPENAI_API_KEY")
    endpoint = os.getenv("OPENAI_API_BASE")
    deployment_name = os.getenv("OPENAI_GPT_MODEL")
    api_version = os.getenv("OPENAI_API_VERSION")
    system_prompt = "You are a funny Disney character. Make the user guess your name."
    user_prompt = input("\nYou: ")
    time_asked = get_time()
    client = AzureOpenAI(
    azure_endpoint=endpoint,
    api_key=api_key,
    api_version=api_version
    )
    response = client.chat.completions.create(
    model=deployment_name,
    messages=[
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_prompt}
    ]
    )

    ai_response_dict = response.to_dict()
    ai_response = ai_response_dict['choices'][0]['message']["content"]
    print(f"GPT: {ai_response}\n\n")


    # Call MySQL API to capture metadata (make sure api is running locally)
    url = "https://code-api.azurewebsites.net/code_api"  
    
    # The following data must be sent as payload with each API request.
    data = {  
        "system_prompt": system_prompt,  # System prompt given to the AOAI model.
        "user_prompt": user_prompt,  # User prompt in which the end-user asks the model. 
        "time_asked": time_asked, # Time in which the user prompt was asked.
        "response": ai_response,  # Model's answer to the user prompt
        "deployment_model": deployment_name, # Input your model's deployment name here
        "name_model": "gpt-4o",  # Input you model here
        "version_model": "2024-05-13",  # Input your model version here. NOT API VERSION.
        "region": "East US 2",  # Input your AOAI resource region here
        "project": "Disney Character (API Test)",  # Input your project name here. Following the system prompt for this test currently :)
        "api_name": url, # Input the url of the API used. 
        "database": "mysqldb" # Specify here cosmosdb or mysql as database. 
    }  
    
    response = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(data))  
    
    print(response.status_code)  
    print(response.json())  