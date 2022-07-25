// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";
import "./Base64.sol";

contract Agreement is ERC721A {
    using Strings for uint160;
    using Strings for uint256;

    struct AssetArg {
        address a; // contract address
        uint256 i; // tokenID of ERC721
    }

    struct Asset {
        address a; // contract address
        uint256 i; // tokenID of ERC721
        address o; // owner of assets
    }

    struct AgreementNFT {
        string name;
        string terms;
        address[] partyList;
        address[] assetsList;
        address[] party;
        bytes32[] assets;
        uint256 signDate;
        uint256 dueDate;
    }

    AgreementNFT[] public nft;
    mapping(bytes32 => Asset) assetPool;

    modifier tokenExist(uint256 tokenId) {
        require(_exists(tokenId), "Nonexistent token");
        _;
    }

    constructor() ERC721A("Agreement", "AGREE") {}

    function create(
        string calldata _name,
        string calldata _terms,
        uint256 _due,
        address[] calldata partyList,
        address[] calldata assetsList
    ) external {
        nft.push(
            AgreementNFT(
                _name,
                _terms,
                partyList,
                assetsList,
                new address[](0),
                new bytes32[](0),
                block.timestamp,
                _due
            )
        );
        nft[nft.length - 1].party.push(msg.sender);

        _mint(msg.sender, 1);
    }

    function create(
        string calldata _name,
        string calldata _terms,
        uint256 _due,
        address[] calldata partyList,
        address[] calldata assetsList,
        AssetArg[] calldata _assets
    ) external {
        nft.push(
            AgreementNFT(
                _name,
                _terms,
                partyList,
                assetsList,
                new address[](0),
                new bytes32[](0),
                block.timestamp,
                _due
            )
        );
        nft[nft.length - 1].party.push(msg.sender);
        _addAssets(msg.sender, nft.length - 1, _assets);

        _mint(msg.sender, 1);
    }

    function sign(uint256 tokenId) public tokenExist(tokenId) {
        _addParty(msg.sender, tokenId);
    }

    function sign(uint256 tokenId, AssetArg[] calldata _assets)
        public
        tokenExist(tokenId)
    {
        _addAssets(msg.sender, tokenId, _assets);
        _addParty(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExist(tokenId)
        returns (string memory)
    {
        bytes memory _content = bytes(terms(tokenId));
        uint256 _height = (_content.length * 37) / 30;

        if (_height < 500) {
            _height = 500;
        }

        bytes memory _svg = abi.encodePacked(
            '<svg baseProfile="tiny" width="500" height="',
            _height.toString(),
            '" viewBox="0 0 500 ',
            _height.toString(),
            '" fill="none" xmlns="http://www.w3.org/2000/svg"><foreignObject x="10" y="10" width="480" height="',
            _height.toString(),
            '"><p align="left" style= "white-space:pre-wrap; line-height: 35px; font-family:Courier;">',
            _content,
            "</p></foreignObject></svg>"
        );

        bytes memory meta = abi.encodePacked(
            '{"name": "',
            nft[tokenId].name,
            '", "description": "A Smart Agreement NFT", ',
            '"image_data": "',
            "data:image/svg+xml;base64,",
            Base64.encode(abi.encodePacked(_svg)),
            '", "designer": "LUCA355.xyz"}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(meta)
                )
            );
    }

    function terms(uint256 tokenId)
        public
        view
        tokenExist(tokenId)
        returns (string memory)
    {
        uint256 i;
        string memory status = "Pending";

        if (nft[tokenId].party.length == nft[tokenId].partyList.length + 1) {
            status = "Valid";
        }

        if (nft[tokenId].signDate >= nft[tokenId].dueDate) {
            status = "Expired";
        }

        bytes memory _buffer = abi.encodePacked(
            "-----",
            nft[tokenId].name,
            "-----\n",
            nft[tokenId].terms,
            "\n[CONTRACT STATUS]: ",
            status,
            "\nSinged-Due Date: ",
            nft[tokenId].signDate.toString(),
            "-",
            nft[tokenId].dueDate.toString(),
            "\nSigned By:\n"
        );

        uint256 _partyNum = nft[tokenId].party.length;
        for (i = 0; i < _partyNum; i++) {
            _buffer = abi.encodePacked(
                _buffer,
                uint160(nft[tokenId].party[i]).toHexString(),
                "\n"
            );
        }

        bytes32[] memory _keys = nft[tokenId].assets;
        if (_keys.length == 0) {
            return string(_buffer);
        }

        _buffer = abi.encodePacked(_buffer, "Assets Included:\n");

        for (i = 0; i < _keys.length; i++) {
            Asset memory _asset = assetPool[_keys[i]];
            string memory expired = _verifyAsset(_asset, tokenId)
                ? "Verified: "
                : "Expired: ";
            _buffer = abi.encodePacked(
                _buffer,
                "[",
                expired,
                uint160(_asset.a).toHexString(),
                " #",
                _asset.i.toString(),
                "\nOwner: ",
                uint160(_asset.o).toHexString(),
                "]\n"
            );
        }

        return string(_buffer);
    }

    function _hash(Asset memory _asset) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_asset.a, _asset.i, _asset.o));
    }

    function _addAssets(
        address _who,
        uint256 tokenId,
        AssetArg[] calldata _assets
    ) internal {
        for (uint256 i = 0; i < _assets.length; i++) {
            Asset memory _asset = Asset(_assets[i].a, _assets[i].i, _who);
            if (_verifyAsset(_asset, tokenId) == false) {
                revert("Asset not in list or not owner");
            }
            bytes32 key = _hash(_asset);
            if (assetPool[key].i == 0) {
                assetPool[key] = _asset;
            }
            nft[tokenId].assets.push(key);
        }
    }

    function _verifyAsset(Asset memory _asset, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        uint256 assetsListSize = nft[tokenId].assetsList.length;
        uint256 i;

        for (i = 0; i < assetsListSize; i++) {
            if (nft[tokenId].assetsList[i] == _asset.a) {
                break;
            }
        }
        if (i == assetsListSize) {
            return false;
        }
        IERC721 token = IERC721(_asset.a);
        return token.ownerOf(_asset.i) == _asset.o;
    }

    function _addParty(address _who, uint256 tokenId) internal {
        uint256 _partyNum = nft[tokenId].partyList.length;
        uint256 i;

        for (i = 0; i < _partyNum; i++) {
            if (nft[tokenId].partyList[i] == _who) {
                break;
            }
        }
        if (i == _partyNum) {
            revert("party not in list");
        }

        _partyNum = nft[tokenId].party.length;

        for (i = 0; i < _partyNum; i++) {
            if (nft[tokenId].party[i] == _who) {
                return;
            }
        }

        nft[tokenId].party.push(_who);
        nft[tokenId].signDate = block.timestamp;
    }
}
