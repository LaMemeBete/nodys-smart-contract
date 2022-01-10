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
    uint256 public userRequestsCounter;
    uint256 public serviceRequestsCounter;
    string[] public dataTypesUsedList;

    enum STATE {
        OPEN,
        CLOSE
    }
    enum DATA_STATE {
        DELETED,
        INTACT
    }
    enum REQUEST_STATE {
        PENDING,
        SUCCESS,
        FAILURE
    }
    enum REQUEST_TYPE {
        DELETE,
        SHARE,
        CLOSE,
        OPEN
    }

    struct DataTypesUsed {
        string dataType;
        STATE state;
        DATA_STATE dataState;
        bool isValue;
    }

    struct Request {
        string dataType;
        REQUEST_STATE state;
        REQUEST_TYPE requestType;
        STATE stateRequestCreation;
        DATA_STATE dataStateRequestCreation;
    }

    mapping(string => DataTypesUsed) public dataTypesUsed;
    mapping(uint256 => Request) public userRequests;
    mapping(uint256 => Request) public serviceRequests;

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
        userRequestsCounter = 0;
        serviceRequestsCounter = 0;
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
    function addDataType(
        string memory _dt,
        STATE state,
        DATA_STATE dataState
    ) public {
        require(
            dataTypes.checkDataTypeExistence(_dt),
            "Data Type is not permitted."
        );
        require(!dataTypesUsed[_dt].isValue, "Data Type already in use.");
        DataTypesUsed memory newDataTypesUsed = DataTypesUsed(
            _dt,
            state,
            dataState,
            true
        );
        dataTypesUsed[_dt] = newDataTypesUsed;
        dataTypesUsedList.push(_dt);
    }

    /*
     * User making request from service
     */
    function checkUserRequestValidity(
        string memory _dt,
        REQUEST_TYPE requestType
    ) private view returns (bool) {
        if (
            dataTypesUsed[_dt].state == STATE.OPEN &&
            dataTypesUsed[_dt].dataState == DATA_STATE.DELETED
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.CLOSE &&
            dataTypesUsed[_dt].dataState == DATA_STATE.DELETED
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.OPEN &&
            dataTypesUsed[_dt].dataState == DATA_STATE.INTACT &&
            (requestType != REQUEST_TYPE.SHARE &&
                requestType != REQUEST_TYPE.CLOSE)
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.CLOSE &&
            dataTypesUsed[_dt].dataState == DATA_STATE.INTACT &&
            (requestType != REQUEST_TYPE.SHARE &&
                requestType != REQUEST_TYPE.DELETE)
        ) {
            return false;
        }
        return true;
    }

    function createRequestFromUser(string memory _dt, REQUEST_TYPE requestType)
        public
    {
        require(
            dataTypes.checkDataTypeExistence(_dt),
            "Data Type is not permitted."
        );
        require(dataTypesUsed[_dt].isValue, "Data Type not in use.");
        require(checkUserRequestValidity(_dt, requestType), "Invalid request.");
        Request memory newRequest = Request(
            _dt,
            REQUEST_STATE.PENDING,
            requestType,
            dataTypesUsed[_dt].state,
            dataTypesUsed[_dt].dataState
        );
        userRequests[userRequestsCounter] = newRequest;
        userRequestsCounter += 1;
    }

    /*
     * Service making request from user
     */
    function checkServiceRequestValidity(
        string memory _dt,
        REQUEST_TYPE requestType
    ) private view returns (bool) {
        if (
            dataTypesUsed[_dt].state == STATE.OPEN &&
            dataTypesUsed[_dt].dataState == DATA_STATE.INTACT
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.OPEN &&
            dataTypesUsed[_dt].dataState == DATA_STATE.DELETED
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.CLOSE &&
            dataTypesUsed[_dt].dataState == DATA_STATE.INTACT &&
            requestType != REQUEST_TYPE.OPEN
        ) {
            return false;
        }
        if (
            dataTypesUsed[_dt].state == STATE.CLOSE &&
            dataTypesUsed[_dt].dataState == DATA_STATE.DELETED &&
            requestType != REQUEST_TYPE.OPEN
        ) {
            return false;
        }
        return true;
    }

    function createRequestFromService(
        string memory _dt,
        REQUEST_TYPE requestType
    ) public {
        require(!dataTypes.checkDataTypeExistence(_dt) && requestType != REQUEST_TYPE.OPEN, "Invalid request.");
        require(checkServiceRequestValidity(_dt, requestType), "Invalid request.");
        Request memory newRequest = Request(
            _dt,
            REQUEST_STATE.PENDING,
            requestType,
            dataTypesUsed[_dt].state,
            dataTypesUsed[_dt].dataState
        );
        serviceRequests[serviceRequestsCounter] = newRequest;
        serviceRequestsCounter += 1;
        
    }
}
