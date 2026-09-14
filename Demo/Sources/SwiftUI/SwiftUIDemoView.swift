//
//  SwiftUIDemoView.swift
//  TKRubberPageControlDemo
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import SwiftUI
import TKRubberPageControl

/// Showcase of the SwiftUI implementation. It mirrors the UIKit tab: a default
/// control, a custom styled control, a page count picker and programmatic
/// navigation.
struct SwiftUIDemoView: View {

  @State private var page = 0
  @State private var customPage = 0
  @State private var pageCount = DemoData.defaultPageCount

  private let customStyle = RubberPageControlStyle(
    barColor: Color(red: 0.30, green: 0.25, blue: 0.70),
    smallBubbleColor: Color(red: 0.25, green: 0.65, blue: 0.75),
    bigBubbleColor: Color(red: 0.95, green: 0.80, blue: 0.20)
  )

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        section(title: "Default") {
          RubberPageControl(selection: $page, pageCount: pageCount)
          status("selection: \(page) of \(pageCount)")
        }

        Picker("Pages", selection: $pageCount) {
          ForEach(DemoData.pageCounts, id: \.self) { count in
            Text("\(count)").tag(count)
          }
        }
        .pickerStyle(SegmentedPickerStyle())

        HStack(spacing: 16) {
          Button("Previous") { page = max(0, page - 1) }
          Button("Next") { page = min(pageCount - 1, page + 1) }
        }

        section(title: "Custom style") {
          RubberPageControl(
            selection: $customPage,
            pageCount: pageCount,
            style: customStyle
          )
          status("selection: \(customPage) of \(pageCount)")
        }
      }
      .padding(24)
    }
  }

  private func section<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(spacing: 12) {
      Text(title)
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      content()
    }
  }

  private func status(_ text: String) -> some View {
    Text(text)
      .font(.system(.body, design: .monospaced))
      .opacity(0.6)
  }
}
