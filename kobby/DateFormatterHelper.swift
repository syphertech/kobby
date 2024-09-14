//
//  DateFormatterHelper.swift
//  kobby
//
//  Created by Maxwell Anane on 9/8/24.
//


//
//  DateFormatting.swift
//  kobby
//
//  Created by Maxwell Anane on 9/8/24.
//

import Foundation

struct DateFormatterHelper {
    // Static function to format a date string from the original format to MM/dd/yyyy
    static func formattedDate(from timestamp: String?, originalFormat: String = "yyyy/MM/dd/HH/mmss", desiredFormat: String = "MM/dd/yyyy") -> String {
        guard let timestamp = timestamp else { return "Unknown Date" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = originalFormat
        if let date = formatter.date(from: timestamp) {
            formatter.dateFormat = desiredFormat
            return formatter.string(from: date)
        }
        
        return "Invalid Date"
    }
}
