//
//  Chat.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import Foundation

struct Chat: Identifiable, Codable, Hashable {
    var id: String
    var label: String
    var createdAt: Date
}
