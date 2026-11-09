//
//  Coordinator.swift
//  finora
//
//  Created by Shameem on 7/30/26.
//

import Foundation
import UIKit

protocol Coordinator {
    var rootViewController: UINavigationController? { get set }
    func start()
}
