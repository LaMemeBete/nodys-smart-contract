// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "../interfaces/DataTypesInterface.sol";
import "@openzeppelin-contract/contracts/access/Ownable.sol";

contract PersonalData is Ownable {
    address public userAddress;
    address public serviceAddress;
    address public dataTypesAddress;
    DataTypesInterface public dataTypes;
    string public serviceName;

    constructor(
        address _serviceAddress,
        address _userAddress,
        address _dataTypesAddress,
        string memory _serviceName
    ) {
        serviceAddress = _serviceAddress;
        userAddress = _userAddress;
        dataTypesAddress = _dataTypesAddress;
        dataTypes = DataTypesInterface(dataTypesAddress);
        serviceName = _serviceName;
    }

    function updateServiceName(string memory _serviceName) public {
        serviceName = _serviceName;
    }

    function transferServiceOwnership(address _serviceAddress) public {
        serviceAddress = _serviceAddress;
    }

    function retrieveDataTypes() public view returns (string[] memory) {
        return dataTypes.retrieveDataTypes();
    }
}
