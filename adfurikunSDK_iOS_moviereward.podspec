Pod::Spec.new do |s|
  s.name            = "adfurikunSDK_iOS_moviereward"
  s.version         = "3.1.0"
  s.summary         = "An iOS SDK for ADFURIKUN Movie Reward Ads"
  s.homepage        = "https://adfurikun.jp/adfurikun/"
  s.license         = { :type => 'Copyright', :text => 'Copyright Glossom Inc. All rights reserved.' }
  s.author          = "Glossom Inc."
  s.platform        = :ios, "7.0"
  s.source          = { :path => "." }
  s.default_subspec = 'All'
  s.static_framework = true
  
  s.subspec 'Core' do |core|
    core.vendored_frameworks = '**/ADFMovieReward.framework'
    core.frameworks = 'AdSupport', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreTelephony', 'MediaPlayer', 'StoreKit', 'SystemConfiguration', 'SafariServices', 'UIKit', 'WebKit'
    core.pod_target_xcconfig = { 'OTHER_LDFLAGS' => ['-ObjC', '-fobjc-arc'] }
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'adfurikunSDK_iOS_moviereward/Core'
    applovin.source_files = '**/adnetworks/AppLovin/**/*.{h,m}'
    applovin.vendored_frameworks = '**/adnetworks/AppLovin/AppLovinSDK.framework'
    applovin.frameworks = 'AdSupport', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreTelephony', 'MediaPlayer', 'SafariServices', 'StoreKit', 'SystemConfiguration', 'UIKit', 'WebKit'
    applovin.libraries = 'z'
  end

  s.subspec 'AdColony' do |adcolony|
    adcolony.dependency 'adfurikunSDK_iOS_moviereward/Core'
    adcolony.source_files = '**/adnetworks/AdColony/*.{h,m}'
    adcolony.vendored_frameworks = '**/adnetworks/AdColony/AdColony.framework'
    adcolony.frameworks = 'AdSupport', 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'CoreTelephony', 'JavaScriptCore', 'MessageUI', 'MobileCoreServices', 'SystemConfiguration'
    adcolony.weak_frameworks = 'EventKit', 'Social', 'StoreKit', 'WatchConnectivity', 'WebKit'
    adcolony.libraries = 'z'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'adfurikunSDK_iOS_moviereward/Core'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m}'
    unityads.vendored_frameworks = '**/adnetworks/UnityAds/UnityAds.framework'
    unityads.frameworks = 'AdSupport', 'AVFoundation', 'CFNetwork', 'CoreFoundation', 'CoreMedia', 'CoreTelephony', 'StoreKit', 'SystemConfiguration'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'adfurikunSDK_iOS_moviereward/Core'
    maio.source_files = '**/adnetworks/Maio/*.{h,m}'
    maio.vendored_frameworks = '**/adnetworks/Maio/Maio.framework'
    maio.frameworks = 'AdSupport', 'AVFoundation', 'CoreMedia', 'MobileCoreServices', 'SystemConfiguration', 'WebKit'
    maio.libraries = 'z'
  end

  s.subspec 'Tapjoy' do |tapjoy|
    tapjoy.dependency 'adfurikunSDK_iOS_moviereward/Core'
    tapjoy.source_files = '**/adnetworks/Tapjoy/*.{h,m}'
    tapjoy.vendored_frameworks = '**/adnetworks/Tapjoy/Tapjoy.embeddedframework/Tapjoy.framework'
    tapjoy.resource = '**/adnetworks/Tapjoy/Tapjoy.embeddedframework/Resources/TapjoyResources.bundle'
    tapjoy.frameworks = 'AdSupport', 'CFNetwork', 'CoreData', 'CoreGraphics', 'CoreMotion', 'EventKit', 'EventKitUI', 'Foundation', 'ImageIO', 'Mapkit', 'MediaPlayer', 'MessageUI', 'MobileCoreServices', 'QuartzCore', 'Security', 'SystemConfiguration', 'Twitter', 'UIKit'
    tapjoy.weak_frameworks = 'CoreLocation', 'CoreTelephony', 'PassKit', 'Social', 'StoreKit'
    tapjoy.libraries = 'c++', 'sqlite3.0', 'xml2', 'z'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'adfurikunSDK_iOS_moviereward/Core'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m}'
    vungle.vendored_frameworks = '**/adnetworks/Vungle/VungleSDK.framework'
    vungle.frameworks = 'AdSupport', 'AudioToolBox', 'AVFoundation', 'CFNetwork', 'CoreGraphics', 'CoreMedia', 'Foundation', 'MediaPlayer', 'QuartzCore', 'StoreKit', 'SystemConfiguration', 'UIKit'
    vungle.weak_frameworks = 'WebKit'
    vungle.libraries = 'sqlite3.0', 'z'
  end

  s.subspec 'SmaAD' do |smaad|
    smaad.dependency 'adfurikunSDK_iOS_moviereward/Core'
    smaad.source_files = '**/adnetworks/SmaAD/**/*.{h,m}'
    smaad.vendored_libraries = '**/adnetworks/SmaAD/libSmaadVideoAd.a'
    smaad.resource = '**/adnetworks/SmaAD/SmaadVideoAdResources.bundle'
    smaad.frameworks = 'AdSupport', 'MediaPlayer', 'SystemConfiguration'
  end

  s.subspec 'Five' do |five|
    five.dependency 'adfurikunSDK_iOS_moviereward/Core'
    five.source_files = '**/adnetworks/Five/*.{h,m}'
    five.vendored_frameworks = '**/adnetworks/Five/FiveAd.framework'
    five.frameworks = 'AdSupport', 'AVFoundation', 'CoreMedia', 'CoreTelephony', 'SystemConfiguration'
  end

  s.subspec 'NendAd' do |nendad|
    nendad.dependency 'adfurikunSDK_iOS_moviereward/Core'
    nendad.source_files = '**/adnetworks/NendAd/*.{h,m}'
    nendad.vendored_frameworks = '**/adnetworks/NendAd/NendAd.embeddedframework/NendAd.framework'
    nendad.resource = '**/adnetworks/NendAd/NendAd.embeddedframework/NendAd.framework/Resources/NendAdResource.bundle'
    nendad.frameworks = 'AdSupport', 'AVFoundation', 'CoreLocation', 'CoreMedia', 'CoreMotion', 'CoreTelephony', 'ImageIO', 'Security', 'SystemConfiguration'
    nendad.weak_frameworks = 'WebKit'
  end

  s.subspec 'AfiO' do |afio|
    afio.dependency 'adfurikunSDK_iOS_moviereward/Core'
    afio.source_files = '**/adnetworks/Afio/**/*.{h,m,png}'
    afio.vendored_frameworks = '**/adnetworks/Afio/AMoAd.framework'
    afio.frameworks = 'AdSupport', 'AVFoundation', 'CoreMedia', 'ImageIO', 'StoreKit'
  end

  s.subspec 'All' do |all|
    all.dependency 'adfurikunSDK_iOS_moviereward/Core'
    all.dependency 'adfurikunSDK_iOS_moviereward/AppLovin'
    all.dependency 'adfurikunSDK_iOS_moviereward/AdColony'
    all.dependency 'adfurikunSDK_iOS_moviereward/UnityAds'
    all.dependency 'adfurikunSDK_iOS_moviereward/Maio'
    all.dependency 'adfurikunSDK_iOS_moviereward/Tapjoy'
    all.dependency 'adfurikunSDK_iOS_moviereward/Vungle'
    all.dependency 'adfurikunSDK_iOS_moviereward/SmaAD'
    all.dependency 'adfurikunSDK_iOS_moviereward/Five'
    all.dependency 'adfurikunSDK_iOS_moviereward/NendAd'
    all.dependency 'adfurikunSDK_iOS_moviereward/AfiO'
  end

end
