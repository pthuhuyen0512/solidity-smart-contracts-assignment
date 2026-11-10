# Solidity Smart Contract Assignment

**Name: Pham Thu Huyen**   
**Roll No: 29201139715**   
**Email: thuhuyenpham1234@gmail.com** 


| # | Contract | Level | Tested on Ganache | Screenshots |
|---|---|---|---|---|
| 01 | [Storage](contracts/01_Storage.sol) | Basic | YES | [Deploy](screenshots/01_compile.png), [Ganache](screenshots/01_ganache.png) |
| 02 | [Greeting](contracts/02_Greeting.sol) | Basic | YES | [Deploy](screenshots/02_compile.png), [Test](screenshots/02_test1.png) |
| 03 | [Counter](contracts/03_Counter.sol) | Basic | YES | [Deploy](screenshots/03_compile.png), [Test](screenshots/03_test.png) |
| 04 | [Ownable + ProtectedVault](contracts/04_Ownable.sol) | Medium | YES | [Deploy](screenshots/04_compile.png), [Deposit](screenshots/04_deposit.png), [Test](screenshots/04_test1.png) |
| 05 | [SimpleBank](contracts/05_SimpleBank.sol) | Medium | YES | [Deploy](screenshots/05_compile.png), [Test](screenshots/05_test1.png) |
| 06 | [Voting](contracts/06_Voting.sol) | Medium | YES | [Deploy](screenshots/06_compile.png), [Test](screenshots/06_test1.png) |
| 07 | [MyToken](contracts/07_MyToken.sol) | Medium | Partial | [Deploy](screenshots/07_compile.png), [Transfer](screenshots/07_transfer.png), [Approve](screenshots/07_approve.png) |
| 08 | [Crowdfunding](contracts/08_Crowdfunding.sol) | Advanced | YES | [Deploy](screenshots/08_compile.png), [Contribution](screenshots/08_contribute.png), [Claim](screenshots/08_test1.png), [Refund](screenshots/08_test2.png) |
| 09 | [Lottery](contracts/09_Lottery.sol) | Advanced | YES | [Deploy](screenshots/09_compile.png), [Test](screenshots/09_test1.png) |
| 10 | [TimeLockVault](contracts/10_TimeLockVault.sol) | Advanced | YES | [Deploy](screenshots/10_compile.png), [Test](screenshots/10_test1.png) |
| 11 | [Escrow](contracts/11_Escrow.sol) | Advanced | YES | [Deploy](screenshots/11_compile.png), [Delivery](screenshots/11_test1.png), [Refund](screenshots/11_refund.png), [Seller resolution](screenshots/11_dispute_seller.png), [Buyer resolution](screenshots/11_dispute_buyer.png), [Disputed-state revert](screenshots/11_disputed_revert.png), [Repeated settlement revert](screenshots/11_repeat_revert.png) |
| 12 | [SimpleNFT](contracts/12_SimpleNFT.sol) | Advanced | YES | [Deploy](screenshots/12_compile.png), [Transfer](screenshots/12_transfer.png), [Approve](screenshots/12_approve.png), [Test](screenshots/12_test1.png) |
| 13 | [EnglishAuction](contracts/13_EnglishAuction.sol) | Expert | YES | [Deploy](screenshots/13_compile.png), [Bids](screenshots/13_bids.png), [Refund](screenshots/13_refund.png), [Test](screenshots/13_test1.png) |
| 14 | [MultisigWallet](contracts/14_MultisigWallet.sol) | Expert | YES | [Deploy](screenshots/14_compile.png), [Funding](screenshots/14_fund.png), [Pending transaction](screenshots/14_pending.png), [Test](screenshots/14_test1.png) |
| 15 | [StakingRewards](contracts/15_StakingRewards.sol) | Expert | YES | [Deploy](screenshots/15_compile.png), [Stake](screenshots/15_stake.png), [Pending reward](screenshots/15_pending.png), [Claim](screenshots/15_claim.png), [Test](screenshots/15_test1.png) |

The screenshots directory currently contains **48 PNG images**, with at least two images for each contract. All screenshots are in the screenshots/ folder. Per-contract details are in report/REPORT.md.

## How to run
1. Open Remix -> paste contract -> compile with 0.8.x
2. Ganache QUICKSTART on 127.0.0.1:7545
3. Remix: Environment = Custom External Http Provider
4. Deploy and test per the checklist in each contract file
