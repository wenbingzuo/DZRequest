Pod::Spec.new do |s|
  s.name         = "DZRequest"
  s.version      = "1.0.0"
  s.summary      = "A Simple Wrapper of AFNetworking 3.0"
  s.homepage     = "https://github.com/DaZuo/DZRequest"
  s.license      = "MIT"
  s.authors      = { 'DaZuo' => 'Jaly201319@hotmail.com'}
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/DaZuo/DZRequest.git", :tag => s.version }
  s.source_files = "DZRequest/**/*.{h,m}"
  s.dependency "AFNetworking"
  s.requires_arc = true
end