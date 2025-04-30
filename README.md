# Lil-Hearts
## TDX 2025 Agentforce Hackathon
Detailed Design and Solution flow

<img width="1198" alt="Image" src="https://github.com/user-attachments/assets/3911ad47-0b21-4ccc-b83d-609d4201e485" />

## Solution Architecture and Assumptions
1. Einstein Data Library – primarily used to upload the Knowledge Files to the library and lets RAG to perform its Vectorization
techniques and converting the file into series of chunks ( Tried AWS Approach as well )
2. Data Cloud – Data Cloud provides the support to the chunks by storing them in the DLO, DSO and store the Retriever
information of the Library which can be referred at prompt builder.
3. Prompt Builder – Prompt builder is used of multiple use cases such as
    * Generating Email Body.
    * Generating Prompt response for Knowledge answers.
    * Calculating the shortest distance.
    * Summarize the Case based on the record snapshot.
4. Flow Actions – Responsible for multiple use cases such as,
    * Calling required prompt actions
    * Record retrieval from the custom object
    * Create and modify the records.
    * Send Email to the customer
    * Prompt Template triggered flow
5. Custom Objects – Responsible for capturing multiple record information, custom objects created as part of this architecture
are as below,
    * LH_Appointment__c
    * Customer__C
    * LH_Order__c
    * Lil_Hearts_Clinic__c
    * Medical_Prescription__c
    * Medicine_Product__c
    * Medicine__c
    * Slots__c
    * Daycare_Center__c
6. Agent Builder – Lets us to create and configure the Agentforce Service Agent via Actions and topics.
7. Agent Topics – Defines the behavior of the agent via topics for every use cases,
    * Medical Prescription
    * Knowledge Answer
    * Immediate Advisory
    * Case Information
    * Assist with Daycare Centers
    * Appointment Management
    * Doctor Query (Chart)
9. Agent Actions– N Number of actions have been used under the topics for seamless conversation.
10. Omni – Channel Routing – Responsible for routing the sessions to the AI Agent
11. Experience site – The agent is embedded on this page for the customer to access the agent. The Page has welcoming image
brief description of the services of Lil’ Hearts.
12. LWC – A component was created to let the users upload the images to the case and Google Vision.
13. Google Vision – Lets the user to upload the prescription image and place order for the available medicines.
