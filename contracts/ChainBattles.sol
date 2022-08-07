// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //starting number for random function
    uint initialNumber;
    uint upperLimit = 3;


    struct Character { 
        uint256 Level;
        uint256 Speed;
        uint256 Strength;
        uint256 Life;
        }

    mapping(uint256 => Character) public tokenIdToLevels;

    


    constructor () ERC721("Chain Battles", "CBTLS") {

    }

    /** 
    * @dev generates an svg object for the character
    */
    function generateCharacter(uint256 tokenId) public view returns (string memory) {

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevel(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Lives: ",getLife(tokenId),'</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
            )   
        );
    }

     
    /** 
    * @dev helper functions to get properties of the character
    */
    function getLevel(uint256 tokenId) public view returns (string memory) {
        
        uint256 levels = tokenIdToLevels[tokenId].Level;

        return levels.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        
        uint256 speed = tokenIdToLevels[tokenId].Speed;

        return speed.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        
        uint256 strength = tokenIdToLevels[tokenId].Strength;

        return strength.toString();
    }

    function getLife(uint256 tokenId) public view returns (string memory) {
        
        uint256 life = tokenIdToLevels[tokenId].Life;

        return life.toString();
    }
    
    /** 
    * @dev creates json object to represent the character
    */
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );


        
    }

    /** 
    * @dev mints a new character
    */
    function mint() public {

        //start at 1
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        Character memory Warrior = Character({Level: 0, Speed: random(upperLimit), Strength: random(upperLimit), Life: random(upperLimit)});
        tokenIdToLevels[newItemId] = Warrior;

        _setTokenURI(newItemId, getTokenURI(newItemId));

    }

    /** 
    * @dev trains the charactaer by increasing its characteristics
    * only the owner can train a character
    */
    function train(uint256 tokenId) public {

        require(_exists(tokenId), "Please use an existing Token");
        require(ownerOf(tokenId) == msg.sender, "You must own this Token to train it.");

        // increment level by 1
        uint256 currentLevel = tokenIdToLevels[tokenId].Level;
        tokenIdToLevels[tokenId].Level = currentLevel + 1;

        //increment other stats randomly by 1-3
        uint256 currentSpeed= tokenIdToLevels[tokenId].Speed;
        tokenIdToLevels[tokenId].Speed = currentSpeed + random(upperLimit);

        uint256 currentStrength= tokenIdToLevels[tokenId].Strength;
        tokenIdToLevels[tokenId].Strength = currentStrength + random(upperLimit);

        uint256 currentLife= tokenIdToLevels[tokenId].Life;
        tokenIdToLevels[tokenId].Life = currentLife + random(upperLimit);


        _setTokenURI(tokenId, getTokenURI(tokenId));

    }

    /** 
    * @dev retrieve all the mints stored on the blockchain
    */
    function getMints() public view returns(Character[] memory) {
        uint tokenId = _tokenIds.current();

        Character[] memory characters = new Character[](tokenId);
            for (uint i = 0; i < tokenId ; i++) {
                characters[i] = tokenIdToLevels[i+1];
            }
            return characters;
    }


    /** 
    * @dev creates a different number each time it is called
    * @param number is the upper bound of the rrandom numbwr
    */
    //source: https://blog.finxter.com/how-to-generate-random-numbers-in-solidity/
    function random(uint number) public returns(uint){
        return uint(keccak256(abi.encodePacked(initialNumber++))) % number;
    }


}