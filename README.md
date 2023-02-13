<p align="center">
<img width="300" alt="logo" src="https://user-images.githubusercontent.com/5517281/217730515-aaaa01f4-082b-4ebd-bf69-0156946d6d28.png">
</p>

# SafeSnap
An open-sourced Web3 iOS Application which combines Gnosis Safe and Snapshot together makes you easily manage your DAOs on your pocket.

# Snapshot
<img width="300" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602637-0d8c8c28-df41-4219-89a8-b695ae3392e4.JPG><img width="300" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602597-10922aad-da6c-4618-80a6-4f483de53469.JPG>

<img width="700" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602656-80656cb4-ba8f-4e8f-a785-659e0977f8a4.JPG>

<img width="700" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602667-e56e1d67-e10d-4041-a409-6af9d77232b7.JPG>

## <img width="28" alt="logo" src=https://upload.wikimedia.org/wikipedia/fr/archive/b/bc/20210310082855%21TestFlight-icon.png> Testflight

https://testflight.apple.com/join/yYciI6d2


## <img width="20" alt="logo" src=https://user-images.githubusercontent.com/23297747/40148910-112c56d4-5936-11e8-95df-aa9796b33bf3.png> GitCoin

[GitCoin - SafeSnap](https://grantshub.gitcoin.co/#/chains/1/registry/0x03506eD3f57892C85DB20C36846e9c808aFe9ef4/projects/273)

<img width="358" alt="截屏2023-02-09 13 50 02" src="https://user-images.githubusercontent.com/5517281/217729551-ad4c92d5-6c44-4f1f-a007-a8b1019808f9.png">

## How to use 使用指南

https://mirror.xyz/kittenyang.eth/nvp9pm9KsHM-wnEbtIvetmng03ixUf5vFTguKrFMZDs

## Preface
[中文介绍](/README-CN.md)

In the past few years of the Web3 wave, a large number of so-called Web3 on-chain applications have emerged, covering various tracks. I am personally very optimistic about the DAO track. Not only does it make great use of the features of blockchain, but more importantly, it will reconfigure the paradigm of human social collaboration. If blockchain is a technological revolution, then DAO is more like a social revolution, although it is just the beginning of the story, and it will take a long time to really achieve this goal.

I also experienced the power of the DAO model in the real world during the Covid-19 blockade in Shanghai in the first half of 2022. At that time, the community was completely locked down, and the online supplies were almost sold out, so people had to rely on the community building managers who had channels to purchase supplies. Everyone spontaneously divided the work in the community group, procurement of procurement, handling of handling, online Q&A ..... The first feeling I had was that this was like a popular Web3 project, and the way Web3 projects work is that the more you contribute to the community in the early days, the more project pitches you can get, including but not limited to Token or NFT, so you can cash in on the market when the project is on fire. Essentially it is the same thing as starting a business and getting original shares. Some say it's speculative and a waste of time, but how is it not in the real world? Get a good relationship with your superiors, work hard to make money, and work hard to recharge and learn, not all for various benefits, as long as you don't go to the pits. So the underlying logic is fine: the earlier someone contributes to the community, the more lucrative the reward should be, it's just that blockchain has made the process lower barrier, programmatic, and provable on-chain. There are also benefits for the project, as having a group of wholehearted fans to build together early on also provides more possibilities for subsequent development.

Back to the example of the community DAO, the people answering questions in the group are like MODs in Discord, the procurement is like the project's operation negotiating business cooperation with the outside world, and the people carrying the project are like developers writing code with their heads down. It is conceivable that if we really follow the path of the existing Web3 project and issue community governance tokens, any action that is beneficial to the community will be incentivized, for example, the above-mentioned procurement, transportation, question and answer roles will get a lot of airdrops, which in turn will promote more people to join in the community's common construction. By the time the community becomes more harmonious, residents' happiness index, housing prices will naturally rise, and then will attract more high-quality education and medical resources to gather, which will eventually continue to drive housing prices. If external residents can not directly experience the living environment of the community, but through the purchase of your community currency can also share a share of the pie. See, the Web3 project's playbook seems to work in the real world as well. And during that time, the residents of the Changning district were able to allocate better supplies, people were voting with their feet, and the sentiment of public opinion clearly showed that the intention to buy a home in the Changning district in the future was significantly higher than in other districts. The real world does confirm this. So if and when the infrastructure and policies for DAO are ready, it will be a major reshuffle of all forms of social organization.

The above case for DAO is too ambitious, in fact, our family is a small DAO, for example, you and your loved ones and children are members of the family DAO, issuing an initial supply of 10,000 family coins, then who has contributed to the family can get a certain monetary incentive, including but not limited to doing housework, generating income for the family, the child did an excellent thing This includes, but is not limited to, doing chores, generating income for the family, children doing a good thing, etc., etc. On the surface, everyone is trying to contribute to the family in order to get the incentive, but in fact, the family becomes better. At the same time, you can add the idea of multi-signature wallet, each incentive requires a specified number of members of the family to agree at the same time to pass, and subsequently these incentives can be used as governance tokens for family voting, such as where to choose to travel this year, ah, what delicious food to eat on the weekend, whether the children study abroad or domestic research ...... The more money you hold, the more weight your vote will have. After all, it means you have contributed more to your family in the past, and the proposal with the most votes will be passed. Everything is transparent, traceable, and non-tamperable.

When I discussed the idea with my family members, we all thought it was a good idea to try it out, and if it fails, it fails, life is trial and error. So I started to research the existing solutions on the market. Here we have to mention the benefits of smart contracts, you can think of ideas that someone somewhere in the world may have already thought of, and the code is open and transparent on the chain, that is to say, you do not have to repeat themselves to build the wheel, more importantly, do not have to worry about the Web2 world in a variety of environmental dependencies, incompatibilities and other issues, directly a few lines of code to call the smart contract on the line. The above idea requires two key applications, namely multi-signature wallet and on-chain voting.

## Multi-signature wallet
A multi-signature wallet, as the name implies, requires multiple signatures. A basic BIP wallet has a unique pair of public and private keys corresponding to each other, once your private key is leaked, then your wallet is completely ruined, so the security is greatly reduced. So on top of that, someone thought, why not artificially wrap another layer of logic? It's all about a smart contract anyway. Thus, the market for multi-signature wallets emerged. In today's early Web3 world, which is comparable to a dark forest, multi-signature wallets can be said to be the necessary bulletproof vest for hunters who enter the hunting ground. Its importance cannot be overstated.

Gnosis Safe is one of the best in this field.

After experiencing the DApp of Gnosis Safe, reading the open source code of Github, and diving into the daily group of Discord developers for a while, I decided to choose this DApp, mainly because of its frequent iterations, support for the most mainstream chains, and the most complete expansion service. It is the best solution available in the multi-signature field.

Moreover, Gnosis Safe has the source code of the iOS client for the GNU protocol, which has a lot of reference value for you to implement the details of these multi-signature rules.

## On-chain voting
Another important component of a DAO is how the currency is spent. For most community currencies that do not have financial properties, the most useful feature is community governance. And voting is the most common way to do that.

Aragon, Syndicate, Snapshot, and so on, but in the end it was more economical to sign off-chain and submit the results on-chain, so Snapshot was chosen. Snapshot has a very active development community, and questions are answered in seconds.

However, Snapshot is a pure front-end DApp, so there are many interfaces and steps to reverse in order to port to mobile. For example, it requires you to have an ENS domain name, so you have to reverse the ENS registration logic and re-implement it on your end. The good thing is that it is an open source contract, so you need to dig the graves of some deeper hidden code. The porting process is like a treasure hunt, where you scratch your head to find an ancient JS implementation of a parameter that you couldn't figure out in an obscure repo.

Snapshot has also taken polling to a whole new level, with a wide range of features such as yes voting, sorted voting, secondary voting, weighted voting, and more, in addition to the basic single choice voting, and the community is still developing new features.

## Assemble it
With the above two main functions, you still need to implement some basic DAO functions by yourself.

Currently, SafeDao only supports the ETH mainnet and Goreli testnet, mainly because Snapshot supports both of them; therefore, a TokenFactory smart contract needs to be published on the mainnet to issue DAO currencies; at the same time, the initial currencies have to be transferred to the multi-signature wallet after creation for subsequent distribution to members from the multi-signature wallet. Members of the multi-signature wallet will automatically become Snapshot voting members once they hold the corresponding DAO token. As for how the two services are linked, I thought of a triky way to use the hash address of the multisig wallet as the Snapshot Space name, although it's a bit of a rub.

In addition, this is my first complete App written entirely in the SwiftUI framework, and the takeaway is that SwiftUI is still a very early Baby, with a very modern and efficient mechanism for handling data, but with many custom animations and the need for extreme performance, there are still many limitations and bugs.

## Final
At first the idea was still for my own family service, then I found that there are not a few demand for these two products on the market, and neither of them has an integrated mobile terminal, so I had the idea of releasing it to the public, of course it is bound to be open source, after all, I am also from the open source project.

Finally, I hope that blockchain is no longer only speculative things like coins and NFT digital collectibles, so that the day to influence the real world will come sooner and really ignite the potential of human collaboration.

# Credit
[Gnosis-Safe](https://github.com/safe-global/safe-contracts)

[Snapshot Labs](https://github.com/snapshot-labs)

<img width="18" alt="tw" src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/2491px-Twitter-logo.svg.png"> [@KittenYang](https://twitter.com/KittenYang)


## Tip Jar
Open Source works will not be longer without your support.

<img width="18" alt="eth" src="https://i.seadn.io/gae/_PL7VvNBC2eA_YMqswTazvjEN4Fw4WkSeyPFQtNEUzOn1o_AFVCeUY-bnG5FHd9p5Hvi-Jn8x9aNYgvOd9247lhnwFf-UTn7hddQ?auto=format"> [0x9D68df58C48ce745306757897bb8FaA3FE72A1BF](https://metamask.app.link/send/0x9D68df58C48ce745306757897bb8FaA3FE72A1BF)

