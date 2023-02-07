//
//  ChartModel.swift
//  family-dao
//
//  Created by KittenYang on 1/27/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import Charts
import UIKit

extension Date {
	static func new(year: Int, month: Int, day: Int = 1, hour: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
		Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes, second: seconds)) ?? Date()
	}
	func getComponents(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
		return calendar.dateComponents(Set(components), from: self)
	}
	
	func getComponents(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
		return calendar.component(component, from: self)
	}
}

enum Constants {
	static let previewChartHeight: CGFloat = 100
	static let detailChartHeight: CGFloat = 280
}

protocol ChartDateValue {
	associatedtype Value: Comparable & Plottable
	var day: Date { get set }
	var yValue: Value { get set }
	var initialValue: Value  { get set }
}

extension ChartDateValue {
	func isAbove(threshold: Value) -> Bool {
		self.yValue > threshold
	}
}

public struct StoredCurrencyHistory: Codable {
	var history: [String:[CurrencyHistory]]
	
	mutating func saveDatas(family:String, user:String, data:[CurrencyHistory]) {
		let key = "\(family):\(user)"
		self.history[key] = data
	}
	
	func datas(family:String, user:String) -> [CurrencyHistory]? {
		let key = "\(family):\(user)"
		return self.history[key]
	}
}

public struct CurrencyHistory:ChartDateValue,Codable, Hashable {
	var day: Date
	var initialValue: Int
	var yValue: Int
}

//enum SalesData {
//	/// Sales by day for the last 30 days.
//	static let last30Days = [
//		(day: Date.new(year: 2022, month: 5, day: 8), sales: 168),
//		(day: Date.new(year: 2022, month: 5, day: 9), sales: 117),
//		(day: Date.new(year: 2022, month: 5, day: 10), sales: 106),
//		(day: Date.new(year: 2022, month: 5, day: 11), sales: 119),
//		(day: Date.new(year: 2022, month: 5, day: 12), sales: 109),
//		(day: Date.new(year: 2022, month: 5, day: 13), sales: 104),
//		(day: Date.new(year: 2022, month: 5, day: 14), sales: 196),
//		(day: Date.new(year: 2022, month: 5, day: 15), sales: 172),
//		(day: Date.new(year: 2022, month: 5, day: 16), sales: 122),
//		(day: Date.new(year: 2022, month: 5, day: 17), sales: 115),
//		(day: Date.new(year: 2022, month: 5, day: 18), sales: 138),
//		(day: Date.new(year: 2022, month: 5, day: 19), sales: 110),
//		(day: Date.new(year: 2022, month: 5, day: 20), sales: 106),
//		(day: Date.new(year: 2022, month: 5, day: 21), sales: 187),
//		(day: Date.new(year: 2022, month: 5, day: 22), sales: 187),
//		(day: Date.new(year: 2022, month: 5, day: 23), sales: 119),
//		(day: Date.new(year: 2022, month: 5, day: 24), sales: 160),
//		(day: Date.new(year: 2022, month: 5, day: 25), sales: 144),
//		(day: Date.new(year: 2022, month: 5, day: 26), sales: 152),
//		(day: Date.new(year: 2022, month: 5, day: 27), sales: 148),
//		(day: Date.new(year: 2022, month: 5, day: 28), sales: 240),
//		(day: Date.new(year: 2022, month: 5, day: 29), sales: 242),
//		(day: Date.new(year: 2022, month: 5, day: 30), sales: 173),
//		(day: Date.new(year: 2022, month: 5, day: 31), sales: 143),
//		(day: Date.new(year: 2022, month: 6, day: 1), sales: 137),
//		(day: Date.new(year: 2022, month: 6, day: 2), sales: 123),
//		(day: Date.new(year: 2022, month: 6, day: 3), sales: 146),
//		(day: Date.new(year: 2022, month: 6, day: 4), sales: 214),
//		(day: Date.new(year: 2022, month: 6, day: 5), sales: 250),
//		(day: Date.new(year: 2022, month: 6, day: 6), sales: 146)
//	].map { Sale(day: $0.day, initialValue: 0, sales: $0.sales) }
//
//	/// Total sales for the last 30 days.
//	static var last30DaysTotal: Int {
//		last30Days.map { $0.sales }.reduce(0, +)
//	}
//
//	static var last30DaysAverage: Double {
//		Double(last30DaysTotal / last30Days.count)
//	}
//
//}

enum ChartInterpolationMethod: Identifiable, CaseIterable {
	case linear
	case monotone
	case catmullRom
	case cardinal
	case stepStart
	case stepCenter
	case stepEnd
	
	var id: String { mode.description }
	
	var mode: InterpolationMethod {
		switch self {
		case .linear:
			return .linear
		case .monotone:
			return .monotone
		case .stepStart:
			return .stepStart
		case .stepCenter:
			return .stepCenter
		case .stepEnd:
			return .stepEnd
		case .catmullRom:
			return .catmullRom
		case .cardinal:
			return .cardinal
		}
	}
}

enum AccessibilityHelpers {
	// TODO: This should be a protocol but since the data objects are in flux this will suffice
	static func chartDescriptor<T:ChartDateValue>(forSalesSeries data: [T],
												  saleThreshold: T.Value? = nil,
												  isContinuous: Bool = false) -> AXChartDescriptor {

		// Since we're measuring a tangible quantity,
		// keeping an independant minimum prevents visual scaling in the Rotor Chart Details View
		let min = 0 // data.map(\.sales).min() ??
		let _max = data.map(\.yValue).max()
		var max: Int = 0
		if let __max = _max as? Double {
			max = Int(__max)
		} else if let __max = _max as? Int {
			max = __max
		}

		// A closure that takes a date and converts it to a label for axes
		let dateTupleStringConverter: ((T) -> (String)) = { dataPoint in

			let dateDescription = dataPoint.day.formatted(date: .complete, time: .omitted)

			if let threshold = saleThreshold {
				let isAbove = dataPoint.isAbove(threshold: threshold)

				return "\(dateDescription): \(isAbove ? "Above" : "Below") threshold"
			}

			return dateDescription
		}

		let xAxis = AXNumericDataAxisDescriptor(
			title: "Date index",
			range: Double(0)...Double(data.count),
			gridlinePositions: []
		) { "Day \(Int($0) + 1)" }

		let yAxis = AXNumericDataAxisDescriptor(
			title: "Sales",
			range: Double(min)...Double(max),
			gridlinePositions: []
		) { value in "\(Int(value)) sold" }

		let series = AXDataSeriesDescriptor(
			name: "Daily sale quantity",
			isContinuous: isContinuous,
			dataPoints: data.enumerated().map { (idx, point) in
				var sales: Double = 0.0
				if let _sales = point.yValue as? Double {
					sales = _sales
				} else if let _sales = point.yValue as? Int {
					sales = Double(_sales)
				}
				return .init(x: Double(idx),
						  y: sales,
						  label: dateTupleStringConverter(point))
			}
		)

		return AXChartDescriptor(
			title: "Sales per day",
			summary: nil,
			xAxis: xAxis,
			yAxis: yAxis,
			additionalAxes: [],
			series: [series]
		)
	}

//	static func chartDescriptor(forLocationSeries data: [LocationData.Series]) -> AXChartDescriptor {
//		let dateStringConverter: ((Date) -> (String)) = { date in
//			date.formatted(date: .abbreviated, time: .omitted)
//		}
//
//		// Create a descriptor for each Series object
//		// as that allows auditory comparison with VoiceOver
//		// much like the chart does visually and allows individual city charts to be played
//		let series = data.map { dataPoint in
//			AXDataSeriesDescriptor(
//				name: "\(dataPoint.city)",
//				isContinuous: false,
//				dataPoints: dataPoint.sales.map { data in
//						.init(x: dateStringConverter(data.weekday),
//							  y: Double(data.sales),
//							  label: "\(data.weekday.weekdayString)")
//				}
//			)
//		}
//
//		// Get the minimum/maximum within each city
//		// and then the limits of the resulting list
//		// to pass in as the Y axis limits
//		let limits: [(Int, Int)] = data.map { seriesData in
//			let sales = seriesData.sales.map { $0.sales }
//			let localMin = sales.min() ?? 0
//			let localMax = sales.max() ?? 0
//			return (localMin, localMax)
//		}
//
//		let min = limits.map { $0.0 }.min() ?? 0
//		let max = limits.map { $0.1 }.max() ?? 0
//
//		// Get the unique days to mark the x-axis
//		// and then sort them
//		let uniqueDays = Set( data
//			.map { $0.sales.map { $0.weekday } }
//			.joined() )
//		let days = Array(uniqueDays).sorted()
//
//		let xAxis = AXCategoricalDataAxisDescriptor(
//			title: "Days",
//			categoryOrder: days.map { dateStringConverter($0) }
//		)
//
//		let yAxis = AXNumericDataAxisDescriptor(
//			title: "Sales",
//			range: Double(min)...Double(max),
//			gridlinePositions: []
//		) { value in "\(Int(value)) sold" }
//
//		return AXChartDescriptor(
//			title: "Sales per day",
//			summary: nil,
//			xAxis: xAxis,
//			yAxis: yAxis,
//			additionalAxes: [],
//			series: series
//		)
//	}
}
