// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface DataTypesInterface {
    function setDataTypes(uint256) external;
    function retrieveDataTypes() external view returns (string[] memory);
}
