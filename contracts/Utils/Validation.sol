// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/AccountAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/PrecompilesAPI.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Validation is Context {
    mapping(bytes => uint256) private _nonces;

    event ShowMsg(bytes m);

    function validateOwner(
        uint64 minerID,
        bytes memory signature,
        address sender
    ) external {
        CommonTypes.FilAddress memory ownerAddr = getOwner(minerID);
        bytes memory digest = getDigest(
            ownerAddr.data,
            minerID,
            sender
        );
        AccountAPI.authenticateMessage(
            CommonTypes.FilActorId.wrap(PrecompilesAPI.resolveAddress(ownerAddr)),
            AccountTypes.AuthenticateMessageParams({
                signature: signature,
                message: digest
            })
        );
        _nonces[ownerAddr.data] += 1;
    }

    function getSigningMsg(uint64 minerID) external returns (bytes memory m) {
        bytes memory ownerAddr = getOwner(minerID).data;
        m = getDigest(ownerAddr, minerID, _msgSender());
        emit ShowMsg(m);
    }

    function getNonce(bytes memory addr) external view returns (uint256) {
        return _nonces[addr];
    }

    function getDigest(
        bytes memory ownerAddr,
        uint64 minerID,
        address sender
    ) private view returns (bytes memory) {
        bytes32 digest = keccak256(abi.encode(
            keccak256("validateOwner"),
            ownerAddr,
            minerID,
            sender,
            _nonces[ownerAddr],
            getChainId()
        ));
        return bytes.concat(digest);
    }

    function getOwner(uint64 minerID) private returns (CommonTypes.FilAddress memory) {
        return MinerAPI.getOwner(CommonTypes.FilActorId.wrap(minerID)).owner;
    }

    function getChainId() private view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}
