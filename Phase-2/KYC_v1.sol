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
	address admin;
	
	constructor () public payable {
	    admin = msg.sender;
    	}
    	
    // BANK INTERFACE 
    	
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
	
	function addRequest(bytes32 user_name, bytes32 data_hash) public payable{
	    if(isPartOfBanks() && checkKycPermission()){
	        allRequests.length++;
	        allRequests[allRequests.length-1] = KYC_Request(user_name, msg.sender, data_hash);
	        for(uint i=0;i<allBanks.length;i++){
	            if(allBanks[i].eth_address == msg.sender)
	                allBanks[i].kyc_count++;
	        }
	    }
	}
	
    function addCustomer(bytes32 user_name, bytes32 data_hash) public payable {
        if (!checkIfCustomerIsPresent(user_name) && isPartOfBanks()){
            allCustomers.length++;
            allCustomers[allCustomers.length-1] = Customer(user_name, data_hash, true, 0, 0, msg.sender);
        }
    }
    function removeRequest(bytes32 user_name, bytes32 data_hash) public payable {
        if(isPartOfBanks() && checkKycPermission() && allRequests.length != 0){
            for(uint i=0; i<allRequests.length; i++){
                if(allRequests[i].user_name == user_name){
                    for(uint j=i+1;j< allRequests.length;j++){
                        allRequests[j-1]=allRequests[j];
                    }    
                    allRequests.length--;
                    for(uint k=0;k < allBanks.length;k++){
	                    if(allBanks[k].eth_address == msg.sender)
	                        allBanks[k].kyc_count--;
	                }
                }
            }
        }
    }
    
	function removeCustomer(bytes32 user_name) public payable {
        if(isPartOfBanks()){
            // uint idx;
            for(uint i=0;i<allCustomers.length;i++){
                if (allCustomers[i].user_name == user_name && allCustomers[i].bank_addr == msg.sender){
                    // idx = i;
                    removeRequest(allCustomers[i].user_name, allCustomers[i].data_hash);
                    for(uint j=i+1; j < allCustomers.length; j++){
                        allCustomers[j-1]=allCustomers[j];
                    }
                    allCustomers.length--;
                }
            }
                
        }
    }
    
    function viewCustomer(bytes32 user_name) public payable returns (bytes32, bytes32){
        if(isPartOfBanks() && checkIfCustomerIsPresent(user_name)){
            for(uint i=0;i< allCustomers.length; i++){
                if(allCustomers[i].user_name == user_name)
                    return (allCustomers[i].user_name,allCustomers[i].data_hash);
            }
        }    
    }
    
    function upvoteCustomer(bytes32 user_name) public payable {
        if(isPartOfBanks() && checkIfCustomerIsPresent(user_name)){
            for(uint i=0; i<allCustomers.length; i++){
                if(allCustomers[i].user_name == user_name)
                    allCustomers[i].up_votes++;
            }
        }
    }
    
    function downvoteCustomer(bytes32 user_name) public payable {
        if(isPartOfBanks() && checkIfCustomerIsPresent(user_name)){
            for(uint i=0; i< allCustomers.length;i++){
                if(allCustomers[i].user_name == user_name)
                    allCustomers[i].down_votes--;
            }
        }
    }
    
    // have to complete this function
    function modifyCustomer(bytes32 user_name, bytes32 data_hash) public payable {
        if(isPartOfBanks()){
            for(uint i=0;i< allCustomers.length; i++){
                if (allCustomers[i].user_name == user_name){
                    allCustomers[i].data_hash = data_hash;
                    allCustomers[i].bank_addr = msg.sender;
                    allCustomers[i].up_votes = 0;
                    allCustomers[i].down_votes = 0;
                    for(uint j=0;j < allRequests.length; j++ ){
                        if(allRequests[i].user_name == allCustomers[i].user_name){
                            for(uint k =j+1;k< allRequests.length;k++){
                                allRequests[j-1] = allRequests[j];
                            }
                            allRequests.length--;
                    	    for(uint k=0;k < allBanks.length;k++){
        	                if(allBanks[k].eth_address == msg.sender)
        	                    allBanks[k].kyc_count++;
	                        }
                        }
                    }
                }
            }
        }
    }
    
    function getBankReports(address bank_addr) public view returns (uint){
        for(uint i=0;i< allBanks.length;i++){
            if(allBanks[i].eth_address == bank_addr)
                return allBanks[i].report;
        }
    }
    
    function getCustomerStatus(bytes32 user_name) public view returns (bool){
        for(uint i=0;i< allCustomers.length; i++){
            if(allCustomers[i].user_name == user_name)
                return allCustomers[i].kyc_status;
        }   
    }
    
    function viewBankDetails(address bank_addr) public view returns (bytes32){
        for(uint i=0; i< allBanks.length;i){
            if(allBanks[i].eth_address == bank_addr)
                return allBanks[i].bank_name;
        }
    }
    
    // ADMIN INTERFACE
    
    function addBank(bytes32 bank_name, address eth_address, bytes32 reg_number) public payable {
        if(admin == msg.sender){
            allBanks.length++;
            allBanks[allBanks.length - 1] = Bank(bank_name, eth_address, 0, 0, true, reg_number); 
        }
    }
    
    function modifyBankKycPermission(address bank_addr) public payable{
        if(admin == msg.sender){
            for(uint i=0;i<allBanks.length;i++){
                if(allBanks[i].eth_address == bank_addr){
                    allBanks[i].kyc_permission = !allBanks[i].kyc_permission;
                }
            }
        }
    }
    
    function removeBank(address bank_addr) public payable {
        if(admin == msg.sender){
            for(uint i=0;i < allBanks.length;i++){
                if(allBanks[i].eth_address == bank_addr){
                    for(uint j= i+1; j<allBanks.length;j++){
                        allBanks[j-1] = allBanks[j];
                    }
                    allBanks.length--;
                }
            }
        }
    }
    
}