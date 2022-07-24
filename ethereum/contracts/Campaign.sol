pragma solidity ^0.4.17;

contract Campaign{
    struct Request{
        string description; //why spend request is beign created
        uint value; // amount of money manager wants to send to the vendor
        address recipient; //address that the money will be sent to
        bool complete;   // true if the request has already been processed(money sent)
        mapping(address=>bool) approvals; //track who has voted
        uint approvalCount;  // track no. of approvals
    }
    
    address public manager;
    // address of the person managing the campaign

    uint public minimumContribution;
     //min donation (in wei) required to be considered a 'contributor' or 'approver'

    mapping(address=>bool) public approvers;
    uint public approversCount;
    Request[] public requests;
    
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    
    function Campaign(uint minimum, address campaignCreator) public {
        // manager=msg.sender;  //sender property-> who is creating the contract
        //assign the address of contract creator to manager
        manager = campaignCreator;
        minimumContribution = minimum;
    }
    

    //called when someone wants to send money to contract and become approver
    //'payable' makes this function able to receive money
    function contribute() public payable{
         //makes sure contribution>=minimumContribution
        require(msg.value > minimumContribution);
        
        approvers[msg.sender] = true;
        
        approversCount++;
    }
    
    function createRequest(string description, uint value, address recipient) public restricted{
        Request memory newRequest = Request({
            description : description,
            value : value,
            recipient : recipient,
            complete : false,
            approvalCount : 0
        });
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public{
        Request storage request = requests[index];
        
        //make sure person calling this function has donated
        require(approvers[msg.sender]);

        //make sure the person calling this function hasn't voted before
        require(!request.approvals[msg.sender]);
        
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    
    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];
        
        require(!request.complete);
        require(request.approvalCount > (approversCount/2));
        //check if request is already finalized
        
        request.recipient.transfer(request.value);
        // request.recipient is an address so tranfer function can be used 
        request.complete = true;
    }

    function getSummary() public view returns(uint, uint, uint, uint, address){
       return(
            minimumContribution,
            this.balance,
            requests.length,
            approversCount,
            manager
       );
    }

    function getRequestCount() public view returns(uint){
        return requests.length;
    }
}

contract CampaignFactory{
    address[] deployedCampaigns;    // addresses of all deployed campaigns
    
    // deploys a new instance of a campaign and stores the resulting address
    function createCampaign(uint minimum) public{
            address newCampaign = new Campaign(minimum, msg.sender);
            deployedCampaigns.push(newCampaign);
    }
    
    // returns a list of all deployed campaigns
    function getDeployedCampaigns() public view returns (address[]){
        return deployedCampaigns;
    }
}



