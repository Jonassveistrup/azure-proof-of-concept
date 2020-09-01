pragma solidity ^0.4.20;

contract WorkbenchBase {
	event WorkbenchContractCreated(string applicationName, string workflowName, address originatingAddress);
	event WorkbenchContractUpdated(string applicationName, string workflowName, string action, address originatingAddress);

	string internal ApplicationName;
	string internal WorkflowName;

	function WorkbenchBase(string applicationName, string workflowName) internal {
		ApplicationName = applicationName;
		WorkflowName = workflowName;
	}

	function ContractCreated() internal {
		WorkbenchContractCreated(ApplicationName, WorkflowName, msg.sender);
	}

	function ContractUpdated(string action) internal {
		WorkbenchContractUpdated(ApplicationName, WorkflowName, action, msg.sender);
	}
}

contract Dfakturering_v14 is WorkbenchBase("Dfakturering_v14","Dfakturering_v14") {

	enum StateType {Created, CanBeNegotiated, IsNegotiating, InvoiceAccepted, Paid, Cancelled, Failed, Passed}
	StateType public State;			// The state of the Invoice
	address public Invoicer; 	   	// Product seller
	address public Receiver;    	// Receiver of invoice
	address public Auditor;    		// Auditorname of Seller
	address public Negotiator;    	// The suggester
	address public ReceiverBank;    // The bank of the receiver

	string public Comment;

	string public FilePath; 		// The path of the file
	bytes32 public FileHash; 		// Not a real filehash, just the hash of the filepath
	int public Price;    			// Price in currency
	int public VAT;    				// VAT percentage (25%)

	int public NewPrice;    		// New suggested price
	int public NewVAT;    			// New suggested VAT
	string public NewFilePath; 		// New suggested filepath


	// Constructor. -> this function is refered to as CreateInvoice in the sequence diagram
	function Dfakturering_v14(address receiver, address receiverBank, address invoicersAuditor, string filepath, int price, int vat) public {
		State = StateType.Created;

		Invoicer = msg.sender;
		Receiver = receiver;
		Auditor = invoicersAuditor;
		ReceiverBank = receiverBank;

		FilePath = filepath;
		FileHash = keccak256(bytes(filepath));

		Price = price;
		VAT = vat;
		ContractCreated();
	}

	function AuditOk() public {
		require(msg.sender == Auditor && State == StateType.Paid);
		State = StateType.Passed;
		ContractUpdated("AuditOk");
	}

	function AuditFail(string _comment) public {
		require(msg.sender == Auditor && State == StateType.Paid);
		State = StateType.Failed;
		Comment = _comment;
		ContractUpdated("AuditFail");
	}

	function Negotiate(string _filePath, int _price, int _vat, string _comment) public {
		require(State == StateType.CanBeNegotiated || State == StateType.IsNegotiating || State == StateType.Created);
		require(msg.sender == Receiver || msg.sender == Invoicer);

		Negotiator = msg.sender;
		NewVAT = _vat;
		NewPrice = _price;

		NewFilePath = _filePath;

		State = StateType.IsNegotiating;
		Comment = _comment;

		ContractUpdated("Negotiate");
	}

	function AcceptNegotiation() public {
		require(State == StateType.IsNegotiating);
		require(msg.sender == Receiver || msg.sender == Invoicer);
		require(msg.sender != Negotiator);

		Price = NewPrice;
		VAT = NewVAT;
		FilePath = NewFilePath;
		FileHash = keccak256(bytes(NewFilePath));

		NewPrice = 0;
		NewVAT = 0;
		Negotiator = 0;
		NewFilePath = "";

		State = StateType.CanBeNegotiated;

		ContractUpdated("AcceptNegotiation");
	}

	function AcceptInvoice() public{
		require(State == StateType.CanBeNegotiated || State == StateType.Created);
		require(msg.sender == Receiver);

		State = StateType.InvoiceAccepted;
		ContractUpdated("InvoiceAccepted");
	}

	//This function illustrates how seller's bank can initiate the split payment between seller (price) and the authorities (VAT).
	function AcceptPayment() public{
		require(msg.sender == ReceiverBank && State == StateType.InvoiceAccepted);

		State = StateType.Paid;

		ContractUpdated("AcceptPayment");
	}

	function CancelDeal(string _comment) public{
		require(State == StateType.CanBeNegotiated || State == StateType.IsNegotiating || State == StateType.Created);
		require(msg.sender == Receiver || msg.sender == Invoicer);

		State = StateType.Cancelled;
		Comment = _comment;

		ContractUpdated("CancelDeal");
	}
}
