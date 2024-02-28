// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

/// @title IBlastPoints
/// @notice Interface for the Blast Points contract
interface IBlastPoints {
    /// @notice Configures the points operator for the caller's address.
    /// @dev Sets the points operator for the contract making the call.
    /// @param operator The address to set as the points operator.
    function configurePointsOperator(address operator) external;

    /// @notice Configures a new points operator on behalf of a contract address.
    /// @dev Sets the new points operator for a specified contract address.
    /// Only callable by the current points operator.
    /// @param contractAddress The contract address for which to set the new points operator.
    /// @param newOperator The address to set as the new points operator.
    function configurePointsOperatorOnBehalf(
        address contractAddress,
        address newOperator
    ) external;

    /// @notice Reads the points operator for a given contract address.
    /// @param contractAddress The address of the contract to query.
    /// @return operator The address of the points operator for the given contract.
    function operatorMap(
        address contractAddress
    ) external view returns (address operator);

    /// @notice Reads the status of a given contract address.
    /// @dev Returns the operator address, ban status, and contract code length for the specified contract.
    /// @param contractAddress The address of the contract to query.
    /// @return operator The address of the operator for the given contract.
    /// @return isBanned Indicates whether the contract is banned.
    /// @return codeLength The length of the contract's code.
    function readStatus(
        address contractAddress
    )
        external
        view
        returns (address operator, bool isBanned, uint256 codeLength);
}
