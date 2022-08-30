//
//  CAWidgets.swift
//  CAWidgets
//
//  Created by Jim Phieffer on 8/24/22.
//

import WidgetKit
import SwiftUI

@main
struct CAWidgets: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        LunchWidget()
        LetterDayWidget()
        ScheduleWidget()
    }
}
