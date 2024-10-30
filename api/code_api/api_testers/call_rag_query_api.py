'''
This script is designed to test the MySQL API using eligible GPT and ADA models specifically 
for RAG scenarios, where embeddings for queries are generated and documents are retrieved from Azure AI Search.

Findings:
- Azure AI Search uses a default embedding model if no custom model is specified.
- To use your own model, specify model in AzureSearch(). Then call model in embedding_function parameter in the AzureAISearchRetriever().

Update 9/23/24
'''

import os
from langchain_community.retrievers import AzureAISearchRetriever
from dotenv import load_dotenv
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_openai import AzureChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage
import requests
from datetime import datetime, timezone 
import json

load_dotenv()
api_key = os.getenv('OPENAI_API_KEY')  
endpoint = os.getenv('OPENAI_API_BASE')
api_version = os.getenv('OPENAI_API_VERSION')  
address = os.getenv('AZURE_AI_SEARCH_URL')  
index_name = os.getenv('AZURE_AI_SEARCH_INDEX')
password = os.getenv('AZURE_AI_SEARCH_KEY')  
gpt_model = os.getenv('OPENAI_GPT_MODEL')
ada_model = os.getenv('OPENAI_ADA_MODEL')

def get_time():  
    # Capture the current date and time in UTC (MySQL Native timezone)  
    current_utc_time = datetime.now(timezone.utc)  
    # Format the date and time to the desired string format  
    formatted_time = current_utc_time.strftime('%Y-%m-%d %H:%M:%S')  
    return formatted_time  

retriever = AzureAISearchRetriever(service_name=address,api_key=password,top_k=1, index_name=index_name)
# Create your LLM object, which is the LLM service provider
llm = AzureChatOpenAI(azure_endpoint=endpoint, api_key=api_key, api_version=api_version, azure_deployment=gpt_model, temperature=0.7)
contextualize_q_system_prompt = """Given a chat history and the latest user question \
which might reference context in the chat history, formulate a standalone question \
which can be understood without the chat history. Do NOT answer the question, \
just reformulate it if needed and otherwise return it as is."""
contextualize_q_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", contextualize_q_system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)
history_aware_retriever = create_history_aware_retriever(
    llm, retriever, contextualize_q_prompt
)

# Create a custom prompt for the LLM to be directed (needed for create_stuff_documents_chain)
qa_system_prompt = """You are a q/a assistant. A friendly bot designed to have unqiue conversations. \
You must be talkative and provide lots of specific details from the conversation context. \
Only answer questions based on given context. If answer not in context, say I do not know. \
Context: {context}
"""
qa_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", qa_system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)

# Create chain for LLM to answer questions from retrieved documents 
combine_docs_chain = create_stuff_documents_chain(llm=llm, prompt=qa_prompt)

# Create chain to retrieve documents
retrieval_chain = create_retrieval_chain(retriever=history_aware_retriever, combine_docs_chain=combine_docs_chain)

chat_history = []
count = 0
while True:
    # Collect user prompt
    query = input("\nYou: ")
    time_asked = get_time()
    # Execute the retrieval chain on question
    chain = retrieval_chain.invoke({"input": query, "chat_history": chat_history})
    chat_history.extend([HumanMessage(content=query), chain["answer"]])
    # Initialize object that holds sources in the returned dictionary
    sources = [] 
    page_contents = []
    search_scores = []
    # print(chain)
    for doc in chain['context']:
        source = doc.metadata['metadata']
        page_content = doc.page_content
        search_score = doc.metadata['@search.score']
        # print(type(search_score))
        sources.append(source)
        page_contents.append(page_content)
        search_scores.append(search_score)
    # Print out LLM answer and sources. 
    print(f"\nAnswer: {chain['answer']}")
    source = "".join(sources)
    print(f"\nSource: {source}\n\n")
    page_content = "".join(page_contents) 
    search_score = search_scores[0]
    system_prompt = qa_system_prompt.replace("{context}", page_content)
    # Call MySQL API to capture metadata (make sure api is running locally)
    url = "https://code-api.azurewebsites.net/code_api"  
    
    # The following data must be sent as payload with each API request.
    data = {  
        "system_prompt": f"{system_prompt}\n\n{contextualize_q_system_prompt}\n{str(chat_history)}",  # All system prompts used including retrieved docs and any memory
        "user_prompt": query,  # User prompt in which the end-user asks the model. 
        "time_asked": time_asked, # Time in which the user prompt was asked.
        "response": chain['answer'],  # Model's answer to the user prompt
        "search_score": search_score, # Score for retrieved docs
        "deployment_model": f'{gpt_model}, {ada_model}', # Input your model deployment names here
        "name_model": "gpt-4o, text-embedding-ada-002",  # Input your models here
        "version_model": "2024-05-13, 2",  # Input your model version here. NOT API VERSION.
        "region": "East US 2",  # Input your AOAI resource region here
        "project": "Retriever (API Test)",  # Input your project name here. Following the system prompt for this test currently :)
        "api_name": url, # Input the url of the API used. 
        "retrieve": True, # Set to True, indicating you are utilizing RAG.
        "database": "mysqldb" # Set to cosmosdb or mysqldb depending on desired platform
    }  
    
    response = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(data))  
    
    print(response.status_code)  
    print(response.json())  