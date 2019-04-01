pragma solidity ^0.4.25;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes  _extraData) external; 
}

contract GakexMain {
    
    // check is admin
    modifier onlyAdmin(){
        require(msg.sender == owner, "admin required");
        _;
    }
    
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    uint256 public totalBalance;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint32 public decimals;
    // NETWORK ADDRESS
    address private owner;
    
    constructor ()
    public
    {
        owner = msg.sender;
        symbol = "GEX";
        name = "GAKEX";
        decimals = 6;
        totalSupply = 12000000 * 10**6; // 12,000,000 GEX
        totalBalance = 0;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);
        require(_value <= balanceOf[msg.sender], "not enough balance");                 // Check avaiable balance
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        require(_value <= balanceOf[_from]);                 // Check avaiableBalance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
    function freezeAccount(address target, bool freeze) public onlyAdmin {
        frozenAccount[target] = freeze;
    }
}
