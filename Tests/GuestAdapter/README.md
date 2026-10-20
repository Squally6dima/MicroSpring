# MicroSpring Guest Adapter Test

A minimal UIKit guest adapter used to test MicroSpring's controller-delivery callback.

## Contract

The host must export:

```objc
extern void MSReportGuestRootViewController(UIViewController *rootViewController);
```

The library exports `MicroSpringGuestEntry(const char *containerPath)`. It logs the path, schedules UIKit work on the main queue, creates a dark test screen with an incrementing counter, and reports the controller to the host.

A return value of `0` means delivery was scheduled. It does not guarantee that the host embedded or displayed the controller.

## Build

Add `guest_adapter.m` to an iOS Dynamic Library target in Xcode, enable ARC, and link UIKit and Foundation. The host callback must be resolvable when the library is loaded. For an app-owned test, configure the host and library together rather than relying on undocumented system behavior.

The GitHub Actions workflow performs an iOS SDK syntax check. It does not package, sign, or install an iOS app.
