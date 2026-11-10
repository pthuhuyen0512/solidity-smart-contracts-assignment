# Smart Contract Testing Report

**Name: Pham Thu Huyen**
**Roll No: 29201139715**
**Email: thuhuyenpham1234@gmail.com**

## Environment and evidence

Solidity `^0.8.20`, compiled in Remix (EVM target Paris) and tested manually on Ganache (`http://127.0.0.1:7545`) via Custom - External Http Provider. The pragma allows compatible compilers; it does not identify the exact build used.

"Tested" lists only what the saved screenshots show; missing evidence is stated. A/B/C/D are roles within each test, not fixed accounts. A gas-estimation popup is not an on-chain failed receipt, and ETH comparisons must include gas.

## 01 Storage

- **What it does:** Stores an integer set by the constructor; anyone can `set()` and `get()` it.
- **Key concept:** Persistent state, constructor initialization and the `ValueSet` event; reads send no transaction.
- **Tested:** `set(100)` then `get()` returned 100, visible in Ganache. Initial value 42 and decoded event not shown; the contract has no `require`, so no rejection case.
- **Ganache proof:** [Remix result](../screenshots/01_compile.png), [Ganache call](../screenshots/01_ganache.png).

## 02 Greeting

- **What it does:** Stores a public greeting; only the owner can change or reset it.
- **Key concept:** `onlyOwner` access control and the `GreetingChanged` event.
- **Tested:** Owner set `GM Ganache`; `greet()` and Ganache confirm it. Non-owner rejection and reset not shown.
- **Ganache proof:** [Deployment](../screenshots/02_compile.png), [Result and transaction](../screenshots/02_test1.png).

## 03 Counter

- **What it does:** A 0-100 counter with increment, decrement and reset.
- **Key concept:** Boundary checks at 0 and `MAX`; each update emits an event.
- **Tested:** Successful increment/decrement in Remix and Ganache. A decrement at zero was hit during practice; reaching 100, the 101st-increment rejection and reset are not shown.
- **Ganache proof:** [Deployment](../screenshots/03_compile.png), [Increment/decrement](../screenshots/03_test.png).

## 04 Ownable + ProtectedVault

- **What it does:** An ownership base plus an inheriting ETH vault; anyone deposits, only the owner withdraws or transfers ownership.
- **Key concept:** Inheritance reuses `onlyOwner`; the vault checks amounts and handles failed ETH calls.
- **Tested:** `Ownable` alone was deployed first by mistake, then `ProtectedVault`, plus a deposit image. `04_test1.png` shows the vault deployment, not a withdrawal; ownership transfer, non-owner rejection and withdrawal are not shown.
- **Ganache proof:** [First deployment](../screenshots/04_compile.png), [Deposit](../screenshots/04_deposit.png), [ProtectedVault](../screenshots/04_test1.png).

## 05 SimpleBank

- **What it does:** Per-account ETH deposits and withdrawals against an internal balance.
- **Key concept:** Checks-Effects-Interactions: balance reduced before `call{value}`; a failed call reverts and reentrancy reuse is blocked.
- **Tested:** 2 ETH deposit; `myBalance()` = `2000000000000000000` wei. Second user's deposit, rejected 10 ETH withdrawal and 1 ETH withdrawal not shown.
- **Ganache proof:** [Deployment](../screenshots/05_compile.png), [2 ETH deposit](../screenshots/05_test1.png).

## 06 Voting

- **What it does:** The chairperson authorizes voters; one vote each; the highest count wins.
- **Key concept:** Structs, arrays, mappings and role checks; authorizing must not reset a vote; ties go to the first candidate.
- **Tested:** Deployment and reads only (`candidates(0)` = `A`, 0 votes). Full election, winner, duplicate-vote and unauthorized-voter rejection not shown.
- **Ganache proof:** [Deployment](../screenshots/06_compile.png), [Reads](../screenshots/06_test1.png).

## 07 MyToken

- **What it does:** ERC-20-style token without OpenZeppelin; the constructor mints the supply to the deployer.
- **Key concept:** `approve()` uses the actual sender, `allowance()` only reads. Supply is in whole tokens; amounts use 18-decimal units (500 tokens = `500000000000000000000`).
- **Tested:** Deployment and a 500-token transfer. The approval image shows a transaction from A while the B→C allowance is still 0, so it does not prove B approved C. Successful `transferFrom` and exhausted-allowance rejection are unconfirmed.
- **Ganache proof:** [Deployment](../screenshots/07_compile.png), [Transfer](../screenshots/07_transfer.png), [Approval attempt](../screenshots/07_approve.png).

## 08 Crowdfunding

- **What it does:** Collects ETH toward a goal; after the deadline the owner claims if it succeeded, contributors refund if it failed.
- **Key concept:** Timestamp and outcome checks with CEI payouts; `raised` is historical; `claimed` and zeroed contributions stop repeat payouts.
- **Tested:** Separate campaigns show contribution, claim and refund (`contributions(caller)` = 0). The same account was owner and contributor, and a new Ganache block was needed after waiting. Repeat-refund and non-owner claim rejections not shown.
- **Ganache proof:** [Deployment](../screenshots/08_compile.png), [Contribution](../screenshots/08_contribute.png), [Claim](../screenshots/08_test1.png), [Refund](../screenshots/08_test2.png).

## 09 Lottery

- **What it does:** Fixed-fee entries; the manager cannot enter, picks a winner once enough players joined, pays the pot and resets.
- **Key concept:** Payable validation and manager-only selection. Blockhash randomness is manipulable and unfit for real money; Chainlink VRF is stronger.
- **Tested:** Deployment and a rejected `enter()` by the manager (gas-estimate popup, no decoded reason). `09_test1.png` is that rejection, not a draw. Five entries, payout and new round not shown.
- **Ganache proof:** [Deployment](../screenshots/09_compile.png), [Rejected entry](../screenshots/09_test1.png).

## 10 TimeLockVault

- **What it does:** Holds ETH; only the beneficiary withdraws after `unlockTime` and can extend the lock.
- **Key concept:** `block.timestamp` plus an address check; `timeRemaining()` returns 0 after expiry instead of underflowing.
- **Tested:** Deployment and a successful `withdraw()`, with one account as both deployer and beneficiary. Early-withdraw rejection, timestamp comparison, non-beneficiary rejection and `extendLock()` not shown.
- **Ganache proof:** [Deployment](../screenshots/10_compile.png), [Withdrawal](../screenshots/10_test1.png).

## 11 Escrow

- **What it does:** Holds the buyer's payment until delivery, a refund, or an arbiter's dispute ruling.
- **Key concept:** State machine (1 AwaitingDelivery, 2 Complete, 3 Refunded, 4 Disputed); state changes before ETH moves, so no repeat settlement.
- **Tested:** Separate funded instances for delivery, seller refund, dispute to seller and dispute to buyer, plus rejection of repeated confirmation and of confirmation during a dispute. Gas-estimation popups are read with the instance state, not as decoded reverts.
- **Ganache proof:** [Deployment](../screenshots/11_compile.png), [Delivery](../screenshots/11_test1.png), [Refund](../screenshots/11_refund.png), [Seller resolution](../screenshots/11_dispute_seller.png), [Buyer resolution](../screenshots/11_dispute_buyer.png), [Disputed-state rejection](../screenshots/11_disputed_revert.png), [Repeat rejection](../screenshots/11_repeat_revert.png).

## 12 SimpleNFT

- **What it does:** Mints NFTs at 0.01 ETH (max 100); direct and approved transfers; the owner withdraws revenue.
- **Key concept:** Token owner differs from collection owner; only the token owner approves, and a transfer clears approval. An ERC-721-style subset, not full ERC-721.
- **Tested:** Mint, transfer, approval and a successful `transferFrom` (`ownerOf(1)` updated). B, as token owner, must approve, correcting an inconsistent example in the assignment. Wrong-price rejection, the 100 cap and revenue withdrawal not shown.
- **Ganache proof:** [Deployment](../screenshots/12_compile.png), [Transfer](../screenshots/12_transfer.png), [Approval](../screenshots/12_approve.png), [Delegated transfer](../screenshots/12_test1.png).

## 13 EnglishAuction

- **What it does:** Rising bids until a deadline; outbid bidders withdraw refunds; the winning bid goes to the seller.
- **Key concept:** Pull payment via `pendingReturns`, so a refusing recipient cannot block bids; debit before the ETH call plus a reentrancy guard; the 5% increment is rounded up to whole wei.
- **Tested:** Bids, a refund withdrawal and a successful `endAuction()` (`ended = true`). Too-low bid, post-expiry bid and no-bidder auction not shown.
- **Ganache proof:** [Deployment](../screenshots/13_compile.png), [Bids](../screenshots/13_bids.png), [Refund](../screenshots/13_refund.png), [Auction end](../screenshots/13_test1.png).

## 14 MultisigWallet

- **What it does:** A multi-owner ETH wallet that executes a transfer after enough distinct confirmations.
- **Key concept:** Owner checks, per-transaction confirmations and an `executed` flag; submitting auto-confirms, and in a 2-of-3 wallet the second confirmation executes.
- **Tested:** Funding, a pending proposal and a second owner's `confirmTransaction(0)` (two logs, `confirmed(0, owner)` = true). Repeat rejection, non-owner submission rejection and exact recipient balance not shown.
- **Ganache proof:** [Deployment](../screenshots/14_compile.png), [Funding](../screenshots/14_fund.png), [Pending proposal](../screenshots/14_pending.png), [Second confirmation](../screenshots/14_test1.png).

## 15 StakingRewards

- **What it does:** ETH staking with time-based rewards; claim or unstake; the owner funds rewards and changes the rate.
- **Key concept:** Principal and reward pool tracked separately; CEI and a reentrancy guard. Rate = reward wei per 1 ETH per second (`amount * rate * elapsed / 1 ether`), unlike the unscaled PDF formula; a global rate index preserves old rates; the one-day lock is not implemented.
- **Tested:** Stake, positive pending reward, claim and unstake (amount, startTime, rewardDebt all 0). Rewards depend on block timestamps, so the value may not be exactly 60,000 wei. Repeat unstake, multiple claims, pool exhaustion and owner funding/rate changes not shown; no exact per-wei reconciliation is claimed.
- **Ganache proof:** [Deployment](../screenshots/15_compile.png), [Stake](../screenshots/15_stake.png), [Pending reward](../screenshots/15_pending.png), [Claim](../screenshots/15_claim.png), [Unstake](../screenshots/15_test1.png).

## Evidence limitations

The screenshots record the manual work done so far and do not claim every assignment check passed. MyToken's delegated transfer and Lottery's successful draw need more evidence before full coverage is claimed.