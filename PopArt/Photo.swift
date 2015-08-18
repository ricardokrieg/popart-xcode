//
//  Photo.swift
//  PopArt
//
//  Created by Ricardo Franco on 17/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import Foundation

struct Photo {
    let image_url: String
    let score: Float
    let uploaded: Bool
    let painting: Painting?
}