//
//  Network.swift
//  GisKit
//
//  Created by Qitao Yang on 2020/10/18.
//

import Moya
import RxSwift
import NetworkKit
import GnosisSafeKit
import web3swift
import BigInt

public enum Network {
	
	/*
	****** Gnosis Safe ******
	 GET
	 */
	case getGnosisSafeInfo(address: String, chain: Chain.ChainID)
	case getGnosisSafeBalance(address: String)
	case getSafeTxHashInfo(safeTxHash: String)
	case getSafeHistory(address: String)
	case getSafeQueued(address: String, cursor: NetworkAPIGnosiSafeQueued.Cursor?)
	
	/*
	 ****** Gnosis Safe ******
	 POST
	 */
	case multisigTransactionsEstimations(address: String)
	case propose(`safe`: String, to: String, value: String = "0", data: Data, operation: Int = 0, nonce: String, safeTxGas: String = "0", baseGas: String = "0", gasPrice: String = "0", gasToken: String = EthereumAddress.zero.address, refundReceiver: String = EthereumAddress.zero.address, safeTxHash: String, sender: String = WalletManager.shared.currentWallet?.address ?? "", origin: String? = nil, signature: String)
	case confirmations(txHash: String, signedTxHash: String)
	

	/*
	 ****** Snapshot ******
	 POST
	 */
	case ensdomains(address:String)
	case spaceInfoByENSNames(names:[String])
	case spaceStatus(domain:String)
	case sigTypedData(address: String, sig:String, typedData:EIP712TypedData)
	case checkAlias(address:String, alias:String)
	case getProposalInfo(id:String)
	case getSpaceAllProposal(domain: String, first: Int, skip: Int)
	case getSpaceStateProposal(domain: String, first: Int, skip: Int, state: SnapshotProposalInfo.ProposalState, startDate: Date?, authors_in:[String]?)
	case getUserSpace(address: String)
	case getScore(domain:String, api_method: String, address: String, strategy: SnapshotSpaceInfo.SnapshotSpaceInfoDetail.SnapshotSpaceInfoDetailStrategy, blockNumber:String)
	case getVoteOfProposal(proposalID:String, first:Int, address:String?, space: String?)
	case spaceSubscription(address: String, space: String)
	
	/*
	 ****** Token ******
	 GET
	 */
	case tokenInfo(tokenContract:String)
	case blockNumber(fromDate: Date,toDate:Date)
	case tokenHolders(adress: EthereumAddress, block: BigUInt)
	
	public var api: NetworkAPI {
		switch self {
		case .getGnosisSafeInfo(let address, let chain):
			return NetworkAPIGnosisSafeInfo(address: address, chain: chain)
		case .getGnosisSafeBalance(let address):
			return NetworkAPIGnosisBalance(address: address)
		case .multisigTransactionsEstimations(let address):
			return NetworkAPIGnosisTransactionEstimation(address: address)
		case .getSafeTxHashInfo(let safeTxHash):
			return NetworkAPIGnosiSafeTxHashInfo(safeTxHash: safeTxHash)
		case .getSafeHistory(let address):
			return NetworkAPIGnosiSafeHistory(address: address)
		case .getSafeQueued(let address, let cursor):
			return NetworkAPIGnosiSafeQueued(address: address, cursor:cursor)
		case .propose(let safe, let to, let value, let data, let operation, let nonce, let safeTxGas, let baseGas, let gasPrice, let gasToken, let refundReceiver, let safeTxHash, let sender, let origin, let signature):
			return NetworkAPIGnosisPropose(safe: safe, to: to, value: value, data: data, operation: operation, nonce: nonce, safeTxGas: safeTxGas, baseGas: baseGas, gasPrice: gasPrice, gasToken: gasToken, refundReceiver: refundReceiver, safeTxHash: safeTxHash, sender: sender, origin: origin, signature: signature)
		case .confirmations(let txHash, let signedTxHash):
			return NetworkAPIGnosiSafeConfirmations(signedSafeTxHash: signedTxHash, safeTxHash: txHash)
		case .ensdomains(address: let address):
			return NetworkAPIEnsdomains(address: address)
		case .spaceInfoByENSNames(let names):
			return NetworkAPISpaceInfo(eth_domain_names: names)
		case .tokenInfo(let tokenContract):
			return NetworkAPITokenInfo(address: tokenContract)
		case .sigTypedData(address: let address, sig: let sig, typedData: let data):
			return NetworkAPISigTypedData(address: address, sig: sig, typedData: data)
		case .getSpaceAllProposal(let domain, let first, let skip):
			return NetworkAPIGetSpaceAllProposal(domain: domain, first: first, skip: skip)
		case .spaceStatus(let domain):
			return NetworkAPISpaceStatus(domain: domain)
		case .checkAlias(let address, let alias):
			return NetworkAPICheckAliases(address: address, alias: alias)
		case .getProposalInfo(let id):
			return NetworkAPIProposalInfo(proposalID: id)
		case .getSpaceStateProposal(let domain, let first, let skip, let state, let startDate, let authors_in):
			return NetworkAPIGetSpaceStateProposal(domain: domain, first: first, skip: skip, state: state, startDate:startDate, author_in:authors_in)
		case .getUserSpace(let address):
			return NetworkAPIGetUserSpace(address: address)
		case .getVoteOfProposal(let proposalID, let first, let address, let space):
			return NetworkAPIGetVoteOfProposal(proposalID: proposalID, first: first, address: address, space: space)
		case .spaceSubscription(let address, let space):
			return NetworkAPISubscription(address: address, space: space)
		case .getScore(let domain, let api_method, let address, let strategy,let blockNumber):
			return NetworkAPIGetScore(domain:domain, api_method: api_method, address: address, strategy: strategy, blockNumber: blockNumber)
		case .blockNumber(let fromDate,let toDate):
			return NetworkAPIBlockHeightByTime(fromDate: fromDate, toDate: toDate)
		case .tokenHolders(let adress, let block):
			return NetworkAPITokenHoldersByBlock(tokenAddress: adress, blockHeight: block)
		}
	}
	
}

