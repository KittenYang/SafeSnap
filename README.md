<img width="300" alt="logo" src="https://user-images.githubusercontent.com/5517281/217602093-c696dcd7-2717-49c8-b031-023289685b57.png">

<!-- ![](https://user-images.githubusercontent.com/5517281/217332125-24213eb7-1964-43f4-87cc-e5f613048045.jpeg) -->
# SafeSnap
An open-sourced Web3 iOS Application which combines Gnosis Safe and Snapshot together makes you easily manage your DAOs on your pocket.

# Snapshot
<img width="300" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602637-0d8c8c28-df41-4219-89a8-b695ae3392e4.JPG><img width="300" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602597-10922aad-da6c-4618-80a6-4f483de53469.JPG>

<img width="700" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602656-80656cb4-ba8f-4e8f-a785-659e0977f8a4.JPG>

<img width="700" alt="logo" src=https://user-images.githubusercontent.com/5517281/217602667-e56e1d67-e10d-4041-a409-6af9d77232b7.JPG>


## Preface
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


## 前言
在过去 Web3 大浪淘沙的几年，涌现了一大批所谓的 Web3 链上应用，内容涉及各个赛道。虽然大多数最后都是昙花一现的炮灰，但其中不乏非常有创意、有前景 App。我个人非常看好 DAO 这一赛道。不仅在于它极大地发挥了区块链的特点，更重要的是这将重构人类社会协作的范式。如果说区块链是技术革命，那么 DAO 更像是一次社会革命，虽然现在只是故事的开始，真正实现这个目标恐怕还要很久。



在 2022 上半年上海 Covid-19 疫情封锁期间，我也深刻体验到了 DAO 模式在现实世界的力量。当时小区全部封锁，线上的物资几乎抢购一空，群众只能依靠有渠道的小区楼长统一采购物资。大家自发在小区群里分工合作，采购的采购、搬运的搬运、线上答疑的答疑..... 当时给我的第一感觉是，这俨然就像一个热门的 Web3 项目。Web3 项目的玩法就是在早期你为社区贡献越多，后续就能获得越多项目的空投，包括但不限于 Token 或者 NFT，从而后续项目火了，你可以在市场上套现。本质上和创业获得原始股是一个道理。有人说这是投机和浪费时间的工作，但现实世界中的工作何尝不是这样呢？搞好上级关系、拼命工作赚钱、努力充电学习，不都是为了各种利益，只要别去坑蒙拐骗。所以说底层逻辑是没问题的：越早对社区有贡献的人，理应获得更丰厚的回报，只是区块链把这一过程变得门槛更低、程序化、并且链上可证了。对于项目来说也有好处，早期拥有一批全心全意的粉丝共建，也为后续发展提供了更多可能。 

回到小区 DAO 的例子，群里答疑的人就像 Discord 里的 MOD、采购就像项目的运营在和外界洽谈商务合作、搬运的人就像是开发者埋头写着代码。可以想象如果真的按现有 Web3 项目的路子走下去，发行小区治理代币，任何对小区有利的举动都能获得相应激励，比如上面的采购、搬运、答疑等早期角色都能获得大量空投，那么反过来也会促进更多人加入进来参与小区的共建。到时候小区变得更和谐、居民幸福指数，房价自然水涨船高，然后又会吸引更多优质教育、医疗资源聚集，最终又会不断推动房价。如果外部居民虽不能直接体验小区的居住环境，但通过购买你们的小区货币也能分一杯羹。看吧，Web3 项目的这套玩法放在现实世界似乎也行得通。而那段时间，长宁辖区的居民能分配更好的物资，人民都是用脚投票的，舆情情绪里明显表现出未来在长宁区置业的意向明显高于其他区。现实世界也确实证实了这一点。因此如果 DAO 的基础设施和政策一切准备就绪的时候，是对全社会组织形式的一次大洗牌。

上面对于 DAO 的案例太过于宏大了，其实我们家庭就是一个小型的 DAO，比如你和你的爱人小孩三个人是家庭DAO 的成员，发行一个初始供应量为10000的家庭币，那么谁为家庭做出了贡献了都能获得一定的货币激励，包括但不限于做家务、为家庭创收、孩子做了一件优秀的事等等等等，大家表面上为了获得激励努力为家庭做贡献，实际上最终都是让这个家变得更好了。同时可以加入多签钱包的思路，每一笔激励需要家庭指定数目的成员同时同意才可以通过，后续这些激励可以作为治理代币进行家庭投票，比如今年选择去哪里旅游啊、周末吃什么好吃的、小孩是出国留学还是国内读研......  谁的货币持有量越多，谁的投票权重就越大，毕竟代表你过去对家庭做出贡献更大嘛，最后投票数最多的提案才能通过。一切都是透明、可追溯、不可篡改的。


当我和家庭成员讨论了这个想法，大家都对觉得这个玩法可以尝试下，失败就失败嘛，人生就是在不断试错。于是我开始调研市面上已有的方案。这里就不得不提智能合约的好处了，你能想到的点子这个世界上某个角落的人可能早就已经想到了，并且代码都是链上公开透明的，也就是说你不用自己重复造轮子，更重要的不用担心 Web2 世界里各种环境依赖、不兼容等问题，直接几行代码调用智能合约就行了。而上面想法需要的两个关键应用，正是多签钱包和链上投票。





## 多签钱包

所谓多签钱包，顾名思义就是需要多份签名。一个最基本 BIP 钱包拥有一个彼此唯一对应的公钥、私钥对，一旦你的私钥泄漏了，那么你的这个钱包就彻底废了，因此安全性大打折扣。因此在这之上，就有人想到了，为啥不可以人为的再包装一层逻辑呢？反正都是一个智能合约的事。于是，多签钱包的市场就出现了。在如今堪比黑暗森林的早期 Web3 世界，多签钱包可以说是进场狩猎的猎人们必备的防弹衣了。其重要性不言而喻。

而这个赛道目前的佼佼者，非 Gnosis Safe 莫属。

在体验了 Gnosis Safe 的 DApp、拜读了 Github 开源的源码、潜水 Discord 开发者日常群一段时间之后，我果断选择了这个DApp。主要还是因为它迭代频繁、支持最多主流链、最完善的拓展服务。这应该是目前多签领域现有的最佳方案了。

而且 Gnosis Safe 还有 GNU 协议的 iOS 客户端源码，对于自己实现这些多签规则的细节也有很多参考价值。



## 链上投票

DAO 的另一个重要组成便是如何消费货币。对于大多数没有金融属性的社区货币，最有用的功能便是社区治理了。而治理中投票便是最常见的方式。

这个赛道的选择就很多了。Aragon、Syndicate、Snapshot 等等，最终评估下来还是链下签名、链上提交结果的方式更经济，因此选择了 Snapshot，而且 Snapshot 正好也有测试网的环境，方便配合 Gnosis Safe 进行开发调试，而且 Snapshot 的开发社群也很活跃，提交的问题基本秒回复。

但是 Snapshot 是一个纯前端的 DApp，因此要移植到移动端需要逆向很多接口和步骤。比如它要求你先有一个 ENS 域名，所以还得先逆向出 ENS 的注册逻辑，在端上重新实现一遍。好在都是开源的合约，需要挖坟一些隐藏地比较深的代码。移植的这个过程就像是寻宝，你挠破头皮的想不出的一个参数，最后在一个毫不起眼的 repo 里找到了上古 JS 实现。

同时 Snapshot 可以说是把投票玩出花了，除了最基本的单选投票，还有赞成投票、排序选择投票、二次投票、加权投票等多种玩法，同时社区还在不断开发新功能。



## 组装起来

有了上述两个主要功能，还需要自己实现一些 DAO 的基本功能。

目前 SafeDao 只支持 ETH 主网和 Goreli 测试网，主要是因为 Snapshot 支持这两个；因此需要在主网上发布一个 TokenFactory 的智能合约，用来发行 DAO 货币；同时初始货币在创建后就要全部转移到多签钱包以便后续从多签钱包分发给成员。而多签钱包的成员只要持有了相应 DAO 的 token，就会自动成为拥有 Snapshot 投票权的成员。至于两个服务如何串联起来，我想了一个比较 triky 的路子，直接用多签钱包的 hash 地址作为 Snapshot 的 Space 名，虽然有点搓就是了。

另外，这是我完全用 SwiftUI 框架编写的第一个完整 App，心得就是，SwiftUI 目前还是一个很早期的 Baby，处理数据的机制非常现代和高效，但是很多自定义动画和追求极致性能的需求下，目前还是有很多限制和 bug。



## 最后

起初这个想法还是为了自己家庭服务的，后来发现市面上对这两个产品有需求的不在少数，并且都没有一个整合起来的移动端，因此有了对外发布的想法，当然必然是开放源代码的，毕竟我也是从开源项目中来的。

最后的最后，希望区块链不再只有炒币、数字藏品这些投机的东西了，让影响现实世界的那一天早点到来，真正点燃人类协作的潜力。


