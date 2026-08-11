haveno seems not usable for now ...

basically, haveno is only a tool to create a market, similar to openbazaar
but a stable haveno market has not-yet been created (?)



haveno-reto

the seednode seems offline: 
bugc27z7lqjgpwmhbuu3kuwoq2bhailj573r32jm5ydwrcqrwjtblnid.onion:1002

$ torsocks nc bugc27z7lqjgpwmhbuu3kuwoq2bhailj573r32jm5ydwrcqrwjtblnid.onion 1002
1720959904 ERROR torsocks[402405]: Host unreachable (in socks5_recv_connect_reply() at socks5.c:539)

$ curl --proxy socks5h://user$RANDOM@127.0.0.1:9050 http://bugc27z7lqjgpwmhbuu3kuwoq2bhailj573r32jm5ydwrcqrwjtblnid.onion:1002
curl: (97) Can't complete SOCKS5 connection to bugc27z7lqjgpwmhbuu3kuwoq2bhailj573r32jm5ydwrcqrwjtblnid.onion. (4)

gui statusbar: no seed nodes available

Jul-14 14:11:24.109 [JavaFX Application Thread] INFO  h.n.p2p.peers.getdata.RequestDataHandler: Sending getDataRequest to bugc27z7lqjgpwmhbuu3kuwoq2bhailj573r32jm5ydwrcqrwjtblnid.onion:1002 failed. That is expected if the peer is offline.
        getDataRequest=PreliminaryGetDataRequest(supportedCapabilities=[0, 1, 2, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16]).
        Exception=java.lang.RuntimeException: java.io.IOException: Cannot connect to hidden service 
Jul-14 14:11:24.117 [JavaFX Application Thread] WARN  haveno.core.app.P2PNetworkSetup: onNoSeedNodeAvailable 



TODO
Warning
We did not receive a filter object from the seed nodes.
Please inform the Haveno network administrators to register a filter object with ctrl + f.
https://github.com/haveno-dex/haveno/issues/1135



TODO "create new offer" fails
Warning
There are no arbitrators available.
-> create account first?



https://www.reddit.com/r/Monero/



https://www.reddit.com/r/Monero/comments/1e077v4/no_kyc_now_and_working_no_pipe_dreams/



https://old.reddit.com/r/Monero/comments/1drzhth/localmonero_alternative/lazk36a/?context=3&share_id=TTNkmw-t5BdYo43RWLnQH

2024-06-30

What exchanges to use then?

[basicswap looks nice]

Exchange method	  Exchanges	              Trust level
DEX	              Haveno                  ✅ escrow
                    https://github.com/haveno-dex/haveno
                    https://github.com/retoaccess1/haveno-reto
                  Bisq
                    https://github.com/bisq-network/bisq
P2P               Bitpapa                 ✅ escrow
                    https://bitpapa.com/
                    BTC ETH TON USDT XMR
                  Robosats
                    https://github.com/RoboSats/robosats
                    BTC
                  Paxful
                    https://paxful.com/
                    BTC USDT ETH USDC
                  ~LocalMonero~
                  ~AgoraDesk~
Atomic swaps      UnstoppableSwap.net     ✅ trustless
                    https://unstoppableswap.net/
                    XMR BTC
                  AtomicMonero
                    https://www.atomicmonero.com/
                    BTC ETH XMR
                  BasicSwapDEX
                    https://basicswapdex.com/
                    https://github.com/basicswap/basicswap
                    BTC XMR DASH LTC FIRO PIVX DCR WOW PART
                    todo: XNO
                  swap from XNO
                    https://hub.nano.org/trading/swap-service/101
                  nanswap
                    https://nanswap.com/swap/XNO/XMR
                    lightweight
                  changenow
                    https://changenow.io/?from=nano&to=xmr&amount=10
                    also fiat to crypto
                  swapswop
                    https://swapswop.io/
                  exchang
                    https://exchang.io/
                  simpleswap
                    https://simpleswap.io/crypto-to-crypto/xno-xmr
                    expensive?
                    slow website
                    scam?
                      https://old.reddit.com/r/Monero/comments/lqickm/simpleswap_is_a_scam/
                  changelly
                    https://changelly.com/exchange/xno/xmr
                    min: 30 xno
                    not trusted by https://www.reddit.com/r/Monero
                  letsexchange
                    https://letsexchange.io/
                    min: 100 xno
                  GrowBridge
                    https://bridge.growsol.io/
                    broken?
                      https://old.reddit.com/r/nanocurrency/comments/1bt02sx/dex_for_nano_please_share_your_favourite_dex/
                    min: 200 xno
                  exolix
                    https://exolix.com/
                    min: 300 xno
                  ~Samourai Wallet~
AMM               SeraiDEX                low for users / medium for liquidity providers (hacks)

AMM = automatic market makers



https://blog.nihilism.network/servers/haveno-client-f2f/index.html



https://monero.observer/first-public-haveno-networks-mainnet-hardenedsteel-retoaccess1/

14 May 2024 | Updated 26 May 2024

HardenedSteel, retoaccess1 experiment with first ever public Haveno networks on mainnet

HardenedSteel1 and retoaccess12 have separately started running
the first two ever public Haveno networks on Monero’s mainnet,
only 48 hours after woodser6’s quick start guide7 was published

Note: use at your own risk and only trade with small amounts that you can afford to lose.



https://monero.town/post/3125326

2024-05-13

Havno mainnet deployment guide posted

https://github.com/haveno-dex/haveno/blob/master/docs/create-mainnet.md

It looks like some plans changed at the 11th hour.
People on r/monero were saying that in the current climate,
the seed nodes would be shut down and the Haveno Council members arrested.

So instead, it looks like the devs are just releasing the software,
and there are to be multiple competing instances of Haveno.
Anybody can create a Haveno mainnet,
they are responsible for finding hosting, appointing arbitrators,
setting maker/taker fees, and staying anonymous.
The seed nodes are hidden behind Tor hidden services.
If one instance gets shut down, several more can immediately start up.
The Haveno and Monero developers avoid being operators or taking fees,
which makes it more difficult to lawfare them.
