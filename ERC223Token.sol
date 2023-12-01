pragma solidity ^0.8.0;

abstract contract IERC223Recipient {
    function tokenReceived(address _from, uint _value, bytes memory _data) public virtual returns (bytes4) { return 0x8943ec02; }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract ERC223Token {

    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    string  private _name     = "My ERC-223 Token";
    string  private _symbol   = "MTKN";
    uint8   private _decimals = 18;
    uint256 private _totalSupply;
    
    mapping(address => uint256) private balances;

    constructor()
    {
        balances[msg.sender] = 100 * 10 ** _decimals;
        _totalSupply         = 100 * 10 ** _decimals;
        emit Transfer(address(0), msg.sender, 100 * 10 ** _decimals, hex"000000");
    }

    function name()                    public view returns (string memory) { return _name; }
    function symbol()                  public view returns (string memory) { return _symbol; }
    function decimals()                public view returns (uint8)         { return _decimals; }
    function standard()                public view returns (string memory) { return "223"; }
    function totalSupply()             public view returns (uint256)       { return _totalSupply; }
    function balanceOf(address _owner) public view returns (uint256)       { return balances[_owner]; }

    function transfer(address _to, uint _value, bytes calldata _data) public returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function transfer(address _to, uint _value) public returns (bool success)
    {
        bytes memory _empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _empty);
        }
        emit Transfer(msg.sender, _to, _value, _empty);
        return true;
    }
}
