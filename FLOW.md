# Regenerating screenshots and demo recordings

## Screenshots (iPhone)

```sh
xcrun simctl boot "iPhone 17 Pro"
flutter pub get
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d "iPhone 17 Pro" --dart-define=DEMO_AUTOPLAY=true
```

`integration_test/screenshot_test.dart` walks the whole journey (sign in, trial, parental gate, profiles, learn path, Watch, Play, Talk, lesson complete, episodes, stickers, parent area, settings, mic consent, first-run profile) and calls `binding.takeScreenshot('NN-name')` on each screen. `test_driver/integration_test.dart` receives each PNG through `integrationDriver(onScreenshot:)` and writes it to `screenshots/`.

Screens with always-on animation (the glowing path node, the Flame game, confetti) never settle, so the test advances time with fixed `pump(Duration)` loops instead of `pumpAndSettle`. `DEMO_AUTOPLAY=true` makes the Catch basket steer itself and speeds up the Watch clip clock.

## Screenshot (iPad)

```sh
xcrun simctl boot "iPad Pro 11-inch (M5)"
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/tablet_screenshot_test.dart \
  -d "iPad Pro 11-inch (M5)" --dart-define=DEMO_AUTOPLAY=true
```

## Demo GIFs

`integration_test/demo_test.dart` is a shorter walkthrough with no screenshots.

iOS:

```sh
xcrun simctl io "iPhone 17 Pro" recordVideo --codec h264 --force ios-demo.mp4 &
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/demo_test.dart -d "iPhone 17 Pro" --dart-define=DEMO_AUTOPLAY=true
pkill -INT -f recordVideo
```

Android (emulator):

```sh
adb shell screenrecord --time-limit 170 --size 540x1200 /sdcard/ademo.mp4 &
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/demo_test.dart -d emulator-5554 --dart-define=DEMO_AUTOPLAY=true
# wait for the time limit so screenrecord finalizes the file, then:
adb pull /sdcard/ademo.mp4
```

Convert each recording (trim the launch, speed up 1.9x, 10 fps, 300 px):

```sh
F="setpts=PTS/1.9,fps=10,scale=300:-1:flags=lanczos"
ffmpeg -ss <start> -i in.mp4 -vf "${F},palettegen=max_colors=128:stats_mode=diff" pal.png
ffmpeg -ss <start> -i in.mp4 -i pal.png \
  -lavfi "${F}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" screenshots/demo.gif
```
