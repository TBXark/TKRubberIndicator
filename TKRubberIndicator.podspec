Pod::Spec.new do |s|
  s.name         = "TKRubberPageControl"
  s.version      = "1.0.0"
  s.summary      = "A rubber pagec ontrol in Swift."
  s.homepage     = "https://github.com/TBXark/TKRubberIndicator"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.author       = { "vfanx" => "tbxark@qq.com" }
  s.source       = { :git => "https://github.com/TBXark/TKRubberIndicator.git", :tag => "1.0.0" }
  s.platform     = :ios, '8.0'
  s.source_files = 'Classes/*.{h,m,swift}'
  s.requires_arc = true
end
