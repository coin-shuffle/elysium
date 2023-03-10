//
//  RangeSliderView.swift
//  TrueElysium
//
//  Created by Ivan Lele on 09.03.2023.
//

import SwiftUI
import BigInt

struct RangedSliderView: View {
    let currentValue: Binding<ClosedRange<UInt>>
    @Binding var sliderBounds: ClosedRange<UInt>
    
    var body: some View {
        GeometryReader { geomentry in
            sliderView(sliderSize: geomentry.size)
        }
    }
    
        
    @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
        let sliderViewYCenter = sliderSize.height / 2
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(.bar)
                .frame(height: 4)
            ZStack {
                let sliderBoundDifference = sliderBounds.count
                let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)
                
                let leftThumbLocation: CGFloat = currentValue.wrappedValue.lowerBound == sliderBounds.lowerBound
                    ? 0
                    : CGFloat(currentValue.wrappedValue.lowerBound - sliderBounds.lowerBound) * stepWidthInPixel
                
                let rightThumbLocation = CGFloat(currentValue.wrappedValue.upperBound) * stepWidthInPixel
                
                lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
                
                let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
                thumbView(position: leftThumbPoint, value: currentValue.wrappedValue.lowerBound)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)
                        
                        let newValue = sliderBounds.lowerBound + UInt(xThumbOffset / stepWidthInPixel)
                        
                        if newValue < currentValue.wrappedValue.upperBound {
                            currentValue.wrappedValue = newValue...currentValue.wrappedValue.upperBound
                        }
                    })
                
                thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentValue.wrappedValue.upperBound)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)
                        
                        var newValue = UInt(xThumbOffset / stepWidthInPixel)
                        newValue = min(newValue, sliderBounds.upperBound)
                        
                        if newValue > currentValue.wrappedValue.lowerBound {
                            currentValue.wrappedValue = currentValue.wrappedValue.lowerBound...newValue
                        }
                    })
            }
        }
    }
    
    @ViewBuilder func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }.stroke(.black, lineWidth: 4)
    }
    
    @ViewBuilder func thumbView(position: CGPoint, value: UInt) -> some View {
        ZStack {
            Text(String(value))
                .font(.footnote)
                .offset(y: -20)
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(.black)
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                .contentShape(Rectangle())
        }
        .position(x: position.x, y: position.y)
    }
}
