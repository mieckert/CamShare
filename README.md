#  CamShare - share live stream from a document camera as browser tab

CamShare is a small MacOS app to allow you to display the video feed from a camera --mainly a document camera-- 
in a browser tab, the intention being that this browser tab can then be shared during a video conference via 
the video conference tool's browser tab or screen sharing functionality.  (Google Meet in particular will perform
better when videos are shared as browser tab rather than via window or full screen sharing.)

The main features of CamShare are:
* Share video from your (document) camera via a browser tab for video conference tools like Google Meet
  that do not have a built-in functionality for this.  (Zoom, e.g., has a built-in sharing functionality
  for document cameras)
* Allows you to set and lock focus and exposure, so that the camera does not try to refocus and realign exposure
  when, e.g., your hand is in the image writing things on a piece of paper or whiteboard.
* Can run in the background as a menu bar item, so that it is quickly accessible during a video conference

## Roadmap / TODOs
- [ ] replace `sleep()` with a more proper waiting mechanism that does not block the UI in `focus()`,
      `exposure()` and `focusAndExposure()`
- [ ] display hotkeys in menu bar
- [ ] make default camera configurable or save it into a plist etc.
- [ ] look closer at usage of `@ObservedObject` vs. using a `@StateObject` for the `SettingsManager`
- [ ] look at sandboxing and signing (incl. opening of network socket)
- [ ] look at other picture quality factors that cannot be easily set through the `AVCaptureDevice` API,
      see the great [CameraController](https://github.com/Itaybre/CameraController) App for reference
 
## Dependencies / used packages
- [swifter](https://github.com/httpswift/swifter), version 1.5.0
- [HotKey](https://github.com/soffes/HotKey), version 0.2.0 (4d02d80)
