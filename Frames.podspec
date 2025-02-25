Pod::Spec.new do |s|
  s.name         = "Frames"
  s.version      = "4.0.3"
  s.summary      = "Checkout API Client, Payment Form UI and Utilities in Swift"
  s.description  = <<-DESC
  Checkout API Client and Payment Form Utilities in Swift.
  This library contains methods to implement a payment form as well as UI elements.
                   DESC
  s.homepage     = "https://github.com/checkout/frames-ios.git"
  s.swift_version = "5.0"
  s.license      = "MIT"
  s.author       = { "Checkout.com Integration" => "integration@checkout.com" }
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/checkout/frames-ios.git", :tag => s.version }

  s.source_files = 'Source/**/*.swift'
  s.exclude_files = "Classes/Exclude"
  s.resources = 'Source/Resources/**'

  s.dependency 'PhoneNumberKit', '3.3.3'
  s.dependency 'CheckoutEventLoggerKit', '1.2.0'
  s.dependency 'Checkout', '4.0.2'

end
