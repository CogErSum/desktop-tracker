import SwiftUI

extension Color {
    static let tmst = TMSTColors()
}

struct TMSTColors {
    let accent = Color(red: 91/255, green: 76/255, blue: 205/255)
    let accentHover = Color(red: 65/255, green: 50/255, blue: 179/255)
    let textPrimary = Color(red: 37/255, green: 29/255, blue: 29/255)
    let textSecondary = Color(red: 102/255, green: 97/255, blue: 97/255)
    let background = Color.white
    let surface = Color(red: 246/255, green: 246/255, blue: 246/255)
    let stroke = Color(red: 235/255, green: 235/255, blue: 235/255)
    let success = Color(red: 132/255, green: 233/255, blue: 194/255)
    let warning = Color(red: 255/255, green: 199/255, blue: 153/255)
    let error = Color(red: 239/255, green: 68/255, blue: 68/255)
}
