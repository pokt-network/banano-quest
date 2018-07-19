# BANANO Quest

BANANO Quest is a proof of concept game meant to show mobile developers the possiblities of developing blockchain applications using the blockchain and Pocket iOS SDK. A mix between geocaching and Pokemon Go, players use quest hints to walk to specific coordinates in real life, and attempt to complete the quest by sending in their coordinates to the Tavern smart contract deployed on Ethereum. If the coordinates are correct, the contract will reward the player with a unique ERC721 BANANO Token. 

The important piece to understand is that these BANANO Tokens can be used and transferred outside the game itself, and are not controlled in any way by the creators. The Pocket Network team decided to open source the app as an example developers wishing to dive into mobile blockchain development. We hope this serves as inspiration for taking advantage of the different game mechanics and revenue opportunities outside of the App Store.

# Gameplay

There are 2 roles within the game. Players can create or complete quests. To complete a quest, a player must walk to the coordinates they believe are the right answer and submit the coordinates through the app. 

Both need Ethereum's cryptocurrency, Ether to successfully play the game. We recognize this is a significant user experience hurdle in playing the game and have  implemented several ways in which a new user can get Ether into their account. We also purposely abstract all cryptocurrency concepts until absolutely necessary for users to make the gameplay as smooth as possible. 

## Quest Creators

In the context of BANANO Quest, to create a quest you need to send the the following to the Tavern smart contract:

* Quest coordinates
* Quest name
* Quest hint
* How many BANANOs you want the quest to give out
* How much of an ETH prize to give out
* The quadrant of space you want the quest to be in
* The color of your quest

Ethereum is a public, open source blockchain and it would be trivial for any person to query what the given coordinates answer to a quest are. We created a utility in the app where the client hashes all the possible coordinates into a merkle root and additional levels of the tree into the smart contract. This allows the contract to be able to verify whether the coordinates are a valid solution or not. While we are using coordinates for BANANO Quest, developers can use words, virtual world coordinates or any other set of answers that can be hashed into a merkle tree and put into a smart contract. 

## Questers

Questers are users of the application who wish to compete to complete  quests and earn BANANO tokens. Questers must have a nominal amount of Ether in their account to complete them. A quester chooses a quest they want to complete, read the hint associated with it, and msut travel to a physical area in the world to where they believe the quest can be completed. If correct when they submit the quest, an augmented reality banano shows up that they can take a screenshot and share with their friends.  

# Tech Stack

The Pocket team built a custom set of extensible tools to make it easier for developers who wish to build peer to peer applications. Pocket is blockchain agnostic, and everything is built with the goal of easily adding a plugin for any other blockchain into the ecosystem. By doing so, Pocket can be a simple, common interface for developers who want to use a specific cryptocurrency or multiple ones in their applications.  

## Ethereum

We chose Ethereum as the decentralized "backend" for BANANO Quest due to our familiarity and maturity of the tools and network. While confirmation times and lack of avoiding users having to use Ether is a significant UX problem, this is still an example application that hopes to inspire others into building more user friendly applications.   

## Tavern smart contract

Named after the classic location where gamers go and collect quests, Tavern is a smart contract that allows any Solidity developer to easily extend and make their own custom quest for their custom application. For more detailed information visit the repo for [Tavern](https://github.com/pokt-network/tavern). 

The contract rewards players with a [BananoToken](https://github.com/pokt-network/banano-token) which is a Non-Fungible Token (explained below). While we added the BananoToken to the contract, any Ethereum token or ETH can be added as a prize for quests.  
 

## BananoToken and Non-Fungible Tokens (NFT's)

NFT's are based off of an [Ethereum Improvement Proposal](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) standard popularized by [CryptoKitties](https://www.cryptokitties.co/). Otherwise known as ERC721, NFT's enable unique properties that normal EIP20 tokens do not offer, namely unique metadata that gives tokens within the same family vastly different values based on scarcity. Each BANANO token is an NFT, and depending on how difficult and rare the quest is, can potentially have vastly different value than a common BANANO Token. 

NFT's introduce new game mechanics, such as burning or breeding the tokens for another type of NFT. For example, there are [dragons](https://hyperdragons.alfakingdom.com/) that you can feed your cryptokitties to for upgrades. One can imagine a game where someone creates an epic quest where you must collect a CrytoKitty, a BANANO and some other NFT to create a super NFT. The sky is the limit for this space and there is a significant amount of research being done.  

## Pocket iOS SDK

The Pocket iOS SDK contains all the tools needed to send transactions and read data from any blockchain, and is an interface that plugins must conform to in order to provide specific blockchain functionality. For more information please see [our repository](https://github.com/pokt-network/pocket-ios-sdk). 

## Pocket Ethereum iOS plugin

PocketEth is a Ethereum specific plugin that works with the Pocket iOS SDK. It provides all the necessary functionality to create Ethereum transactions and queries based on the Ethereum JSON-RPC Interface. For more information please see [our repository](https://github.com/pokt-network/pocket-ios-eth).
