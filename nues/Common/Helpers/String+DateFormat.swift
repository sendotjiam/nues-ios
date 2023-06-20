//
//  String+DateFormat.swift
//  nues
//
//  Created by Sendo Tjiam on 20/06/23.
//

import Foundation

extension String {
    func updateToDateString() -> String {
        let dateFormatter = DateFormatter()
        guard let dateString = self.components(separatedBy: "T").first else {
            return ""
        }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        guard let date = date else {
            return ""
        }
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
