//
//  ChangeActionCountView.swift
//  family-dao
//
//  Created by KittenYang on 1/10/23
//  Copyright (c) 2023 QITAO Network Technology Co., Ltd. All rights reserved.
//
    

import SwiftUI
import MultiSigKit
import BigInt
import Defaults
import NetworkKit

@available(iOS 16.0, *)
struct Stepper : View {
	struct Step:Equatable, Hashable {
		var count:Int = 1
		var direction: Edge = .bottom
	}
	
	@Binding var step: Step
	
	let min = 1
	
	var body: some View {
		HStack {
			Button {
				self.step.direction = .bottom
				self.step.count = max(min, self.step.count+1)
			} label: {
				Image(systemName: "plus.circle")
					.resizable()
					.frame(width: 26, height: 26)
					.fontWeight(.medium)
					.foregroundColor(.white)
			}
			.buttonStyle(.plain)
			
			Text("\(self.step.count)")
				.id(self.step)
				.font(.rounded(size: 70,weight: .bold))
				.monospacedDigit()
				.foregroundColor(.white)
				.transition(.opacity
					.combined(with: .push(from: self.step.direction))
				)
				.frame(width: 180)
			
			Button {
				self.step.direction = .top
				self.step.count = max(min, self.step.count-1)
			} label: {
				Image(systemName: "minus.circle")
					.resizable()
					.frame(width: 26, height: 26)
					.fontWeight(.medium)
					.foregroundColor(.white)
			}
			.buttonStyle(.plain)
			.disabled(self.step.count <= min)
		}
		.animation(.spring(), value: self.step)
	}
}

@available(iOS 16.0, *)
struct ChangeActionCountView: View {
	
	let action: ActionModel
	
	@Binding var flipped: Bool
	
	typealias ActionBlock = (_ act:ActionModel, _ count:Int) -> Void
	
	var endBlock: ActionBlock?
	
	@State var step: Stepper.Step = .init(count:1, direction: .bottom)
	
	@State var alert: Bool = false
	
    var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color(hexString: action.colorHexString)
				VStack(alignment: .center) {
					Spacer()
					Stepper(step: $step)
					Spacer()
					Button {
						flipped = false
						endBlock?(action,self.step.count)
					} label: {
						ZStack {
							Color.white
							SolidColorButton(text: "are_you_sure_".appLocalizable, textColor: .black, bkgColor: .clear, font: Font.rounded(size: 18.0,weight: .bold))
						}
						.cornerRadius(25)
						.frame(.init(width: proxy.size.width * 0.8, height: 50))
						.padding(.bottom,20)
					}
					Button {
						alert = true
					} label: {
						HStack {
							Image(systemName: "trash")
							Text("delete".appLocalizable)
								.font(.rounded(size: 15.0, weight: .bold))
								.foregroundColor(.white)
						}
						.padding(.bottom,20)
					}

				}
			}
			.cornerRadius(20.0)
		}
		.alert("fasfnew_hofasfafme_name_perospn_exitasss".appLocalizable, isPresented: $alert, actions: {
			Button("delete".appLocalizable, role: .destructive, action: {
				alert = false
				flipped = false
                Delay(0.3) {
                    Defaults.removeAction([action])
                }
			})
		})
    }
	
}

@available(iOS 16.0, *)
struct ChangeTaskCountView_Previews: PreviewProvider {
    static var previews: some View {
		ChangeActionCountView(action: .demo, flipped: .constant(false))
			.previewLayout(.fixed(width: 350, height: 350))
    }
}
