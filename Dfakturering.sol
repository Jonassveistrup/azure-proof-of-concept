pragma solidity ^0.4.20;

contract AppBuilderBase {
	event AppBuilderContractCreated(string contractType, address originatingAddress);
	event AppBuilderContractUpdated(string contractType, string action, address originatingAddress);

	string internal ContractType;

	function AppBuilderBase(string contractType) internal {
		ContractType = contractType;
	}

	function ContractCreated() internal {
		AppBuilderContractCreated(ContractType, msg.sender);
	}

	function ContractUpdated(string action) internal {
		AppBuilderContractUpdated(ContractType, action, msg.sender);
	}
}

contract Dfakturering is AppBuilderBase("Dfakturering") {

	enum ContractStates { Created, CanBeNegotiated, IsNegotiating, NegotiationEndRequested, NegotiationFinished, PaymentSent, Paid, Cancelled, Failed, Passed }

	ContractStates public State;    // Invoice state
	address public Invoicer;    // Product seller
	address public Receiver;    // Receiver of invoice
	address public Auditor;    // Auditorname of Seller
	address public Negotiater;    // The suggester

	uint public Price;    // Price in currency
	uint public VAT;    // VAT percentage (25%)
	
	uint public NewPrice;    // New suggested price
	uint public NewVAT;    // New suggested VAT
	
	function Dfakturering(address receiver, address invoicersAuditor, uint price, uint vAT) {
		Invoicer = msg.sender;
		State = ContractStates.Created;
		Receiver = receiver;
		Auditor = invoicersAuditor;
		Price = price;
		VAT = vAT;

		ContractCreated();
	}
	function Review(bool passed) public {
		require(msg.sender == Auditor && State == ContractStates.Paid);
		
		State = passed ? ContractStates.Passed : ContractStates.Failed;		

		ContractUpdated("Review");
	}

	function Negotiate(uint _price, uint _vat) public {
	    require(State == ContractStates.CanBeNegotiated || State == ContractStates.NegotiationEndRequested || State == ContractStates.IsNegotiating || State == ContractStates.Created);
	    require(msg.sender == Receiver || msg.sender == Invoicer);
	
	    Negotiater = msg.sender;
	    NewVAT = _vat;
	    NewPrice = _price;

	    State = ContractStates.IsNegotiating;
	
		ContractUpdated("Negotiate");	
	}

	function AcceptNegotiation() public {
		require(State == ContractStates.IsNegotiating);
		require(msg.sender == Receiver || msg.sender == Invoicer);
		require(msg.sender != Negotiater);

		Price = NewPrice;
		VAT = NewVAT;

		NewPrice = 0;
		NewVAT = 0;
		Negotiater = 0;

		State = ContractStates.CanBeNegotiated;

		ContractUpdated("AcceptNegotiation");
	}

	function RequestNegotiationEnd() public{
		require(State == ContractStates.CanBeNegotiated);
		require(msg.sender == Receiver || msg.sender == Invoicer);
		require(Negotiater == address(0));

		Negotiater = msg.sender;
		State = ContractStates.NegotiationEndRequested;

		ContractUpdated("RequestNegotiationEnd");
	}

	function AcceptNegotiationEnd() public{
		require(State == ContractStates.NegotiationEndRequested);
		require(msg.sender == Receiver || msg.sender == Invoicer);
		require(Negotiater != msg.sender);

		State = ContractStates.NegotiationFinished;

		ContractUpdated("AcceptNegotiationEnd");
	}

	function SendPayment() public{
		require(State == ContractStates.NegotiationFinished || State == ContractStates.Created);
		require(msg.sender == Receiver);

		State = ContractStates.PaymentSent;

		ContractUpdated("SendPayment");
	}

	function AcceptPayment() public{
		require(msg.sender == Invoicer && State == ContractStates.PaymentSent);

		State = ContractStates.Paid;

		ContractUpdated("AcceptPayment");
	}

	function CancelDeal() public{
		require(State == ContractStates.CanBeNegotiated || State == ContractStates.NegotiationEndRequested || State == ContractStates.IsNegotiating || State == ContractStates.Created);
		require(msg.sender == Receiver || msg.sender == Invoicer);

		State = ContractStates.Cancelled;

		ContractUpdated("CancelDeal");
	}
}