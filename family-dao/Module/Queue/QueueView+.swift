//
//  QueueView+.swift
//  family-dao
//
//  Created by KittenYang on 8/27/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//

import SwiftUI
import MultiSigKit
import web3swift
import SheetKit
import Refresh

struct SectionViewModifier: View {
	
	/* !!!这两个不能改成 @State !!! */

	@Binding var key: SafeHistory.SafeHistoryResult.LabelType

	@Binding var values:[[SafeHistory.SafeHistoryResult]]

	init(key: Binding<SafeHistory.SafeHistoryResult.LabelType>, values: Binding<[[SafeHistory.SafeHistoryResult]]>) {
		self._key = key
		self._values = values//.filter({ !$0.isEmpty })
	}
		
	//"queue": [["同意"],["同意","拒绝"]]
	var body: some View {
		getSection()
	}
	
	private func getSection() -> some View {
		// MARK: 这里必须使用(foreach,id)，不然数据变更不会新增
		return ForEach($values) { value in
			_SectionViewModifier(key: $key, results: value)
		}
	}
	
}


struct _SectionViewModifier: View {
	
	/* !!!这两个不能改成 @State !!! */
	@Binding var key: SafeHistory.SafeHistoryResult.LabelType
	@Binding var results:[SafeHistory.SafeHistoryResult]
	
	//"queue": [["同意"],["同意","拒绝"]]
	var body: some View {
		_section()
	}
	
	// MARK: private
	private var isNext: Bool {
		key == .next
	}
	
	private var isQueued: Bool {
		key == .queued
	}
	
//	@State
	var nonce: UInt256 {
		return self.results.last?.transaction?.executionInfo?.nonce ?? 0
	}
	
	@ViewBuilder
	func sectionheader(_ text: String) -> some View {
		if isNext {
			VStack {
				Text(text + ": \(nonce)")
					.font(.rounded(size: 15.0)).bold()
			}
		} else {
			Text(text + ": \(nonce)")
				.font(.rounded(size: 12.0))
		}
	}
	
	private func _section() -> some View {
		var header_string = ""
		if isNext {
			header_string = "ffsasfnew_hofasfafme_name_perospn_sadsf".appLocalizable
		}
		if isQueued {
			header_string = "fasffasfsaffnew_h_fasfofasfafme_name_perospn".appLocalizable
		}
		return Section(header: sectionheader(header_string)) {
			_cell()
		}
		.id(nonce)
		.transition(.slide)
		.animation(.easeOut, value: nonce)
		.listRowBackground(Color.appBkgColor)
	}
	
	private func _cell() -> some View {
		ForEach($results) { result in //"同意"
			if result.wrappedValue.type == .conflictheader || result.wrappedValue.type == .transaction {
				_cellViewModifier(result:result)
			}
		}
	}
	
	private func _cellViewModifier(result:Binding<SafeHistory.SafeHistoryResult>) -> some View {
		CellViewModifier(result: result, isNextNonce: isNext)
			.padding()
			.overlay {
				if result.wrappedValue.type != .conflictheader {
					GeometryReader { proxy in
						Rectangle()
							.size(width: 6.0, height: proxy.size.height)  // 左侧边框条
							.foregroundColor(result.wrappedValue.uiPattern.color)
					}
				}
			}
	}
	
}


struct CellViewModifier: View {
	
	@Binding var result: SafeHistory.SafeHistoryResult
	
	var isNextNonce: Bool
	
	init(result: Binding<SafeHistory.SafeHistoryResult>, isNextNonce: Bool) {
		self._result = result
		self.isNextNonce = isNextNonce
	}

	var body: some View {
		if result.type == .conflictheader {
			Text("⚠️ \("fassssfnew_hofasfasssfme_name_perospfasfsasfn".appLocalizable)\(result.nonce ?? -1)\n\("fasfnhelloleleoeew_hofasfafme_name_perospn".appLocalizable)")
				.font(Font.rounded(size: 14.0))
				.foregroundColor(Color(hexString: "9A9A9A"))
				.listRowBackground(Color.appBkgColor)
				.id("\(result.nonce ?? -1)_conflict")
		}

		if result.canShowCell {
			QueueViewCell(result: result, isNextNonce: isNextNonce)
				.transition(.blur)
				.animation(.easeOut, value: result.timestamp)
				.contentShape(Rectangle())
				.onTapGesture {
					SheetManager.showSheetWithContent {
						DetailCellView(result: result, isNextNonce: isNextNonce)
					}
				}
		}
	}
}
