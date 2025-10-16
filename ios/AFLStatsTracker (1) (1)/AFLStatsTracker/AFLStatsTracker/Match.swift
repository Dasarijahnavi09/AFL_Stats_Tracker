//
//  Movie.swift
//  AFLStatsTracker
//
//  Created by Jahnavi Dasari on 14/5/2025.
//

import Foundation
import FirebaseFirestore

struct Match: Codable {
    @DocumentID var documentID: String?
    var team1Name: String
    var team2Name: String
    var team1Score: String 
    var team2Score: String
    var quarter: Int
    var timestamp: Date
}
