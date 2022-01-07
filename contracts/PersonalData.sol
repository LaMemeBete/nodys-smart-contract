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
    uint256 public requestCounter;
    uint256 public dataTypesCounter;

    enum STATE {
        OPEN,
        CLOSE
    }

    struct DataTypesUsed {
        string dataType;
        STATE state;
    }
    mapping(uint256 => DataTypesUsed) public dataTypesUsed;

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
        dataTypesCounter = 0;
    }

    /*
     * Service meta modififcations
     */

    function updateServiceName(string memory _serviceName) public {
        serviceName = _serviceName;
    }

    function transferServiceOwnership(address _serviceAddress) public {
        serviceAddress = _serviceAddress;
    }

    /*
     * Adding new data types used is using
     */

    function checkDataTypeUsed(string memory _dt) private view returns (bool) {
        for (uint256 i = 0; i < dataTypesCounter; i++) {
            if (
                keccak256(bytes(_dt)) ==
                keccak256(bytes(dataTypesUsed[i].dataType))
            ) {
                return false;
            }
        }
        return true;
    }

    function addDataType(string memory _dt) public {
        require(
            dataTypes.checkDataTypeExistence(_dt),
            "Data Type is not permitted."
        );
        //require(checkDataTypeUsed(_dt), "Data Type is already used.");
        DataTypesUsed memory newDataTypesUsed = DataTypesUsed(_dt, STATE.CLOSE);
        dataTypesUsed[dataTypesCounter] = newDataTypesUsed;
        dataTypesCounter += 1;
    }
}
