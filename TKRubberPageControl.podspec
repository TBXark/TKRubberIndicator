Pod::Spec.new do |s|
  s.name         = "TKRubberPageControl"
  s.version      = "2.0.0"
  s.summary      = "A rubber animation page control for UIKit and SwiftUI."
  s.description  = <<-DESC
                   TKRubberPageControl is a rubber animation page control.
                   It provides a UIControl based UIKit implementation and a
                   native, Binding driven SwiftUI implementation that share the
                   same layout model.
                   DESC
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.homepage     = "https://github.com/TBXark/TKRubberIndicator"
  s.author       = { "TBXark" => "tbxark@outlook.com" }
  s.source       = { :git => "https://github.com/TBXark/TKRubberIndicator.git", :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'
  s.source_files = 'Sources/TKRubberPageControl/**/*.swift'
  s.frameworks   = 'UIKit', 'SwiftUI'
  s.requires_arc = true
end
