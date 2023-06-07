// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILLiquid.sol";
import "./DataFetcher.sol";

contract Deployer {
    FILTrust private _filTrust;
    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;
    FILLiquid private _filLiquid;
    DataFetcher private _dataFetcher;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor() payable {
        _filTrust = new FILTrust("FILTrust", "FIT");
        emit ContractPublishing("FILTrust", address(_filTrust));
        _validation = new Validation();
        emit ContractPublishing("Validation", address(_validation));
        _calculation = new Calculation();
        emit ContractPublishing("Calculation", address(_calculation));
        _filecoinAPI = new FilecoinAPI();
        emit ContractPublishing("FilecoinAPI", address(_filecoinAPI));
        _filLiquid = new FILLiquid(
            address(_filTrust),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            payable(msg.sender)
        );
        emit ContractPublishing("FILLiquid", address(_filLiquid));
        _dataFetcher = new DataFetcher(address(_filLiquid));
        emit ContractPublishing("DataFetcher", address(_dataFetcher));
        _filTrust.addManager(address(_filLiquid));
        _filLiquid.deposit{value: msg.value}(msg.value, _filLiquid.rateBase(), 0);
        uint filTrustBalance = _filLiquid.filTrustBalanceOf(address(this));
        assert(filTrustBalance == msg.value);
        _filTrust.transfer(msg.sender, filTrustBalance);

        _filTrust.setOwner(msg.sender);
        _filLiquid.setOwner(msg.sender);
    }

    function filTrust() external view returns (address) {
        return address(_filTrust);
    }

    function validation() external view returns (address) {
        return address(_validation);
    }

    function calculation() external view returns (address) {
        return address(_calculation);
    }

    function filecoinAPI() external view returns (address) {
        return address(_filecoinAPI);
    }

    function fill() external view returns (address) {
        return address(_filLiquid);
    }

    function dataFetcher() external view returns (address) {
        return address(_dataFetcher);
    }
}