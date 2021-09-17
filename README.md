# flutter_adfit  
  
카카오애드핏에서 제공하는 광고 배너 뷰를 구현한 패키지입니다.
* 본 패키지는 카카오애드핏에서 정식 제공하는 플러그인이 아닙니다.
* 카카오애드핏에서 제공하는 광고에 대한 자세한 사항은 [AdFit 플랫폼](http://adfit.kakao.com/)에서 확인하세요

- [x]  android
- [x] iOS
- [ ] web

  
## Getting Started  

### 1.  광고단위ID(Client ID) 발급받기
광고를 수신하기 위해서는 먼저 [AdFit 플랫폼](http://adfit.kakao.com/)에서 앱을 등록하고 광고단위 ID(Client ID)를 발급받아야 합니다. 아래의 웹 사이트에서 앱을 등록하고 광고단위 ID를 발급 받을 수 있습니다. AdFit 플랫폼 : [](http://adfit.kakao.com/)[http://adfit.kakao.com](http://adfit.kakao.com)


### 2. 프로젝트 설정하기

**2-1. Android**

* AdFitSDK (3.8.5)
SDK 관련 사항은 [adfit-android-sdk 가이드](https://github.com/adfit/adfit-android-sdk/blob/master/docs/GUIDE.md)를 확인하세요.

a) 네트워크 보안 설정 (target API 28 이상)
>앱의 targetSdkVersion 설정이 Android 9(API 레벨 28) 이상인 경우, 광고 노출 및 클릭이 정상적으로 동작하기 위해서는 일반 텍스트 트래픽을 허용하는 네트워크 보안 설정이 필요합니다.

1.  `res/xml/network_security_config.xml` 생성하여 아래 내용을 추가합니다.    
    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <network-security-config>
        <base-config cleartextTrafficPermitted="true"/>
    </network-security-config>
    ```
2.  `AndroidManifest.xml` 에 아래 속성 추가합니다
    
    ```xml
    <application 
       ...
       android:networkSecurityConfig="@xml/network_security_config" >
    ```


**2-2. iOS**

* AdFitSDK (3.8.5)
SDK 관련 사항은 [adfit-ios-sdk 가이드](https://github.com/adfit/adfit-ios-sdk/wiki/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0)를 확인하세요.

a) iOS 9 ATS(App Transport Security) 처리 ( iOS 9 이상)
>iOS 9부터 [ATS(App Transport Security)](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/) 기능이 기본적으로 활성화 되어 있으며, 암호화된 HTTPS 방식의 통신만 허용됩니다.AdFit SDK는 ATS 활성화 상태에서도 정상적으로 동작하도록 구현되어 있으나, 광고를 통해 노출되는 광고주 페이지는 HTTPS 방식을 지원하지 않을 수도 있습니다.따라서 아래의 사항을 앱 프로젝트의 Info.plist 파일에 적용하여 주시기 바랍니다.

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

b) Objective-C 프로젝트 (Objective-C only)

>AdFit SDK는 최신 Xcode를 기반으로 개발되었습니다. Objective-C 기반의 프로젝트에서 AdFit SDK를 사용하기 위해서는 Swift Standard 라이브러리들을 Embed 시켜주어야 합니다. 앱 프로젝트의 빌드 세팅에서 `Always Embed Swift Standard Libraries` 항목을 `Yes`로 설정해주세요.

c) ATT(App Tracking Transparency) framework 적용 (iOS 14 이상)

>iOS14 타겟팅된 앱은 IDFA 식별자를 얻기 위해서는 ATT Framework를 반드시 적용해야 합니다.
>앱이 사용자 또는 장치를 추적하기 위해 데이터 권한을 요청하는 이유를 사용자에게 알리는 메세지를 추가해야 합니다.
```xml
<key> NSUserTrackingUsageDescription </key>
<string> 맞춤형 광고 제공을 위해 사용자의 데이터가 사용됩니다. </string>

```

## Usage

```dart
import 'package:flutter_adfit/flutter_adfit.dart';

AdFitBanner(  
  iosAdId: "<IOS_AD_ID>",  
  androidAdId: "<ANDROID_AD_ID>",  
  adSize: AdFitBannerSize.BANNER,  
  listener: (event, data) {  
    switch (event) {  
		case AdFitEvent.AdReceived:  
	        break;  
		case AdFitEvent.AdClicked:  
	        break;  
		case AdFitEvent.AdReceiveFailed:  
	        break;  
		case AdFitEvent.OnError:  
	        break;  
	  }  
  },  
)
```
<br>

### AdFitBannerSize
|					|size		|
|-------------------|-----------|
|`LARGE_RECTANGLE`	|300x250	|
|`BANNER`			|320x100	|
|`SMALL_BANNER`		|320x50		|



### AdFitEvent
|					|description			|
|-------------------|-----------|
|`AdReceived`		|배너 광고 노출 완료 시 호출 `AdFitSDK event`	|
|`AdClicked`		|배너 광고 클릭 시 호출 `AdFitSDK event`		|
|`AdReceiveFailed`	|배너 광고 노출 실패 시 호출 `AdFitSDK event` <br>에러 코드는 AdFitSDK 에서 확인하세요.	|
|`OnError`			|배너 광고 초기화 실패 `package event` 		|
