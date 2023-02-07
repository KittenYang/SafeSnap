//
//  PathBetweenTestView.swift
//  family-dao
//
//  Created by KittenYang on 9/1/22
//  Copyright (c) 2022 QITAO Network Technology Co., Ltd. All rights reserved.
//
    
import SwiftUI

struct HeartModel : Identifiable {
	var id = UUID()
}

struct HeartView : View {
	var model : HeartModel
	@State private var offset = CGSize(width: 100, height: 100)
	@State private var initialDragPosition = CGSize(width: 100, height: 100)
	
	var body: some View {
		VStack {
			Image(systemName: "heart.fill")
				.resizable()
				.frame(width: 50, height: 50)
				.position(x: offset.width, y: offset.height)
				.preference(key: ViewPositionKey.self, value: [model.id:offset])
				.gesture(
					DragGesture()
						.onChanged { gesture in
							self.offset = CGSize(width: initialDragPosition.width + gesture.translation.width, height: initialDragPosition.height + gesture.translation.height)
						}
						.onEnded { _ in
							initialDragPosition = self.offset
						}
				)
		}.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct ContentView : View {
	@State private var heartModels : [HeartModel] = [.init(), .init()]
	@State private var positions : [UUID:CGSize] = [:]
	
	var body: some View {
		ZStack {
			ForEach(heartModels) { heart in
				HeartView(model: heart)
			}
			
			Path { path in
				if let first = positions.first {
					path.move(to: CGPoint(x: first.value.width, y: first.value.height))
				}
				positions.forEach { item in
					path.addLine(to: CGPoint(x: item.value.width, y: item.value.height))
				}
			}.stroke()
			
		}.onPreferenceChange(ViewPositionKey.self) { newPositions in
			positions = newPositions
		}
	}
}

struct ViewPositionKey: PreferenceKey {
	static var defaultValue: [UUID:CGSize] { [:] }
	static func reduce(value: inout [UUID:CGSize], nextValue: () -> [UUID:CGSize]) {
		let next = nextValue()
		if let item = next.first {
			value[item.key] = item.value
		}
	}
}

struct HeartView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

/*
 MARK: View
 */


