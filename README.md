# The Degen Casino

The Degen Casino is a collection of decentralized and permissionless casino games built to run on any
EVM-compatible blockchain.


## Games

### Degen's Gambit

*Degen's Gambit* is the first game in the Degen Casino. It is a permissionless slot machine inspired by [Degen Trail: Jackpot Junction](https://github.com/moonstream-to/degen-trail).

*Degen's Gambit* is a 3-reel slot machine with daily and weekly streak mechanics which encourage users to come back to the game at those frequencies.

It is a permissionless, autonomous, fully on-chain game.

More details are available in:
- [The *Degen's Gambit* integration guide](docs/DegenGambitIntegrationGuide.md).


## Account system

The Degen Casino features fully on-chain casino games. This means that every game interaction requires a Degen Casino player to submit an on-chain transaction.
This means that, if the player were playing directly through a wallet like MetaMask, they would have to confirm every move through a transaction confirmation dialogue.
These transaction confirmations disrupt the flow of the game and break player absorption. The Degen Casino account system is a decentralized means through which players
can play games in the Degen Casino without having to confirm a transaction on every move.

More details are available in [The Degen Casino account system](docs/AccountSystem.md).