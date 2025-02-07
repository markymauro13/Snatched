//
//  SnatchedWidgetLiveActivity.swift
//  SnatchedWidget
//
//  Created by Mark Mauro on 2/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SnatchedWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SnatchedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SnatchedWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SnatchedWidgetAttributes {
    fileprivate static var preview: SnatchedWidgetAttributes {
        SnatchedWidgetAttributes(name: "World")
    }
}

extension SnatchedWidgetAttributes.ContentState {
    fileprivate static var smiley: SnatchedWidgetAttributes.ContentState {
        SnatchedWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SnatchedWidgetAttributes.ContentState {
         SnatchedWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SnatchedWidgetAttributes.preview) {
   SnatchedWidgetLiveActivity()
} contentStates: {
    SnatchedWidgetAttributes.ContentState.smiley
    SnatchedWidgetAttributes.ContentState.starEyes
}
