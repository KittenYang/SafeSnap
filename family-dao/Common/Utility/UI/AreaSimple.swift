//
// Copyright © 2022 Swift Charts Examples.
// Open Source - MIT License

import SwiftUI
import Charts
import Foundation

struct AreaSimple<T:ChartDateValue>: View {
	var isOverview: Bool

    private var oldRawData:[T]
    
    @State var data: [T] = [T]()
    @State private var lineWidth = 3.0
    @State private var interpolationMethod: ChartInterpolationMethod = .catmullRom
    @State private var chartColor: Color = .appTheme
    @State private var showGradient = true
    @State private var gradientRange = 0.4
    @State private var selectedDate: Date?
    
    @State private var selectedElement: T?
    
    init(isOverview: Bool, datas:[T]) {
		self.isOverview = isOverview
        self.oldRawData = datas
        var _retains = [T]()
        for data in datas {
            var newData = data
            newData.yValue = data.initialValue
            _retains.append(newData)
        }
		self._data = State(initialValue: _retains)
		self._selectedElement = State(initialValue: datas.last)
	}

    private var gradient: Gradient {
		var colors = [chartColor]
        if showGradient {
			colors.append(.clear)
//            colors.append(chartColor.opacity(gradientRange))
        }
        return Gradient(colors: colors)
    }

	var body: some View {
		if isOverview {
			chart
		} else {
			chart
				.onAppear {
					for index in data.indices {
						DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {
							withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
								data[index].yValue = self.oldRawData[index].yValue
							}
						}
					}
				}
		}
	}

	private var chart: some View {
		Chart(data, id: \.day) {
			AreaMark(
				x: .value("Date", $0.day),
				y: .value("Sales", $0.yValue)
			)
			.foregroundStyle(gradient)
			.interpolationMethod(interpolationMethod.mode)

			if !isOverview {
				LineMark(
					x: .value("Date", $0.day),
					y: .value("Sales", $0.yValue)
				)
                .accessibilityLabel($0.day.formatted(date: .complete, time: .omitted))
//                .accessibilityValue("\($0.sales) sold")
                .accessibilityHidden(isOverview)
				.lineStyle(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
				.interpolationMethod(interpolationMethod.mode)
				.foregroundStyle(LinearGradient(gradient: Gradient(colors: [.appTheme.opacity(0.6), .appTheme]), startPoint: .leading, endPoint: .init(x: 1.0, y:0.0)))
			}
			if let selectedElement {
				PointMark(
					x: .value("Date", selectedElement.day),
					y: .value("Sales", selectedElement.yValue)
				)
				.symbolSize(CGSize(width: 8.0, height: 8.0))
#if os(macOS)
				.foregroundStyle(Color.primary)
#else
				.foregroundStyle(Color(.red))
#endif
			}
//            if let selectedDate, let sales = self.data.first(where: { $0.day.get(.day) == selectedDate.get(.day) })?.sales {
//                RuleMark(x: .value("Date", selectedDate))
//                    #if os(macOS)
//                    .foregroundStyle(Color.primary)
//                    #else
//                    .foregroundStyle(Color(.label))
//                    #endif
//                PointMark(
//                    x: .value("Date", selectedDate),
//                    y: .value("Sales", sales)
//                )
//                .symbolSize(CGSize(width: 15, height: 15))
//                #if os(macOS)
//                .foregroundStyle(Color.primary)
//                #else
//                .foregroundStyle(Color(.label))
//                #endif
//            }
		}
        .accessibilityChartDescriptor(self)
//        .chartOverlay { proxy in
//            GeometryReader { g in
//                Rectangle().fill(.clear).contentShape(Rectangle())
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { value in
//                                let x = value.location.x - g[proxy.plotAreaFrame].origin.x
//                                print("x:\(x)")
//                                if let date: Date = proxy.value(atX: x) {
//                                    print("date:\(date)")
//                                    self.selectedDate = date
//                                }
//                            }
////                            .onEnded { value in
////                                self.selectedDate = nil
////                            }
//                    )
//            }
//        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                if selectedElement?.day == element?.day {
                                    // If tapping the same element, clear the selection.
                                    selectedElement = nil
                                } else {
                                    selectedElement = element
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedElement = findElement(location: value.location, proxy: proxy, geometry: geo)
                                    }
                            )
                    )
            }
        }
        .chartOverlay { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if let selectedElement {
                        let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day)!
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0

                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 100
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                        Rectangle()
                            .fill(.red)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)

                        VStack(alignment: .center) {
                            Text("\(selectedElement.day, format: .dateTime.year().month().day())")
								.font(.rounded(size: 15.0))
                                .foregroundStyle(.secondary)
                            if let sd = selectedElement.yValue as? Int {
                                Text("\(sd, format: .number)")
									.font(.rounded(size: 16.0, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityHidden(isOverview)
                        .frame(width: boxWidth, alignment: .center)
                        .background {
                            ZStack {
                                Rectangle()
                                    .fill(.clear)
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(.quaternary.opacity(0.4))
                            }
							.background(.ultraThinMaterial)
							.cornerRadius(8.0)
                            .padding(.horizontal, -8)
                            .padding(.vertical, -4)
                        }
                        .offset(x: boxOffset)
                    }
                }
            }
        }
		.chartYAxis(isOverview ? .hidden : .automatic)
		.chartXAxis(isOverview ? .hidden : .automatic)
		.frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
	}

    private var customisation: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Line Width: \(lineWidth, specifier: "%.1f")")
                Slider(value: $lineWidth, in: 1...20) {
                    Text("Line Width")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("20")
                }
            }
            
            Picker("Interpolation Method", selection: $interpolationMethod) {
                ForEach(ChartInterpolationMethod.allCases) { Text($0.mode.description).tag($0) }
            }
            
            ColorPicker("Color Picker", selection: $chartColor)
            Toggle("Show Gradient", isOn: $showGradient.animation())

            if showGradient {
                VStack(alignment: .leading) {
                    Text("Gradiant Opacity Range: \(String(format: "%.1f", gradientRange))")
                    Slider(value: $gradientRange) {
                        Text("Gradiant Opacity Range")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                }
            }
        }
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> T? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for salesDataIndex in data.indices {
                let nthSalesDataDistance = data[salesDataIndex].day.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = salesDataIndex
                }
            }
            if let index {
                return data[index]// as? Sale
            }
        }
        return nil
    }
}

// MARK: - Accessibility
//
extension AreaSimple: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        AccessibilityHelpers.chartDescriptor(forSalesSeries: data)
    }
}

// MARK: - Preview

//struct AreaSimple_Previews: PreviewProvider {
//    static var previews: some View {
////        AreaSimple(isOverview: true)
//        AreaSimple(isOverview: false, datas: SalesData.last30Days)
//    }
//}
