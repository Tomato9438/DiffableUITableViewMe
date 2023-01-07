//
//  Contact.swift
//  DiffableTableMe
//
//  Created by Tomato on 2021/11/02.
//

import Foundation

struct Contact: Hashable {
	var id: Int?
	var firstName: String?
	var lastName: String?
	var dateOfBirth: Date?
}

enum ContactSection: CaseIterable {
	case favorite
	case all
}

/*
 Hashing a value means feeding its essential components into a hash function, represented by the Hasher type.
 The model needs at least one unique propertyto handle the non-duplicated values
*/
