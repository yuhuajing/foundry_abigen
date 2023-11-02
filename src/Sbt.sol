// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract SBT is ERC1155 {
    address public owner;

    constructor() payable ERC1155("") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only operator can mint new souls");
        _;
    }

    modifier onlyAllow(uint256 tokenid) {
        require(
            tokenIDInfo[tokenid].allow == 0,
            "This tokenid event has been closed"
        );
        _;
    }

    struct TokenInfo {
        uint256 tokenid;
        uint256 minted;
        uint256 totalamount;
        string name;
        string symbol;
        string url;
        int256 allow;
    }

    mapping(uint256 => TokenInfo) public tokenIDInfo;
    uint256[] tokenIDs;

    /// @notice Set tokenID metadata
    /// @dev Set tokenID metadata
    /// @param tokenid The tokenid
    /// @param totalamount The total number of tokenid, default 0 means no limitation
    /// @param name The full name of this tokenid
    /// @param symbol The abbreviated name of this tokenid
    /// @param url The metaurl url of this tokenid, for example, https://ipfs.io/ipfs/QmW948aN4Tjh4eLkAAo8os1AcM2FJjA46qtaEfFAnyNYzY
    function settokenIDInfo(
        uint256 tokenid,
        uint256 totalamount,
        string memory name,
        string memory symbol,
        string memory url
    ) external onlyOwner {
        if (totalamount != 0) {
            require(
                tokenIDInfo[tokenid].totalamount >= tokenIDInfo[tokenid].minted,
                "Totalamount must more than minted amount"
            );
        }
        TokenInfo memory tokeninfo = TokenInfo({
            tokenid: tokenid,
            minted: tokenIDInfo[tokenid].minted,
            totalamount: totalamount,
            name: name,
            symbol: symbol,
            url: url,
            allow: 0
        });
        tokenIDInfo[tokenid] = tokeninfo;
    }

    /// @notice Get initialized metadata's tokenID info
    /// @dev Get initialized metadata's tokenID info
    function TokenIDs() external view returns (uint256[] memory) {
        return tokenIDs;
    }

    /// @notice Get tokenID metadata,default empty
    /// @dev Get tokenID metadata,default empry
    /// @param _tokenIDs The tokenid array
    function tokenIDsInfo(uint256[] calldata _tokenIDs)
        external
        view
        returns (TokenInfo[] memory)
    {
        TokenInfo[] memory tokenInfo = new TokenInfo[](_tokenIDs.length);
        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            tokenInfo[i] = tokenIDInfo[_tokenIDs[i]];
        }
        return tokenInfo;
    }

    /// @notice The contract owner Mint amount tokenID to receiver
    /// @dev The contract owner Mint amount tokenID to receiver
    /// @param receiver The tokenid receiver
    /// @param tokenid The tokenid to be minted
    /// @param amount The amount of tokenid
    function mint(
        address receiver,
        uint256 tokenid,
        uint256 amount
    ) public onlyOwner onlyAllow(tokenid) {
        if (tokenIDInfo[tokenid].minted == 0) {
            tokenIDs.push(tokenid);
        }
        if (tokenIDInfo[tokenid].totalamount != 0) {
            require(
                tokenIDInfo[tokenid].minted + amount <=
                    tokenIDInfo[tokenid].totalamount,
                "Not Enough TokenID left"
            );
        }
        tokenIDInfo[tokenid].minted += amount;
        _mint(receiver, tokenid, amount, bytes(""));
    }

    /// @notice The contract owner Mint amount tokenID to receiver
    /// @dev The contract owner Mint amount tokenID to receiver
    /// @param receiver The tokenid receiver ayyay
    /// @param tokenid The tokenid ayyay to be minted
    /// @param amount The amount ayyay of tokenid
    function batchmint(
        address[] memory receiver,
        uint256[] memory tokenid,
        uint256[] memory amount
    ) external onlyOwner {
        require(
            receiver.length != 0 && receiver.length == amount.length,
            "Unmatched length"
        );
        if (tokenid.length == 1) {
            for (uint256 i = 0; i < receiver.length; i++) {
                mint(receiver[i], tokenid[0], amount[i]);
            }
        } else {
            require(receiver.length == tokenid.length, "Unmatched length");
            for (uint256 i = 0; i < receiver.length; i++) {
                mint(receiver[i], tokenid[i], amount[i]);
            }
        }
    }

    /// @notice The tokenid owner Burn amount tokenID
    /// @dev The contract owner Burn amount tokenID
    /// @param tokenid The tokenid to be burned
    /// @param amount The amount of tokenid
    function burn(uint256 tokenid, uint256 amount) external virtual {
        _burn(msg.sender, tokenid, amount);
    }

    /// @notice The contract owner update contract owner to this newowner
    /// @dev The contract owner update contract owner to this newowner
    /// @param newowner The contract new owner
    function updateOwner(address newowner) external onlyOwner {
        require(newowner != address(0), "Invalid Owner");
        owner = newowner;
    }

    /// @notice It's banned
    /// @dev It's banned
    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure virtual override {
        revert("Transfer not supported for soul bound token.");
    }

    /// @notice It's banned
    /// @dev It's banned
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override {
        revert("Transfer not supported for soul bound token.");
    }

    /// @notice It's banned
    /// @dev It's banned
    function setApprovalForAll(address, bool) public virtual override {
        revert("Transfer not supported for soul bound token.");
    }

    /// @notice It's banned
    /// @dev It's banned
    function isApprovedForAll(address, address)
        public
        view
        virtual
        override
        returns (bool)
    {
        revert("Transfer not supported for soul bound token.");
    }

    /// @notice The contract owner update totalamount of tokenid
    /// @dev The contract owner update totalamount of tokenid
    /// @param tokenid The tokenid
    /// @param totalamount The new totalamount of thus tokenid
    function updateTotalAmount(uint256 tokenid, uint256 totalamount)
        external
        onlyOwner
    {
        require(
            totalamount >= tokenIDInfo[tokenid].minted,
            "Tokenamount must more than 0"
        );
        tokenIDInfo[tokenid].totalamount = totalamount;
    }

    /// @notice The contract owner update Metadata url of tokenid
    /// @dev The contract owner update Metadata url of tokenid
    /// @param tokenid The tokenid
    function updateURL(uint256 tokenid, string memory url) external onlyOwner {
        tokenIDInfo[tokenid].url = url;
    }

    /// @notice The contract owner close the mint/batchmint funcs of this tokenid
    /// @dev The contract owner close the mint/batchmint funcs of this tokenid
    /// @param tokenid The tokenid
    function closeMint(uint256 tokenid) external onlyOwner {
        tokenIDInfo[tokenid].allow = 1;
    }

    /// @notice The contract owner open the mint/batchmint funcs of this tokenid
    /// @dev The contract owner open the mint/batchmint funcs of this tokenid
    /// @param tokenid The tokenid
    function openMint(uint256 tokenid) external onlyOwner {
        tokenIDInfo[tokenid].allow = 0;
    }

    /// @notice The contract owner update the abbreviated name of this tokenid
    /// @dev The contract owner update the abbreviated name of this tokenid
    /// @param tokenid The tokenid
    /// @param name The full name of this tokenid
    /// @param symbol The abbreviated name of this tokenid
    function updateNameSymbol(
        uint256 tokenid,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        tokenIDInfo[tokenid].name = name;
        tokenIDInfo[tokenid].symbol = symbol;
    }

    /// @notice Get matadata url of this tokenid
    /// @dev Get matadata url of this tokenid
    /// @param tokenid The tokenid
    function uri(uint256 tokenid)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenIDInfo[tokenid].url;
    }

    /// @notice Get the full name of this tokenid
    /// @dev Get the full name of this tokenid
    /// @param tokenid The tokenid
    function getname(uint256 tokenid) external view returns (string memory) {
        return tokenIDInfo[tokenid].name;
    }

    function getsymbol(uint256 tokenid) external view returns (string memory) {
        return tokenIDInfo[tokenid].symbol;
    }

    /// @notice Get totalamount of this tokenid
    /// @dev Get totalamount of this tokenid
    /// @param tokenid The tokenid
    function gettotalamount(uint256 tokenid) external view returns (uint256) {
        return tokenIDInfo[tokenid].totalamount;
    }

    /// @notice Get minted number  of this tokenid
    /// @dev Get minted number  of this tokenid
    /// @param tokenid The tokenid
    function getminted(uint256 tokenid) external view returns (uint256) {
        return tokenIDInfo[tokenid].minted;
    }
}

