import SwiftUI

extension ShapeStyle where Self == Color {
   init(fromInt value: Int) {
      let red = CGFloat((value & 0xFF0000) >> 16) / 255
      let green = CGFloat((value & 0x00FF00) >> 8) / 255
      let blue = CGFloat(value & 0x0000FF) / 255
      
      self.init(red: red, green: green, blue: blue)
   }
}
