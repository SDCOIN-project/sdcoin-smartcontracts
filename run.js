SDCoin.deployed().then(function(inst) { return inst.approveSig(); })
    .then(function(value) {console.log(value);});

SDCoin.deployed().then(function(inst) { return inst.getNonce("0x1234556"); })
    .then(function(value) {console.log(value);});