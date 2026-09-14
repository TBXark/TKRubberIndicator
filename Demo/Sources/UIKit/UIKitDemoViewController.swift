//
//  UIKitDemoViewController.swift
//  TKRubberPageControlDemo
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import TKRubberPageControl
import UIKit

/// Showcase of the UIKit implementation.
final class UIKitDemoViewController: UIViewController {

  private let pageControl = TKRubberPageControl(
    frame: .zero,
    count: DemoData.defaultPageCount
  )
  private let customPageControl: TKRubberPageControl = {
    var config = TKRubberPageControlConfig()
    config.backgroundColor = .systemIndigo
    config.smallBubbleColor = .systemTeal
    config.bigBubbleColor = .systemYellow
    return TKRubberPageControl(frame: .zero, count: DemoData.defaultPageCount, config: config)
  }()

  private let statusLabel = UILabel()
  private let eventLabel = UILabel()
  private let pageCountControl = UISegmentedControl(
    items: DemoData.pageCounts.map(String.init)
  )
  private let previousButton = UIButton(type: .system)
  private let nextButton = UIButton(type: .system)

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "TKRubberPageControl"
    view.backgroundColor = .systemBackground

    configurePageControl()
    configureStatusLabels()
    configurePageCountControl()
    configureButtons()
    layoutContent()
    updateStatus()
  }

  // MARK: - Configuration

  private func configurePageControl() {
    pageControl.valueChange = { [weak self] index in
      self?.eventLabel.text = "valueChange: page \(index)"
    }
    pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    customPageControl.translatesAutoresizingMaskIntoConstraints = false
  }

  private func configureStatusLabels() {
    statusLabel.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
    statusLabel.textColor = .label
    statusLabel.textAlignment = .center

    eventLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    eventLabel.textColor = .secondaryLabel
    eventLabel.textAlignment = .center
    eventLabel.text = "Tap the indicator"
    eventLabel.numberOfLines = 0
  }

  private func configurePageCountControl() {
    pageCountControl.selectedSegmentIndex =
      DemoData.pageCounts.firstIndex(
        of: DemoData.defaultPageCount
      ) ?? 0
    pageCountControl.addTarget(
      self,
      action: #selector(pageCountChanged(_:)),
      for: .valueChanged
    )
  }

  private func configureButtons() {
    previousButton.setTitle("Previous", for: .normal)
    previousButton.addTarget(self, action: #selector(selectPreviousPage), for: .touchUpInside)

    nextButton.setTitle("Next", for: .normal)
    nextButton.addTarget(self, action: #selector(selectNextPage), for: .touchUpInside)
  }

  // MARK: - Layout

  private func layoutContent() {
    let buttons = UIStackView(arrangedSubviews: [previousButton, nextButton])
    buttons.axis = .horizontal
    buttons.distribution = .fillEqually
    buttons.spacing = 16

    let defaultSection = makeSection(
      title: "Default",
      control: pageControl,
      footer: statusLabel
    )
    let customSection = makeSection(
      title: "Custom style",
      control: customPageControl,
      footer: eventLabel
    )

    let stack = UIStackView(arrangedSubviews: [
      defaultSection,
      pageCountControl,
      buttons,
      customSection,
    ])
    stack.axis = .vertical
    stack.spacing = 24
    stack.alignment = .fill

    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)

    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),

      stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
      stack.bottomAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
      stack.leadingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
      stack.trailingAnchor.constraint(
        equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
      stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),

      pageControl.widthAnchor.constraint(equalToConstant: DemoData.controlSize.width),
      pageControl.heightAnchor.constraint(equalToConstant: DemoData.controlSize.height),
      customPageControl.widthAnchor.constraint(equalToConstant: DemoData.controlSize.width),
      customPageControl.heightAnchor.constraint(equalToConstant: DemoData.controlSize.height),
    ])
  }

  private func makeSection(title: String, control: UIView, footer: UIView) -> UIStackView {
    let heading = UILabel()
    heading.text = title
    heading.font = .preferredFont(forTextStyle: .headline)
    heading.textColor = .label

    let controlRow = UIStackView(arrangedSubviews: [control])
    controlRow.axis = .vertical
    controlRow.alignment = .center

    let stack = UIStackView(arrangedSubviews: [heading, controlRow, footer])
    stack.axis = .vertical
    stack.spacing = 12
    stack.alignment = .fill
    return stack
  }

  // MARK: - Actions

  @objc private func pageControlValueChanged(_ sender: TKRubberPageControl) {
    updateStatus()
  }

  @objc private func pageCountChanged(_ sender: UISegmentedControl) {
    let count = DemoData.pageCounts[sender.selectedSegmentIndex]
    pageControl.numberOfPage = count
    customPageControl.numberOfPage = count
    updateStatus()
  }

  @objc private func selectPreviousPage() {
    pageControl.currentIndex -= 1
    customPageControl.currentIndex -= 1
  }

  @objc private func selectNextPage() {
    pageControl.currentIndex += 1
    customPageControl.currentIndex += 1
  }

  private func updateStatus() {
    statusLabel.text = "currentIndex: \(pageControl.currentIndex) of \(pageControl.numberOfPage)"
  }
}
