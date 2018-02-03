#
# Be sure to run `pod lib lint FSImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FSImagePicker'
  s.version          = '0.1.0'
  s.summary          = 'An customizable image picker supporting multiselection.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
FSImagePickerViewController is an image picker supporting multiselection and simple customizations.
                       DESC

  s.homepage         = 'https://github.com/vahan3x/FSImagePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vahan Babayan' => 'vahan3x@gmail.com' }
  s.source           = { :git => 'https://github.com/vahan3x/FSImagePicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'FSImagePicker/Classes/**/*'
  
  s.resources = ['FSImagePicker/Assets/*.xcassets']

  s.public_header_files = 'FSImagePicker/Classes/Public/**/*.h'
  s.private_header_files = 'FSImagePicker/Classes/Private/**/*.h'
  s.frameworks = 'Foundation', 'UIKit', 'Photos'
end
