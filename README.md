# SAFER: Storm Assistance for Emergency Resilience

This is the `flutter` code for the SAFER app built for Prof. Carolyn Lin.

## Common Commands

### To check if `flutter` is configured properly
```
flutter doctor
```

### To run/build the app
```
flutter run
```

### To build an `APK` file:
```
flutter build apk --release
```

### I swear it was working before...
```
rm pubspec.lock
flutter clean
flutter clean cache
flutter pub cache clean
flutter run
```# safer-app

⸻

SAFER iOS Release & App Store Upload Guide

This document provides a full, end-to-end guide for maintaining and publishing the SAFER iOS app. It is designed for future developers responsible for updating and releasing the app to the Apple App Store.

The guide includes environment setup, certificate management, code signing configuration, building, archiving, uploading, App Store Connect configuration, screenshot requirements, and a comprehensive troubleshooting section.

⸻

Table of Contents
	1.	Prerequisites
	2.	Environment Setup
	3.	Signing & Certificates Overview
	4.	Fixing Broken Certificates
	5.	Configuring Xcode
	6.	Building the iOS Release (Flutter)
	7.	Archiving and Exporting the IPA
	8.	Uploading with Transporter
	9.	App Store Connect Setup
	10.	Screenshot and Metadata Requirements
	11.	Common Problems and Fixes
	12.	Final Release Checklist

⸻

1. Prerequisites

Required Access
	•	Apple Developer account access for Professor Lin
	•	App Store Connect access to the SAFER app
	•	GitHub access to the safer-app-main repository
	•	Access to any CI/CD secrets if needed in the future

Required Software
	•	Xcode (latest stable release)
	•	Flutter SDK version 3.29.x or later
	•	CocoaPods
	•	Keychain Access (preinstalled on macOS)

⸻

2. Environment Setup

Verify Flutter installation:

flutter doctor
flutter --version

Clean and refresh the project:

flutter clean
rm pubspec.lock
flutter pub get

Update iOS dependencies:

cd ios
pod install --repo-update
cd ..


⸻

3. Signing & Certificates Overview

The SAFER app relies on the following:
	•	Team ID
	•	Bundle ID
	•	Apple-managed provisioning profiles
	•	Required Apple root certificates, including:
	•	Worldwide Developer Relations Certificate Authority (multiple versions)
	•	Worldwide Developer Relations – G4
	•	Developer ID – G2

If any of these certificates are missing or expired, iOS code signing will fail.

⸻

4. Fixing Broken Certificates

This section covers the most frequent source of publishing failures: invalid or missing Apple root certificates.

Symptoms of certificate issues
	•	Codesigning failures
	•	Errors such as:
	•	release_unpack_ios failed
	•	errSecInternalComponent
	•	unable to build chain to self-signed root
	•	Certificates in Keychain show a warning icon
	•	Xcode cannot generate provisioning profiles

A. Remove invalid root certificates

Open Keychain Access.
In the top-left, select keychain: System Roots.
Search for:
	•	Worldwide Developer Relations Certificate Authority
	•	Worldwide Developer Relations – G4
	•	Developer ID – G2

If any show a warning icon, delete them.

B. Download and reinstall certificates

Download the latest Apple root certificates from Apple’s certificate portal:
	•	Worldwide Developer Relations Certificate Authority (2023)
	•	Worldwide Developer Relations Certificate Authority (2030)
	•	Worldwide Developer Relations – G4
	•	Developer ID – G2

Drag each certificate into:

Keychain Access → System → Certificates

C. Verify certificates

Search in Keychain for:
	•	Worldwide Developer
	•	Developer ID

All should appear with valid (green) status.

D. Confirm signing identities

Run:

security find-identity -p codesigning -v

You should see both:
	•	Apple Development: Carolyn Lin
	•	Apple Development: [current developer]

If any are missing, certificate installation is incomplete.

⸻

5. Configuring Xcode

Open the iOS workspace:

open ios/Runner.xcworkspace

A. Signing & Capabilities

For each target:
	•	Runner
	•	RunnerTests
	•	RunnerUITests
	•	Pods-Runner

Set the following:

Setting	Value
Automatically manage signing	Enabled
Team	University of Connecticut
Bundle Identifier	com.uconn.safer
Signing Certificate	Apple Development
Provisioning Profile	Generated automatically

Each target must use the same Team.

B. iOS Deployment Target

Set to whatever iOS version you please (there will only be a few avaliable)

Ensure the Podfile & AppFrameworkInfo.plist also lists the same iOS you select (currently 15.0)

⸻

6. Building the iOS Release (Flutter)

Run:

flutter clean
flutter pub get
flutter build ios --release

Expected output:

✓ Built build/ios/iphoneos/Runner.app

If not, refer to the troubleshooting section.

⸻

7. Archiving and Exporting the IPA in Xcode

This is the recommended method for producing a signed IPA.
	1.	In Xcode, select the device dropdown:
Choose Any iOS Device (arm64)
	2.	Open the Archive window:

Product → Archive


	3.	After the archive completes:
	•	Click Distribute App
	•	Select App Store Connect
	•	Select Upload
	•	Ensure the correct signing identity is selected

If archiving fails, refer to Section 11.

⸻

8. Uploading with Transporter

If needed as an alternative to Xcode:
	1.	Open Transporter
	2.	Drag the .ipa from:

build/ios/ipa/


	3.	Click Upload

⸻

9. App Store Connect Setup

Once the build appears in App Store Connect:

Required fields:
	•	“What’s New” text
	•	Promotional text (optional but recommended)
	•	Description
	•	Keywords
	•	Support URL
	•	App icon (handled in Xcode)
	•	App Store screenshots (see Section 10)

Compliance

For “Export Compliance”:

Choose:

No, the app does not use encryption beyond Apple-provided APIs.

Submit the version for review once all requirements are complete.

⸻

10. Screenshot and Metadata Requirements

App Store Connect accepts only specific screenshot resolutions.

Accepted screenshot sizes:

iPhone 6.7-inch
	•	1284 × 2778
	•	2778 × 1284

iPhone 6.5-inch
	•	1242 × 2688
	•	2688 × 1242

Screenshots taken from simulators other than iPhone 13/14/15 Pro Max will be rejected.

⸻

11. Common Problems and Fixes

Codesigning Error: “Failed to codesign Flutter.framework”

Causes:
	•	Missing Worldwide Developer Relations certificates
	•	Incorrect Signing & Capabilities settings
	•	Xcode using wrong signing identity

Fix:
	•	Reinstall all four Apple certificates
	•	Reconfigure Xcode targets
	•	Verify security find-identity shows both identities

⸻

Error: “unable to build chain to self-signed root”

Fix:
	•	Deleted or corrupted root certificates
	•	Reinstall the Worldwide Developer Relations certificates

⸻

Error: Provisioning Profile Not Found

Fix:
	•	Ensure “Automatically manage signing” is enabled
	•	Ensure the Team is set to “University of Connecticut”

⸻

Error: Screenshots rejected

Fix:
	•	Capture screenshots using iPhone Pro Max simulators
	•	Ensure images match exact dimensions

⸻

Xcode Archive Fails

Fix:
Clear DerivedData:

rm -rf ~/Library/Developer/Xcode/DerivedData


⸻

12. Final Release Checklist

Before Building
	•	Flutter is installed and validated
	•	CocoaPods installed and pods updated
	•	All root certificates installed correctly
	•	All Xcode targets configured with the same Team
	•	Deployment target set to iOS 15.0

Build
	•	flutter clean
	•	flutter pub get
	•	flutter build ios --release successful

Archive
	•	Archive completed in Xcode
	•	Upload through Xcode or Transporter

App Store Connect
	•	“What’s New” updated
	•	Screenshots uploaded in correct resolutions
	•	Export compliance answered
	•	Version submitted for review

⸻