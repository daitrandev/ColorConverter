//
//  UtilitiesConverter.swift
//  ColorConverter
//
//  Created by Dai Tran on 10/21/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

public class UtilitiesConverter {
    public static func ConvertRGBToHex(decimalArray: [Int]) -> String {
        
        var result: String = ""
        
        for decimal in decimalArray {
            result += String(decimal, radix: 16)
        }
        
        return result.uppercased()
    }
        
    public static func ConvertHexColorToRGB(hexString: String) -> [Int] {
        var hex = hexString
        if hex.characters.count != 6 {
            for _ in hex.characters.count..<6 {
                hex += "0"
            }
        }
        
        var hexArray = [String]()
        for i in stride(from: 0, to: 6, by: 2) {
            let start = hex.index(hex.startIndex, offsetBy: i)
            let end = hex.index(hex.startIndex, offsetBy: i + 2)
            let range = start..<end
            
            hexArray.append(hex.substring(with: range))
        }
        
        var RGBValue = [Int]()
        
        for i in 0..<hexArray.count {
            let dec = Int(hexArray[i], radix: 16)!
            RGBValue.append(dec)
        }

        return RGBValue
    }
}
