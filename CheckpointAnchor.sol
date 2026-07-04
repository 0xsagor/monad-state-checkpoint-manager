// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CheckpointAnchor
 * @dev On-chain contract allowing validation infrastructure providers to broadcast verified historical state roots.
 */
contract CheckpointAnchor is Ownable {

    struct SnapshotRecord {
        bytes32 stateMerkleRoot;
        uint256 blockHeight;
        uint256 recordedTime;
    }

    mapping(uint256 => SnapshotRecord) public snapshotRegistry;
    uint256 public latestSnapshotBlockHeight;

    event SnapshotAnchored(uint256 indexed blockHeight, bytes32 stateMerkleRoot);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Registers a verified historical state root anchor on-chain.
     */
    function anchorSnapshotCheckpoint(uint256 blockHeight, bytes32 stateRoot) external onlyOwner {
        require(snapshotRegistry[blockHeight].blockHeight == 0, "CheckpointError: Boundary parameter already anchored");
        
        snapshotRegistry[blockHeight] = SnapshotRecord({
            stateMerkleRoot: stateRoot,
            blockHeight: blockHeight,
            recordedTime: block.timestamp
        });

        if (blockHeight > latestSnapshotBlockHeight) {
            latestSnapshotBlockHeight = blockHeight;
        }

        emit SnapshotAnchored(blockHeight, stateRoot);
    }
}
