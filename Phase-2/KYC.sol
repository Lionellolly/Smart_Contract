pragma solidity ^0.5.9;

contract KYC {
	struct Customer{
    	bytes32 user_name;
    	bytes32 data_hash;
    	bool kyc_status;
    	uint down_votes;
    	uint up_votes;
    	address bank_addr;
	}
	struct Bank{
	    bytes32 bank_name;
	    address eth_address;
	    uint report;
	    uint kyc_count;
	    bool kyc_permission;
	    bytes32 reg_number;
	}
	struct KYC_Request{
        bytes32 user_name;
        address bank_addr;
        bytes32 data_hash;
	}
	
	mapping(bytes32 => Customer) public customersMap;
	mapping(address => Bank) public banksMap;
	mapping(bytes32 => KYC_Request) public requestsMap;
	
	uint bankCounts;
	
	address admin;
	
	constructor () public payable {
	    admin = msg.sender;
	    bankCounts = 0;
    	}
    	
    // --- BANK INTERFACE --- // 
    
    // checks whether customer is already present to add or remove from blockchain
	function checkIfCustomerIsPresent(bytes32 customer) public view returns (bool){
	    if(customersMap[customer].user_name == customer)
	        return true;
	    else
	        return false;
	}
	
    // checks if the bank is in the blockchain
	function isPartOfBanks(address bank_addr) public view returns (bool){
	    if(banksMap[bank_addr].eth_address == bank_addr)
	        return true;
	    else
	        return false;
	}
	
	// checks the kyc permission of the blockchain by checking the number of reports threshold
	function checkKycPermission(address bank_addr) public returns (bool){
	    if(banksMap[bank_addr].report < uint(bankCounts /3))
	        banksMap[bank_addr].kyc_permission = false;    
	    return banksMap[bank_addr].kyc_permission;
	}
	
    // adds the requests to the requests mapping
    // checks the bank's credibility and the kyc permissioning
	function addRequest(bytes32 customer, bytes32 data_hash) public payable{
	    if(isPartOfBanks(msg.sender) && checkKycPermission(msg.sender))
	        requestsMap[customer] = KYC_Request(customer, msg.sender, data_hash);
	    }
	
	// adds the customer if couple of checks passes
    function addCustomer(bytes32 customer, bytes32 data_hash) public payable {
        if (!checkIfCustomerIsPresent(customer) && isPartOfBanks(msg.sender))
            customersMap[customer] = Customer(customer, data_hash, true, 0, 0, msg.sender);
    }
    
    // removes the request if couple of checks passes
    function removeRequest(bytes32 customer, bytes32 data_hash) public payable {
        if(isPartOfBanks(msg.sender) && checkKycPermission(msg.sender) && requestsMap[customer].user_name == customer){
            address addr = requestsMap[customer].bank_addr;
            delete requestsMap[customer];
            banksMap[addr].kyc_count--;
        }
    }
    
    // removes the customer along with the kyc requests
	function removeCustomer(bytes32 customer) public payable {
        if(isPartOfBanks(msg.sender)){
            // removing the customer from customersMap
            delete customersMap[customer];
            
            // removing the single or mulitple requests raised by the customer from requestsMap
            while (requestsMap[customer].user_name == customer){
                address temp = requestsMap[customer].bank_addr;
                banksMap[temp].kyc_count--;
                delete requestsMap[customer];
            }
        }
	}
    
    // view the customer details
    function viewCustomer(bytes32 customer) public payable returns (bytes32, bytes32){
        if(isPartOfBanks(msg.sender) && checkIfCustomerIsPresent(customer))
            return (customersMap[customer].user_name, customersMap[customer].data_hash);
    }
    
    // upvote the customer rating points
    function upvoteCustomer(bytes32 customer) public payable {
        if(isPartOfBanks(msg.sender) && checkIfCustomerIsPresent(customer))
            customersMap[customer].up_votes++;
    }
    
    // downvote the customer rating points
    function downvoteCustomer(bytes32 customer) public payable {
        if(isPartOfBanks(msg.sender) && checkIfCustomerIsPresent(customer))
            customersMap[customer].down_votes--;
    }
    
    // modify the customer's data hash
    function modifyCustomer(bytes32 customer, bytes32 data_hash) public payable {
        if(isPartOfBanks(msg.sender)){
            customersMap[customer].data_hash = data_hash;
            customersMap[customer].bank_addr = msg.sender;
            customersMap[customer].up_votes = 0;
            customersMap[customer].down_votes = 0;
            
            while (requestsMap[customer].user_name == customer){
                address temp = requestsMap[customer].bank_addr;
                banksMap[temp].kyc_count--;
                delete requestsMap[customer];
        }
    }
    }

    //  get the bank reports count
    function getBankReports(address bank_addr) public view returns (uint){
        return banksMap[bank_addr].report;
    }
    
    // get the customer's kyc status
    function getCustomerStatus(bytes32 customer) public view returns (bool){
        return customersMap[customer].kyc_status;   
    }
    
    // view the bank name
    function viewBankDetails(address bank_addr) public view returns (bytes32){
        return banksMap[bank_addr].bank_name;
    }
    
    // ADMIN INTERFACE
    function addBank(bytes32 bank_name, address bank_addr, bytes32 reg_number) onlyAdmin public payable {
        banksMap[bank_addr] = Bank(bank_name, bank_addr, 0, 0, true, reg_number); 
        bankCounts;
    }
    
    // modifiers for admin access
    function modifyBankKycPermission(address bank_addr) onlyAdmin public payable {
        banksMap[bank_addr].kyc_permission = !banksMap[bank_addr].kyc_permission;
    }
    
    function removeBank(address bank_addr) onlyAdmin public payable {
        delete banksMap[bank_addr];
    }
    
    modifier onlyAdmin(){
        require(msg.sender == admin, "You are not an Administrator. Only admins can perform this function...");
        _;
    }
    
}