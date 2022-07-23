// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";

contract Asset is ERC721A{
    using Strings for uint256;

    modifier tokenExist(uint256 tokenId) {
        require(_exists(tokenId), "Nonexistent token");
        _;
    }
    constructor () ERC721A("Asset", "AST"){}

    function mint() public {
        _mint(msg.sender, 1);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExist(tokenId)
        returns (string memory)
    {
        return tokenId.toString();
    }
}