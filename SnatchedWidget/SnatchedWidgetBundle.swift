//
//  SnatchedWidgetBundle.swift
//  SnatchedWidget
//
//  Created by Mark Mauro on 2/7/25.
//

import WidgetKit
import SwiftUI

@main
struct SnatchedWidgetBundle: WidgetBundle {
    var body: some Widget {
        SnatchedWidget()
        SnatchedWidgetControl()
        SnatchedWidgetLiveActivity()
    }
}
