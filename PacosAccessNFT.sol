// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts@4.8.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.3/security/Pausable.sol";
import "@openzeppelin/contracts@4.8.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.3/utils/math/SafeMath.sol";

contract PacosAccessNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable
{
    using SafeMath for uint256;

    uint256 constant MAX_NFTS = 100;
    uint256 public nftsMinted = 0;
    uint256 public feeAmount = 0.1 ether;
    string public baseURI = "ipfs://QmZea6tSnW3KxZKjCzoxHzpmQV9bW5GniZvbCPkpioTV2r/";

    constructor() ERC721("PacosAccessNFT", "PAN") {
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to) public payable {
        require(nftsMinted < MAX_NFTS, "Maximum number of NFTs minted");
        require(msg.value >= feeAmount, "Insufficient payment for minting");

        nftsMinted = nftsMinted.add(1);
        _safeMint(to, nftsMinted);
        _setTokenURI(nftsMinted, baseURI);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = owner().call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override (ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory jsonFile = "PacosAccessNFT.json";

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, jsonFile))
                : "";
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
