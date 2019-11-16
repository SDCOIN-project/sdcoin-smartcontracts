pragma solidity >=0.4.22 <0.6.0;

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;

  constructor(address _target) public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() external {
    data = msg.data;
  }

  function execute() public returns (bool) {
    (bool first,) = target.call(data);
    return first;
  }
}

