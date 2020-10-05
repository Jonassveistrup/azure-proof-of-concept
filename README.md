# A Blockchain-enabled Platform for VAT Settlement

Find the smart contract code (.sol) , web application meta data-code (.json), a overview of components in the Azure Blockchain Workbench, a state machine overview and a demonstration video in this repo.
In order for the code to work, deploy it inside Azure Blockchain Workbench (https://azure.microsoft.com/en-us/features/blockchain-workbench/)

# Details of artifact implementations
This section provides an overview of Azure Blockchain Workbench solution architecture and a description of the main components.

## Solution architecture
Fig. 1 shows the three logical areas of the architecture: 1) the DLT and data storage types; 2) web, app and smart contracts; and 3) user and key management. The architecture fits with the proposed generic model presented by Xu et al. (2019) whereas the architecture presented by Glaser (2017) does not articulate what Xu et al. (2019) refer to as auxiliary databases. Understanding the context and not only focusing on the DLT component are critical when deploying blockchain technology in an enterprise setting.

![](Solution_architecture.png)
Fig. 1. Solutions architecture

### Web, app and smart contracts
The artifact is, as described in the paper, a prototype. However, a key advantage of the Azure Blockchain Workbench lies in its built-in web application for quick demonstration purposes. This logical area has five subcomponents: user administration; web, app, business reporting; and smart contracts. The user administration module affords users from the Azure Active Directory access to a given role within the application. For example, an external auditor from an accounting firm can be appointed a user of the platform and thus receive necessary access rights to fulfil this role for a given client. I recommend that the validating nodes share governance responsibility of user administration. The web application corresponds to a regular website that users can access via a browser on any device. During the development of the prototype, I used the premade web application and made sure that time spent on development was dedicated to smart contracts. The segregation of the API-based frontend and smart contract code minimizes switching costs when the solution must be directly integrated with an ERP system or other endpoints. 

### User and key management
An enterprise blockchain solution will typically involve multiple actors from different organizations. A key vault is used to store and connect users to their associated addresses on the blockchain. Since each network member must have a known and unique identity, it is important that the validators can safely acquire a unique active identity on the network. This requires a solution that manages user identities and inherent privileges from the organizations’ user management systems (typically, an active directory (AD)). The Azure Blockchain Workbench offers an Azure Active Directory (AAD) tenant that functions as a dedicated delimited container that manages access to the solutions on Azure. In addition, the AAD allows for the configuration of guest ADs that the solution trusts, resulting in simpler user and access control than that provided by standalone blockchain solutions. For example, the platform's AAD can rely on ADs from the Danish Business Authority, the Danish Tax Authority, and other relevant authorities and SMEs who want to use their existing ADs. This decentralized user management system requires that when an employee leaves his or her position in an organization, it will be the organization's own AD that indirectly refuses access to the platform. The solution can then be integrated with e-ID through the next iterations of the artifact. The key management component described here makes it easier for SMEs to connect their existing ADs and to ensure that existing governance structures enacted by the AD can be transferred to the platform.

### Data storage
As the architecture illustrated in Fig. 9 shows, data are stored in multiple places both on the ledger and in a database (SQL DB). Data are stored in both places because distributed ledgers are still very limited in their ability to manage financial reporting and tax issues whereas a traditional relational database is a mature and well-tested technology. The Azure Blockchain Workbench allows business reports to be prepared. As shown in Fig. 9, the service bus connects the blockchain components to a database. The database receives a copy of all data from the blockchain and makes these immediately available in reporting form, allowing authorities to receive the data from a dashboard of their choice. Data synchronization occurs instantly before the ledger reaches consensus. After the consensus round, the API updates the transaction data whether it has reached consensus or not. 
