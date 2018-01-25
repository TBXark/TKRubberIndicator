Pod::Spec.new do |s|
  s.name         = "TKRubberPageControl"
  s.version      = "1.4.0"
  s.summary      = "A rubber pagec ontrol in Swift."
  s.license      = { :type => 'MIT License', :file => 'LICENSE' } 
  s.homepage     = "https://github.com/TBXark/TKRubberIndicator"
  s.author       = { "TBXark" => "tbxark@outlook.com" }
  s.source       = { :git => "https://github.com/TBXark/TKRubberIndicator.git", :tag => s.version }
  s.platform     = :ios, '8.0'
  s.source_files = 'TKRubberPageControl/Classes/**/*'
  s.requires_arc = true
end
