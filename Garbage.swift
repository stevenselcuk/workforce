//
//  Garbage.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import Cocoa
import Foundation
import Introspect
import SwiftUI
import SwiftDate

private var dateFormattersCache = [String: DateFormatter]()

extension Array where Element: Equatable {
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = index(of: item) {
            move(at: index, to: newIndex)
        }
    }
    
    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }
    
    mutating func sendToBack(item: Element) {
        move(item, to: endIndex-1)
    }
}

extension Array {
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}

extension Date {
    func string(format: String) -> String {
        if let dateFormatter = dateFormattersCache[format] {
            return dateFormatter.string(from: self)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormattersCache[format] = dateFormatter
            return dateFormatter.string(from: self)
        }
    }

    var prevMonth: Date {
        dateByAdding(-1, .month).date
    }

    var nextMonth: Date {
        dateByAdding(1, .month).date
    }

    var endOfLastMonth: Date {
        dateByAdding(-1, .month).dateAtEndOf(.month).dateByAdding(-1, .day).date
    }

    var startOfNextMonth: Date {
        dateByAdding(1, .month).dateAtStartOf(.month).date
    }

    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)) ~= self
    }

    func add(_ unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }

    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }

    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }

    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }

    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }

    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }

    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }

    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }

    // This Month Start
    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }

    func getThisMonthEnd() -> Date? {
        let components: NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }

    // Last Month Start
    func getLastMonthStart() -> Date? {
        let components: NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }

    // Last Month End
    func getLastMonthEnd() -> Date? {
        let components: NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}



public extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

extension List {
    /// List on macOS uses an opaque background with no option for
    /// removing/changing it. listRowBackground() doesn't work either.
    /// This workaround works because List is backed by NSTableView.
    func removeBackground() -> some View {
        return introspectTableView { tableView in
            tableView.backgroundColor = .clear
            tableView.enclosingScrollView!.drawsBackground = false
        }
    }
}

extension NSImage {
    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }

    func oval() -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        NSGraphicsContext.current?.imageInterpolation = .high
        let frame = NSRect(origin: .zero, size: size)
        NSBezierPath(ovalIn: frame).addClip()
        draw(at: .zero, from: frame, operation: .sourceOver, fraction: 1)

        image.unlockFocus()
        return image
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension NSColor {
    var hexString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "#FFFFFF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
        return hexString as String
    }
}

extension String {
    func conformsTo(_ pattern: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
}

extension NSColor {
    convenience init(hex: Int, alpha: Float) {
        self.init(
            calibratedRed: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }

    convenience init(hex: String, alpha: Float) {
        // Handle two types of literals: 0x and # prefixed
        var cleanedString = ""
        if hex.hasPrefix("0x") {
            cleanedString = String(hex[hex.index(cleanedString.startIndex, offsetBy: 2) ... hex.endIndex])
        } else if hex.hasPrefix("#") {
            cleanedString = String(hex[hex.index(cleanedString.startIndex, offsetBy: 1) ... hex.endIndex])
        }

        // Ensure it only contains valid hex characters 0
        let validHexPattern = "[a-fA-F0-9]+"
        if cleanedString.conformsTo(validHexPattern) {
            var value: UInt32 = 0
            Scanner(string: cleanedString).scanHexInt32(&value)
            self.init(hex: Int(value), alpha: 1)
        } else {
            fatalError("Unable to parse color?")
        }
    }
}

extension CGImage {
    // In order to get the color at a given pixel from a CGImage, we need to convert the CGImage's
    // data to a bitmap and draw it. We do so via a CGContext, and then manually extract the data at
    // the desired pixel.
    func colorAt(x: Int, y: Int) -> NSColor {
        assert(0 <= x && x < width)
        assert(0 <= y && y < height)

        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(height)

        // Allocate memory for image data. This is the destination in memory where any drawing to
        // the bitmap context will be rendered.
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitmapData = malloc(bitmapByteCount)

        // Since we manually allocate memeory for the data, we must ensure that the same memory is
        // freed after we've used it.
        defer {
            if let ptr = bitmapData {
                free(ptr)
            }
        }

        // Create the bitmap context.
        let context = CGContext(
            data: bitmapData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bitmapBytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo.rawValue
        )

        // Extract the pixel data from the right offset.
        if context != nil {
            // First, we draw the image data onto the context we created.
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context!.draw(self, in: rect)

            // Then we extract the data at the right spot.
            let data = context!.data!
            let offset = 4 * (y * width + x)

            let a = CGFloat(data.load(fromByteOffset: offset, as: UInt8.self)) / 255.0
            let r = CGFloat(data.load(fromByteOffset: offset + 1, as: UInt8.self)) / 255.0
            let g = CGFloat(data.load(fromByteOffset: offset + 2, as: UInt8.self)) / 255.0
            let b = CGFloat(data.load(fromByteOffset: offset + 3, as: UInt8.self)) / 255.0
            return NSColor(red: r, green: g, blue: b, alpha: a)
        }

        // Creating the context failed, so return a default color instead.
        // Hopefully, this should never happen.
        print("Failed to create CGContext!")

        return NSColor.black
    }
}

extension NSColor {
    func bestContrastingColor() -> NSColor {
        let rgb: [CGFloat] = [redComponent, greenComponent, blueComponent].map({
            if $0 <= 0.03928 {
                return $0 / 12.92
            } else {
                return pow(($0 + 0.055) / 1.055, 2.4)
            }
        })

        let L = 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]
        return L > 0.197 ? NSColor.black : NSColor.white
    }
}


extension UserDefaults {
    public func optionalString(forKey defaultName: String) -> String? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? String
        }
        return nil
    }

    public func optionalAny(forKey defaultName: String) -> Any? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value
        }
        return nil
    }

    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }

    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
    public func optionalFloat(forKey defaultName: String) -> Float? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Float
        }
        return nil
    }
}

public extension NSColor {
    /**
     Creates an immuatble UIColor instance specified by a hex string, CSS color name, or nil.

     - parameter hexString: A case insensitive String? representing a hex or CSS value e.g.

     - **"abc"**
     - **"abc7"**
     - **"#abc7"**
     - **"00FFFF"**
     - **"#00FFFF"**
     - **"00FFFF77"**
     - **"Orange", "Azure", "Tomato"** Modern browsers support 140 color names (<http://www.w3schools.com/cssref/css_colornames.asp>)
     - **"Clear"** [UIColor clearColor]
     - **"Transparent"** [UIColor clearColor]
     - **nil** [UIColor clearColor]
     - **empty string** [UIColor clearColor]
     */
    public convenience init(hex: String?) {
        let normalizedHexString: String = NSColor.normalize(hex)
        var c: CUnsignedInt = 0
        Scanner(string: normalizedHexString).scanHexInt32(&c)
        self.init(red: UIColorMasks.redValue(c), green: UIColorMasks.greenValue(c), blue: UIColorMasks.blueValue(c), alpha: UIColorMasks.alphaValue(c))
    }

    /**
     Returns a hex equivalent of this UIColor.

     - Parameter includeAlpha:   Optional parameter to include the alpha hex.

     color.hexDescription() -> "ff0000"

     color.hexDescription(true) -> "ff0000aa"

     - Returns: A new string with `String` with the color's hexidecimal value.
     */
    public func hexDescription(_ includeAlpha: Bool = false) -> String {
        guard cgColor.numberOfComponents == 4 else {
            return "Color not RGB."
        }
        let a = cgColor.components!.map { Int($0 * CGFloat(255)) }
        let color = String(format: "%02x%02x%02x", a[0], a[1], a[2])
        if includeAlpha {
            let alpha = String(format: "%02x", a[3])
            return "\(color)\(alpha)"
        }
        return color
    }

    fileprivate enum UIColorMasks: CUnsignedInt {
        case redMask = 0xFF000000
        case greenMask = 0x00FF0000
        case blueMask = 0x0000FF00
        case alphaMask = 0x000000FF

        static func redValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & redMask.rawValue) >> 24) / 255.0
        }

        static func greenValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & greenMask.rawValue) >> 16) / 255.0
        }

        static func blueValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat((value & blueMask.rawValue) >> 8) / 255.0
        }

        static func alphaValue(_ value: CUnsignedInt) -> CGFloat {
            return CGFloat(value & alphaMask.rawValue) / 255.0
        }
    }

    fileprivate static func normalize(_ hex: String?) -> String {
        guard var hexString = hex else {
            return "00000000"
        }
        if let cssColor = cssToHexDictionairy[hexString.uppercased()] {
            return cssColor.count == 8 ? cssColor : cssColor + "ff"
        }
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        if hexString.count == 3 || hexString.count == 4 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }
        let hasAlpha = hexString.count > 7
        if !hasAlpha {
            hexString += "ff"
        }
        return hexString
    }

    /**
     All modern browsers support the following 140 color names (see http://www.w3schools.com/cssref/css_colornames.asp)
     */
    fileprivate static func hexFromCssName(_ cssName: String) -> String {
        let key = cssName.uppercased()
        if let hex = cssToHexDictionairy[key] {
            return hex
        }
        return cssName
    }

    fileprivate static let cssToHexDictionairy: [String: String] = [
        "CLEAR": "00000000",
        "TRANSPARENT": "00000000",
        "": "00000000",
        "ALICEBLUE": "F0F8FF",
        "ANTIQUEWHITE": "FAEBD7",
        "AQUA": "00FFFF",
        "AQUAMARINE": "7FFFD4",
        "AZURE": "F0FFFF",
        "BEIGE": "F5F5DC",
        "BISQUE": "FFE4C4",
        "BLACK": "000000",
        "BLANCHEDALMOND": "FFEBCD",
        "BLUE": "0000FF",
        "BLUEVIOLET": "8A2BE2",
        "BROWN": "A52A2A",
        "BURLYWOOD": "DEB887",
        "CADETBLUE": "5F9EA0",
        "CHARTREUSE": "7FFF00",
        "CHOCOLATE": "D2691E",
        "CORAL": "FF7F50",
        "CORNFLOWERBLUE": "6495ED",
        "CORNSILK": "FFF8DC",
        "CRIMSON": "DC143C",
        "CYAN": "00FFFF",
        "DARKBLUE": "00008B",
        "DARKCYAN": "008B8B",
        "DARKGOLDENROD": "B8860B",
        "DARKGRAY": "A9A9A9",
        "DARKGREY": "A9A9A9",
        "DARKGREEN": "006400",
        "DARKKHAKI": "BDB76B",
        "DARKMAGENTA": "8B008B",
        "DARKOLIVEGREEN": "556B2F",
        "DARKORANGE": "FF8C00",
        "DARKORCHID": "9932CC",
        "DARKRED": "8B0000",
        "DARKSALMON": "E9967A",
        "DARKSEAGREEN": "8FBC8F",
        "DARKSLATEBLUE": "483D8B",
        "DARKSLATEGRAY": "2F4F4F",
        "DARKSLATEGREY": "2F4F4F",
        "DARKTURQUOISE": "00CED1",
        "DARKVIOLET": "9400D3",
        "DEEPPINK": "FF1493",
        "DEEPSKYBLUE": "00BFFF",
        "DIMGRAY": "696969",
        "DIMGREY": "696969",
        "DODGERBLUE": "1E90FF",
        "FIREBRICK": "B22222",
        "FLORALWHITE": "FFFAF0",
        "FORESTGREEN": "228B22",
        "FUCHSIA": "FF00FF",
        "GAINSBORO": "DCDCDC",
        "GHOSTWHITE": "F8F8FF",
        "GOLD": "FFD700",
        "GOLDENROD": "DAA520",
        "GRAY": "808080",
        "GREY": "808080",
        "GREEN": "008000",
        "GREENYELLOW": "ADFF2F",
        "HONEYDEW": "F0FFF0",
        "HOTPINK": "FF69B4",
        "INDIANRED": "CD5C5C",
        "INDIGO": "4B0082",
        "IVORY": "FFFFF0",
        "KHAKI": "F0E68C",
        "LAVENDER": "E6E6FA",
        "LAVENDERBLUSH": "FFF0F5",
        "LAWNGREEN": "7CFC00",
        "LEMONCHIFFON": "FFFACD",
        "LIGHTBLUE": "ADD8E6",
        "LIGHTCORAL": "F08080",
        "LIGHTCYAN": "E0FFFF",
        "LIGHTGOLDENRODYELLOW": "FAFAD2",
        "LIGHTGRAY": "D3D3D3",
        "LIGHTGREY": "D3D3D3",
        "LIGHTGREEN": "90EE90",
        "LIGHTPINK": "FFB6C1",
        "LIGHTSALMON": "FFA07A",
        "LIGHTSEAGREEN": "20B2AA",
        "LIGHTSKYBLUE": "87CEFA",
        "LIGHTSLATEGRAY": "778899",
        "LIGHTSLATEGREY": "778899",
        "LIGHTSTEELBLUE": "B0C4DE",
        "LIGHTYELLOW": "FFFFE0",
        "LIME": "00FF00",
        "LIMEGREEN": "32CD32",
        "LINEN": "FAF0E6",
        "MAGENTA": "FF00FF",
        "MAROON": "800000",
        "MEDIUMAQUAMARINE": "66CDAA",
        "MEDIUMBLUE": "0000CD",
        "MEDIUMORCHID": "BA55D3",
        "MEDIUMPURPLE": "9370DB",
        "MEDIUMSEAGREEN": "3CB371",
        "MEDIUMSLATEBLUE": "7B68EE",
        "MEDIUMSPRINGGREEN": "00FA9A",
        "MEDIUMTURQUOISE": "48D1CC",
        "MEDIUMVIOLETRED": "C71585",
        "MIDNIGHTBLUE": "191970",
        "MINTCREAM": "F5FFFA",
        "MISTYROSE": "FFE4E1",
        "MOCCASIN": "FFE4B5",
        "NAVAJOWHITE": "FFDEAD",
        "NAVY": "000080",
        "OLDLACE": "FDF5E6",
        "OLIVE": "808000",
        "OLIVEDRAB": "6B8E23",
        "ORANGE": "FFA500",
        "ORANGERED": "FF4500",
        "ORCHID": "DA70D6",
        "PALEGOLDENROD": "EEE8AA",
        "PALEGREEN": "98FB98",
        "PALETURQUOISE": "AFEEEE",
        "PALEVIOLETRED": "DB7093",
        "PAPAYAWHIP": "FFEFD5",
        "PEACHPUFF": "FFDAB9",
        "PERU": "CD853F",
        "PINK": "FFC0CB",
        "PLUM": "DDA0DD",
        "POWDERBLUE": "B0E0E6",
        "PURPLE": "800080",
        "RED": "FF0000",
        "ROSYBROWN": "BC8F8F",
        "ROYALBLUE": "4169E1",
        "SADDLEBROWN": "8B4513",
        "SALMON": "FA8072",
        "SANDYBROWN": "F4A460",
        "SEAGREEN": "2E8B57",
        "SEASHELL": "FFF5EE",
        "SIENNA": "A0522D",
        "SILVER": "C0C0C0",
        "SKYBLUE": "87CEEB",
        "SLATEBLUE": "6A5ACD",
        "SLATEGRAY": "708090",
        "SLATEGREY": "708090",
        "SNOW": "FFFAFA",
        "SPRINGGREEN": "00FF7F",
        "STEELBLUE": "4682B4",
        "TAN": "D2B48C",
        "TEAL": "008080",
        "THISTLE": "D8BFD8",
        "TOMATO": "FF6347",
        "TURQUOISE": "40E0D0",
        "VIOLET": "EE82EE",
        "WHEAT": "F5DEB3",
        "WHITE": "FFFFFF",
        "WHITESMOKE": "F5F5F5",
        "YELLOW": "FFFF00",
        "YELLOWGREEN": "9ACD32",
    ]
}

extension NSWindow {
    /// Positions the `NSWindow` at the horizontal-vertical center of the `visibleFrame` (takes Status Bar and Dock sizes into account)
    public func positionCenter() {
        if let screenSize = screen?.visibleFrame.size {
            setFrameOrigin(NSPoint(x: (screenSize.width - frame.size.width) / 2, y: (screenSize.height - frame.size.height) / 2))
        }
    }

    public func positionTopCenter() {
        if let screenSize = screen?.visibleFrame.size {
            setFrameOrigin(NSPoint(x: (screenSize.width - frame.size.width) / 2, y: (screenSize.height - frame.size.height) - 100))
        }
    }

    /// Centers the window within the `visibleFrame`, and sizes it with the width-by-height dimensions provided.
    public func setCenterFrame(width: Int, height: Int) {
        if let screenSize = screen?.visibleFrame.size {
            let x = (screenSize.width - frame.size.width) / 2
            let y = (screenSize.height - frame.size.height) / 2
            setFrame(NSRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height)), display: true)
        }
    }

    /// Returns the center x-point of the `screen.visibleFrame` (the frame between the Status Bar and Dock).
    /// Falls back on `screen.frame` when `.visibleFrame` is unavailable (includes Status Bar and Dock).
    public func xCenter() -> CGFloat {
        if let screenSize = screen?.visibleFrame.size { return (screenSize.width - frame.size.width) / 2 }
        if let screenSize = screen?.frame.size { return (screenSize.width - frame.size.width) / 2 }
        return CGFloat(0)
    }

    /// Returns the center y-point of the `screen.visibleFrame` (the frame between the Status Bar and Dock).
    /// Falls back on `screen.frame` when `.visibleFrame` is unavailable (includes Status Bar and Dock).
    public func yCenter() -> CGFloat {
        if let screenSize = screen?.visibleFrame.size { return (screenSize.height - frame.size.height) / 2 }
        if let screenSize = screen?.frame.size { return (screenSize.height - frame.size.height) / 2 }
        return CGFloat(0)
    }
}

extension View {
    func fontBold(color: Color = .black, size: CGFloat) -> some View {
        font(.custom("Circe-Bold", size: size))
    }

    func fontRegular(color: Color = .black, size: CGFloat) -> some View {
        font(.custom("Circe", size: size))
    }

    func fontLight(color: Color = .black, size: CGFloat) -> some View {
        font(.custom("Circe-Light", size: size))
    }
    
    func fontMonoMedium(color: Color = .black, size: CGFloat) -> some View {
        font(.custom("Cartograph Mono CF Medium", size: size))
    }
}

extension Float {
    var hoursMinutesSecondsFormat: String {
        let seconds = truncatingRemainder(dividingBy: 60).rounded(.toNearestOrAwayFromZero)
        let minutes = (self / 60).truncatingRemainder(dividingBy: 60).rounded(.toNearestOrAwayFromZero)
        let hours = (self / 3600).rounded(.toNearestOrAwayFromZero)
        return String(format: "%02.f:%02.f", hours, minutes)
    }
    var hoursMinutesSecondsFormatFull: String {
        let seconds = truncatingRemainder(dividingBy: 60).rounded(.toNearestOrAwayFromZero)
        let minutes = (self / 60).truncatingRemainder(dividingBy: 60).rounded(.toNearestOrAwayFromZero)
        let hours = (self / 3600).rounded(.toNearestOrAwayFromZero)
        return String(format: "%02.f:%02.f:%02.f", hours, minutes, seconds)
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color).shadow(color: .black, radius: 12, x: 10, y: 5))
    }
}
struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

class FocusNSView: NSView {
    override var acceptsFirstResponder: Bool {
        return true
    }
}

/// Gets the keyboard focus if nothing else is focused.
struct FocusView: NSViewRepresentable {

    func makeNSView(context: NSViewRepresentableContext<FocusView>) -> FocusNSView {
        return FocusNSView()
    }

    func updateNSView(_ nsView: FocusNSView, context: Context) {

        // Delay making the view the first responder to avoid SwiftUI errors.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let window = nsView.window {

                // Only set the focus if nothing else is focused.
                if let _ = window.firstResponder as? NSWindow {
                    window.makeFirstResponder(nsView)
                }
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct BlinkViewModifier: ViewModifier {
    
    let duration: Double
    @State private var blinking: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(Color.gray.opacity(0.1))
            .background(blinking ? Color("Red") : Color.gray.opacity(0.3))
            .animation(.easeOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                withAnimation {
                    blinking = true
                }
            }
    }
}

extension View {
    func blinking(duration: Double = 0.75) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}
