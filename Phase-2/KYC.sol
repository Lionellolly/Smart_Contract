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
	
	Customer[] allCustomers;
	
	Bank[] allBanks;
	
	KYC_Request[] allRequests;
	
	constructor () public{
    	}
	function checkIfCustomerIsPresent(bytes32 user_name) public view returns (bool){
	    for (uint i=0; i<allCustomers.length;i++){
	        if (allCustomers[i].user_name == user_name)
	            return true;
	    }
	    return false;
	}
	
	function isPartOfBanks() public payable returns (bool){
	    for(uint i=0;i<allBanks.length; i++){
	        if(allBanks[i].eth_address== msg.sender)
	            return true;
	    }
	    return false;
	}
	
	function checkKycPermission() public payable returns (bool){
	    for(uint i=0; i< allBanks.length;i++){
	        if(allBanks[i].eth_address == msg.sender)
	         return true;
	    }
	    return false;
	}
	
	function addRequest(bytes32 user_name, bytes32 data_hash)public payable{
	    if(isPartOfBanks() && checkKycPermission()){
	        allRequests.length++;
	        allRequests[allRequests.length-1] = KYC_Request(user_name, msg.sender,data_hash);
	    }
	}
	
    function addCustomer(bytes32 user_name, bytes32 data_hash) public payable {
        if (!checkIfCustomerIsPresent(user_name) && isPartOfBanks()){
            allCustomers.length++;
            allCustomers[allCustomers.length-1] = Customer(user_name, data_hash, true, 0, 0, msg.sender);
        }
    }
    
	function removeCustomer(bytes32 user_name) public payable {
        if(isPartOfBanks()){
            address temp;
            for(uint i=0;i<allCustomers.length;i++){
                if (allCustomers[i].user_name== user_name){
                    temp = allCustomers[i].bank_addr;
                    for(uint j=i+1;j<allCustomers.length;j++){
                        allCustomers[j-1]=allCustomers[j];
                    }
                    allCustomers.length--;
                }
            }
                
        }
    }
    
    function modifyCustomer(bytes32 user_name, bytes32 data_hash) public payable {
        if(isPartOfBanks()){
            for(uint i=0;i< allCustomers.length; i++){
                if (allCustomers[i].user_name == user_name){
                    allCustomers[i].data_hash = data_hash;
                    allCustomers[i].bank_addr = msg.sender;
                }
            }
        }
    }
    
    function viewCustomer(bytes32 user_name) public returns (bytes32){
        if(isPartOfBanks() && checkIfCustomerIsPresent(user_name)){
            for(uint i=0;i< allCustomers.length; i++){
                if(allCustomers[i].user_name == user_name)
                    return allCustomers[i].data_hash;
            }
        }    
    }
    
}