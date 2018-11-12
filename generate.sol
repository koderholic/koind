pragma solidity ^0.4.5;

contract Koind {

    //Define State Variables
    address Owner;
    uint256 tokenTotal;
    string tokenName;
    string  tokenSymbol;
    mapping(address => uint256 ) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) allowedAddresses;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed from, address indexed to, uint256 value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    event Addition(address indexed allowedAddress);

    modifier onlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    constructor (uint256 __initialSupply, string __name, string __symbol) public {
        
        // Initialize Owner
        Owner = msg.sender;

        // Initialize token variables
        tokenTotal = __initialSupply;
        tokenName = __name;
        tokenSymbol = __symbol;
        balanceOf[msg.sender] = tokenTotal;  
        allowedAddresses[msg.sender] = true;  
    }

    function _transfer(address __from, address __to, uint256 __amount) internal {

        // validations

        require(allowedAddresses[__from] == true,"Sorry, senders address is not listed in the allowed addresses for this contract");
        require(allowedAddresses[__to] == true, "Sorry, receipient address is not listed in the allowed addresses for this contract");

        require(balanceOf[__from] >= __amount, "Sorry, senders do not have sufficient balance for this transaction");

        // Save this for an assertion in the future
        uint previousBalances = balanceOf[__from] + balanceOf[__to];

        balanceOf[__from] -=__amount;
        balanceOf[__to] +=__amount;

        // Ensures that our transactions are carried out properly, to avoid bugs
        assert(balanceOf[__from] + balanceOf[__to] == previousBalances);

        emit Transfer(__from, __to, __amount);

    }

    function _addAllowedAddress(address __addAddress) internal onlyOwner returns (bool) {
        allowedAddresses[__addAddress] = true;
        emit Addition(__addAddress);
        return true;
    }

    function totalSupply() public view returns (uint256){
        return tokenTotal;
    }

    function balanceOf(address __owner) public view returns(uint256) {
        return balanceOf[__owner];
    }

    function allowance(address _giver, address _spender)  public view returns (uint256) { 
        return allowance[_giver][_spender];
    }


    function transfer(address __to, uint256 __amount) public returns (bool) {

        _transfer(msg.sender, __to, __amount);
        return true;

    }

    function transferFrom(address __from,address __to, uint256 __amount) public returns (bool) {
        require(__amount <= allowance[__from][msg.sender], "Sorry, senders do not have sufficient balance for this transaction");     // Check allowance
        allowance[__from][msg.sender] -= __amount;
        _transfer(__from, __to, __amount);
        return true;

    }

    function approve(address __spender, uint __amount) public returns (bool) {     // Check allowance
        allowance[msg.sender][__spender] = __amount;
        emit Approve(msg.sender, __spender, __amount);
        return true;

    }

    function burn(uint256 __value) public returns (bool success) {
        require(balanceOf[msg.sender] >= __value, "Sorry, senders do not have sufficient balance for this transaction");   // Check if the sender has enough
        balanceOf[msg.sender] -= __value;            // Subtract from the sender
        tokenTotal -= __value;                      // Updates totalSupply
        emit Burn(msg.sender, __value);
        return true;
    }

    function burnFrom(address _from, uint256 __value) public returns (bool success) {
        require(balanceOf[_from] >= __value, "Sorry, senders do not have sufficient balance for this transaction");                // Check if the targeted balance is enough
        require(__value <= allowance[_from][msg.sender], "Sorry, senders do not have sufficient balance for this transaction");    // Check allowance
        balanceOf[_from] -= __value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= __value;             // Subtract from the sender's allowance
        tokenTotal -= __value;                              // Update totalSupply
        emit Burn(_from, __value);
        return true;
    }
}