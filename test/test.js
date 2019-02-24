var MiniMeTokenFactory = artifacts.require("MiniMeTokenFactory");
var ERC677BridgeToken = artifacts.require("ERC677BridgeToken");
var MiniMeToken = artifacts.require("MiniMeToken");
var SimpleDealProxy = artifacts.require("SimpleDealProxy");
var SimpleDealLogic = artifacts.require("SimpleDealLogic");
var SimpleDealData = artifacts.require("SimpleDealData");
const ipfs = require("nano-ipfs-store").at("https://ipfs.swarm.city");
// const uuid = require("uuid");


contract('SimpleDealProxy', (accounts) => { 

    var seeker = accounts[1]; // The "Seeker" account
    var provider = accounts[2]; // The "Provider" account
    var maintainer = accounts[3]; // The "Maintainer" account
    var hashtagContract; // The SimpleDeal hashtag contract
    var logicContract;
    var dataContract;
    var swtToken; // The fake SWT token
    var swrsToken; // The "Seeker" reputation token address
    var swrpToken; // The "Provider" reputation token address
    var itemIdHash = {};
    var currentItemHash; // the itemHash the test is currently working with


    describe('Staging: Token Deploy', function () {
        it("should deploy SWT Bridged token contract", async function () {
            swtToken = await ERC677BridgeToken.new(
                "Swarm City Token Bridged",
                "SWTTEST",
                18
                );
                assert.ok(swtToken.address);
        });

        it("should mint SWT for Seeker", async function () {
            await swtToken.mint(seeker, 100);
            var balance = await swtToken.balanceOf(seeker);
            assert.equal(balance.toNumber(), 100, "Seeker balance not correct after swt minting");
        });

        it("should mint SWT for Provider", async function () {
            await swtToken.mint(provider, 100);
            var balance = await swtToken.balanceOf(provider);
            assert.equal(balance.toNumber(), 100, "Provider balance not correct after swt minting");
        });

        it("should see correct token balance Seeker account", async function () {
            var balance = await swtToken.balanceOf(seeker);
            console.log(balance.toNumber());
            //assert.equal(balance.toNumber(), 69700000000000000000, "Seeker balance not correct");
        });

        it("should see correct token balance provider account", async function () {
            var balance = await swtToken.balanceOf(provider);
            console.log(balance.toNumber());
            //assert.equal(balance.toNumber(), 69700000000000000000, "Seeker balance not correct");
        });

        
    });

    describe('Staging: SimpleDealProxy Deploy', function() {
        it("should deploy a SimpleDealProxy", async function () {
            var hashtagMetaJson = {
                "hashtagName": "Settler",
                "hashtagFee": 6,
                "description": "",
                "hashtagList": 0x0 
            };
        
            var hashtagMetaHash = await ipfs.add(JSON.stringify(hashtagMetaJson));
            var bytes32_hashtagMetaHash = web3.utils.fromAscii(hashtagMetaHash);

            hashtagContract = await SimpleDealProxy.new(
                swtToken.address, 
                "TestHashtag", 
                6, 
                "0x0");

            assert.isNotNull(hashtagContract);
        });

        it("should check Library", async function () {
            var address = await hashtagContract.Logic.call();
            logicContract = address.toString('hex');
            assert.isNotNull(logicContract);
        });

        it("should check Data", async function () {
            var address = await hashtagContract.Data.call();
            dataContract = address.toString('hex');
            assert.isNotNull(dataContract);
        });

        it("should create Seeker reputation token", async function () {
            var address = await hashtagContract.SeekerRep.call();
            swrsToken = address.toString('hex');
            assert.isNotNull(swrsToken);
        });

        it("should set Maintainer address", async function () {
            var result = await hashtagContract.setPayoutAddress(maintainer, {
              gas: 4700000,
              from: accounts[0]
            });
            var contractMaintainer = await hashtagContract.payoutAddress.call();
            assert.equal(contractMaintainer, maintainer, "Maintainer address not set");
        });
    });

    describe('Happy Flow: Item Creation Stage', function () {
        it("should create a new Item on the Hashtag contract", async function () {
            // 0. Upload to IPFS
            const metadataHash = await ipfs.add(JSON.stringify({
                username: "Frank",
                avatarHash: "QmSwyxpLq1h8gJe4uSRXgyStfMSonZTKcFAL6yuPB2QLEh",
                description: "Need a ride to Poland",
                location: "Location",
                publicKeySeeker: seeker
            }));

            var hashtagFee = await hashtagContract.hashtagFee.call();

            const itemBudgetWei = 30;
            const totalSum = parseInt(itemBudgetWei) + parseInt(hashtagFee / 2);

            currentItemHash = web3.utils.fromAscii(metadataHash);

            console.log(currentItemHash)

            var simpleDealContract = await new web3.eth.Contract(SimpleDealLogic.abi, logicContract);
            const rawNewItem = await simpleDealContract.methods.newItem(
                web3.utils.fromAscii("ItemHash"),
                itemBudgetWei,
                web3.utils.fromAscii("ItemHash")
            ).encodeABI();

            const result = await swtToken.transferAndCall(
                hashtagContract.address, // spender
                totalSum, // totalSum
                rawNewItem, // next call data
                {
                    from: seeker,
                    gas: 4700000
                }
            );

            assert.isNotNull(result);
        });

        it("should see correct token balance Seeker account", async function () {
            var balance = await swtToken.balanceOf(seeker);
            console.log(balance.toNumber());
            //assert.equal(balance.toNumber(), 69700000000000000000, "Seeker balance not correct");
        });

        it("should see correct token balance Hashtag account", async function () {
            var balance = await swtToken.balanceOf(hashtagContract.address);
            console.log(balance.toNumber());
            //assert.equal(balance.toNumber(), 30000000000000000000, "Hashtag balance not correct");
        });

        it("should see correct token balance Maintainer account", async function () {
            var balance = await swtToken.balanceOf(maintainer);
            console.log(balance.toNumber());
            //assert.equal(balance.toNumber(), 300000000000000000, "Maintainer balance not correct");
        });

        it("should find the Item on the Hashtag", async function () {
            var simpleDealDataInstance = await new web3.eth.Contract(SimpleDealData.abi, dataContract);
            var result = await simpleDealDataInstance.methods.readItemData(web3.utils.fromAscii("ItemHash")).call();
            console.log(result);
            //assert.equal(result[0].toNumber(), 0, "Item creation error");
        });
    });
});