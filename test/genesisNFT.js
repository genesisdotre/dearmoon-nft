const { expectThrow, toWei, fromWei } = require('./helpers')

const GenesisNFT = artifacts.require('GenesisNFT')
  
contract('GenesisNFT', async function(accounts) {

    const creator = accounts[0]
    const guy1 = accounts[1];
    const guy2 = accounts[2];
    const guy3 = accounts[3];
    const guy4 = accounts[4];
    const beneficiary = accounts[5];

    const name = "GenesisNFT";
    const symbol = "GNFT";  
    const basePrice = "100000000000000000";
    const multiplier = 11;
    const divisor = 10;
    const limit = 3;


    it('Guy 1 buying for exact value, guy 2 paying too much and being refunded', async () => {
        let genesisNFT = await GenesisNFT.new(name, symbol, beneficiary, basePrice, multiplier, divisor, limit, { from: creator } );

        let guy1BalanceBefore = parseFloat(fromWei(await web3.eth.getBalance(guy1)));
        await genesisNFT.sendTransaction({ value: toWei("0.1"), from: guy1 });
        let guy1BalanceAfter = parseFloat(fromWei(await web3.eth.getBalance(guy1)));
        
        assert.closeTo(guy1BalanceAfter, guy1BalanceBefore - 0.1, 0.01, "guy 1 balance should be reduced");
        assert.equal(await genesisNFT.ownerOf(0), guy1);

        let guy2BalanceBefore = parseFloat(fromWei(await web3.eth.getBalance(guy2)));
        await genesisNFT.sendTransaction({ value: toWei("0.5"), from: guy2 });
        let guy2BalanceAfter = parseFloat(fromWei(await web3.eth.getBalance(guy1)));

        assert.closeTo(guy2BalanceAfter, guy2BalanceBefore - 0.11, 0.01, "guy 2 balance should be refunded");
        assert.equal(await genesisNFT.ownerOf(1), guy2);
    });    

    it('Guy 1 2 3 buying, guy 4 being rejected', async () => {
        let genesisNFT = await GenesisNFT.new(name, symbol, beneficiary, basePrice, multiplier, divisor, limit, { from: creator } );
        let beneficiaryBalanceBefore = parseFloat(fromWei(await web3.eth.getBalance(beneficiary)));

        await genesisNFT.sendTransaction({ value: toWei("0.1"), from: guy1 });
        await genesisNFT.sendTransaction({ value: toWei("0.5"), from: guy2 });
        await genesisNFT.sendTransaction({ value: toWei("0.5"), from: guy3 });

        assert.equal(await genesisNFT.ownerOf(2), guy3);

        await expectThrow( genesisNFT.sendTransaction({ value: toWei("0.5"), from: guy4 }) );

        // BENEFICIARY TO HAVE THE CORRECT BALANCE
        let beneficiaryBalanceAfter = parseFloat(fromWei(await web3.eth.getBalance(beneficiary)));
        assert..closeTo(beneficiaryBalanceBefore + 0.1 + 0.11 + 0.121, beneficiaryBalanceAfter, 0.0000001, "beneficiary should benefit");

        // ALSO SOME SANITY CHECK IF THE ERC721 is working fine (sanity check, not comprehensive)
        await expectThrow( genesisNFT.safeTransferFrom(guy3, guy2, 2, {from: guy4}) );
        await genesisNFT.safeTransferFrom(guy3, guy2, 2, {from: guy3});
        let balanceOfGuy2 = await genesisNFT.balanceOf(guy2)
        assert.equal(balanceOfGuy2, 2, "guy 2 should have exactly 2 tokens");

        console.log("Hurray, I think the tests are passing");
    });

  })