# MySQL Database for Azure OpenAI Metrics 

## Introduction
The MySQL Database for Azure OpenAI is designed to capture and store metrics for API completion calls related to your Azure OpenAI service. This README provides an overview of the database structure, its purpose, objectives, and how it can be utilized effectively. 

## Purpose 
The primary purpose of the MySQL Database for Azure OpenAI is to capture and store detailed metrics for API completion calls. These metrics include various attributes such as prompt details, user information, model performance, cost calculations, application sources, response latency, and token consumption. By maintaining this data, we aim to provide insights into the performance and usage of the Azure OpenAI service, enabling better decision-making and optimization.

## Objectives 
1. **Data Capture**: To accurately capture and store metrics related to API completion calls.
2. **Data Integrity**: To ensure the integrity and consistency of the captured data.
3. **Performance Monitoring**: To provide a mechanism for monitoring the performance and usage of the AOAI service.
4. **Cost Analysis**: To facilitate cost analysis based on the captured token consumption.
5. **User Insights**: To offer insights into user interactions and prompt usage.
6. **Application Monitoring**: To track which applications are making API calls.
7. **Latency Analysis**: To capture and analyze latency between request and response times.
8. **Token Consumption**: To monitor and analyze token consumption for different models.

## Overview of the Database
The MySQL Database for Azure OpenAI consists of 6 tables, 3 views, and 1 stored procedure. Below is an overview of these components:

<img width="900" alt="Image" src="https://github.com/user-attachments/assets/23792404-fef8-4c2f-bc27-d6c256f00d2f" />

### Tables  
  
1. **aoaisystem**: Stores the AOAI system prompt, application in which the system prompt belongs to, and a linked number for each system prompt, as system prompts can be dynamic.  
   - `system_id` (INT, Primary Key, Auto Increment)  
   - `system_prompt` (MEDIUMTEXT)  
   - `system_proj` (VARCHAR(100))  
   - `prompt_number` (INT)

    <img width="841" alt="Image" src="https://github.com/user-attachments/assets/78d40623-9471-402d-9d85-180b5062e672" />
  
2. **python_api**: Stores the Python/Web-based APIs used to insert AOAI metrics into the MySQL db, such as ***code_api*** or ***apim_api***.  
   - `api_id` (INT, Primary Key, Auto Increment)  
   - `api_name` (VARCHAR(2048))
  
    <img width="152" alt="Image" src="https://github.com/user-attachments/assets/532eb8bf-4fe3-46c6-9564-b93497735eb8" />
  
3. **models**: Stores the AOAI models used to make API calls, the prompt and completion price per token consumption for the model, and the tiktoken encoding class for the model.  
   - `model_id` (INT, Primary Key, Auto Increment)  
   - `model` (VARCHAR(255))  
   - `prompt_price` (DECIMAL(10,6))  
   - `completion_price` (DECIMAL(10,6))  
   - `tiktoken_encoding` (VARCHAR(45))
  
    <img width="278" alt="Image" src="https://github.com/user-attachments/assets/ebe17229-816b-4dbe-984b-63616bca2dd3" />
  
4. **users**: Stores the user credentials from Entra ID for each API call a user makes for their prompt. 
***Note: The user's Entra Object ID is used as the primary key for this table.***
   - `entra_object_id` (VARCHAR(36), Primary Key)  
   - `entra_principal_name` (VARCHAR(255))
  
    ![Image](https://github.com/user-attachments/assets/1ff5dd76-646c-475d-9f25-02f70ccc1e32)
  
5. **prompt**: Stores details about user prompts, token consumption for user prompts, cost for user prompts ONLY, and timestamps in which user prompts were asked. Each prompt in this table is related to a ***system prompt*** from ***aoai_system*** and a ***user*** from ***users***. 
   - `prompt_id` (INT, Primary Key, Auto Increment)  
   - `system_id` (INT, Foreign Key)  
   - `user_prompt` (MEDIUMTEXT)  
   - `tokens` (INT)  
   - `price` (DECIMAL(10,5))  
   - `timestamp` (VARCHAR(20))  
   - `entra_object_id` (VARCHAR(36), Foreign Key)
  
    <img width="360" alt="Image" src="https://github.com/user-attachments/assets/80a1297b-0c80-4c05-999c-c19223ad3d89" />
  
6. **chat_completions**: Stores details about chat completions (LLM responses), token consumption for chat completions (including prompts and responses combined), cost for chat completions (including prompts and responses combined), Azure AI search scores for retrieved documents (only applicable with RAG API calls in ***code_api***), and timestamps in which user prompts were asked. Each chat completion in this table is related to a ***AOAI model*** from ***models***, a ***user prompt*** from ***prompt***, and a ***Python/Web-Based API*** from ***python_api***. 
   - `completion_id` (INT, Primary Key, Auto Increment)  
   - `model_id` (INT, Foreign Key)  
   - `prompt_id` (INT, Foreign Key)  
   - `api_id` (INT, Foreign Key)  
   - `chat_completion` (MEDIUMTEXT)  
   - `tokens` (INT)  
   - `price` (DECIMAL(10,5))  
   - `search_score` (DECIMAL(10,7))  
   - `timestamp` (TIMESTAMP, Default CURRENT_TIMESTAMP)

    <img width="414" alt="Image" src="https://github.com/user-attachments/assets/abe01210-2355-46e8-976b-add4bc727737" />
  
### Views  
  
1. **aoai_cost_total**: Provides a summary of cost metrics by month and day. Summary of each column:
    - `Month`: The year and month in which the costs were incurred.
    - `Day`: The specific day on which the costs were incurred.
    - `Sum total from prompt only ($)`: The total cost of prompts for each day.
    - `Sum total from prompt + ai response ($)`: The total cost of both prompts and AI responses for each day.
    - `Cumulative Sum from prompt only ($)`: The cumulative (running) total cost of prompts up to each day.
    - `Cumulative Sum Total ($)`: The cumulative (running) total cost of both prompts and AI responses up to each day.
  
    <img width="429" alt="Image" src="https://github.com/user-attachments/assets/fcc10ed8-5413-4bad-bc06-17e2188e95e3" />
  
2. **aoai_metadata**: Provides detailed metadata about prompts and completions. Summary of each column:
    - `System prompt`: The system prompt for the AOAI model. 
    - `Prompt Number`: A Linked number for each system prompt, useful for dynamic system prompts. 
    - `User prompt`: The text of the prompt provided by user. 
    - `User prompt tokens`: The number of tokens in the user prompt. 
    - `Prompt price`: The cost associated with the user prompt. 
    - `Time asked`: The time when the user sumbits their prompt. 
    - `AI response`: The response text returned back from the AOAI model. 
    - `AI response tokens`: The number of tokens in the ai response. 
    - `Completion price`: The cost associated with the ai completion. 
    - `Search score`: The Azure AI Search retrieval score for docs (only used for RAG scenarios). 
    - `Time answered`: The time when the AOAI model returns the response.
    - `AI model`: The AOAI model(s) used for the response. 
    - `AOAI MySQL API`: The API used to submit metrics to the MySQL db. `code_api` or `apim_api`.
  
    <img width="841" alt="Image" src="https://github.com/user-attachments/assets/658b5e23-c58f-4ced-9323-7441f49bf368" />
  
3. **aoai_users_metadata**: Provides detailed metadata about user interactions and prompts. Identical to the **aoai_metadata** view, except now we capture user metrics from Entra ID. 
   - `System prompt`: The system prompt for the AOAI model. 
   - `Prompt Number`: A Linked number for each system prompt, useful for dynamic system prompts. 
   - `Active User`: The user identification who submitted the user prompt. 
   - `User prompt`: The text of the prompt provided by user. 
   - `User prompt tokens`: The number of tokens in the user prompt. 
   - `Prompt price`: The cost associated with the user prompt. 
   - `Time asked`: The time when the user sumbits their prompt. 
   - `AI response`: The response text returned back from the AOAI model. 
   - `AI response tokens`: The number of tokens in the ai response. 
   - `Completion price`: The cost associated with the ai completion. 
   - `Search score`: The Azure AI Search retrieval score for docs (only used for RAG scenarios). 
   - `Time answered`: The time when the AOAI model returns the response.
   - `AI model`: The AOAI model(s) used for the response. 
   - `AOAI MySQL API`: The API used to submit metrics to the MySQL
  
  
### Stored Procedures  
  
1. **UpdateUserName**: Procedure to update the user's principal name when inserted to the database dynamically. 
   - Parameters:  
     - `p_new_name` (VARCHAR(255))  
         - Add the preffered new user identification here. Example include: username, email, first and last name, etc. 
     - `p_entra_object_id` (CHAR(36))  
         - Add the Entra object ID here. You can find it in Microsoft Entra ID under Users in the Azure portal or in the users table of the MySQL database, assuming the user has already submitted a prompt and their object ID has been added.
  
### Example Usage  
  
To create the database and all its components, execute the provided [SQL script](./aoai_api_v3.sql). The script will:  
1. Create the schema `aoai_api`.  
2. Create the tables `aoaisystem`, `python_api`, `models`, `users`, `prompt`, and `chat_completions`.  
3. Create placeholder tables for views.  
4. Create the stored procedure `UpdateUserName`.  
5. Create the views `aoai_cost_total`, `aoai_metadata`, and `aoai_users_metadata`.  
  
## Conclusion  
  
The AOAI Metrics Database is a powerful tool designed to capture and analyze metrics related to AOAI API completion calls. By leveraging the structured data stored in this database, users can gain valuable insights into the performance and usage of the AOAI system, including application sources, response latency, and token consumption. We hope this README provides a clear understanding of the database structure and its objectives. For any further assistance, please refer to the detailed SQL script provided.  
