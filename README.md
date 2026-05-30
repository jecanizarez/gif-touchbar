# GIF Touchbar Pock Widget

A custom [Pock](https://github.com/pock/pock) widget designed to display and animate custom GIFs directly in your MacBook Touch Bar.

## Features & Implementation
* **Custom GIF Support**: Load any custom `.gif` file from your disk. The widget securely copies files to local Application Support (`~/Library/Application Support/com.HelloWorld.HelloWorld/custom.gif`) to ensure they load reliably.
* **Static Loop Mode**: Toggle "Static Mode" to play the GIF centered in a fixed position without horizontal movement.
* **Custom Min Width**: Enforce a minimum width (in points) for custom GIFs. Narrow GIFs are scaled up dynamically (via independent axis scaling) to ensure they remain clearly visible on the Touch Bar.
* **Animation & Movement Customization**:
  * **Duration**: Control the animation traversal speed (seconds).
  * **Autoreverse**: Option to walk the GIF back and forth across the Touch Bar.
  * **Translation Range**: Configure custom start (`From Translation X`) and end (`To Translation X`) coordinates.
* **Programmatic Preference Pane**: A robust, programmatic AppKit Auto Layout UI panel that loads in Pock's native widget settings—no fragile XIB files or resource compilation requirements.
* **GPU-Accelerated**: Implemented using Core Animation (`CABasicAnimation`) on layer-backed views, keeping CPU overhead at virtual **0%** to preserve battery life.
* **Dynamic Sizing & Clipping**: Auto Layout integration allows the widget to stretch and fill empty space on the Touch Bar while enforcing subview clipping (`masksToBounds`) to prevent overflow onto neighboring widgets.
* **Lifecycle Aware & Real-time Reloading**: Automatically starts animations when visible, stops them when hidden to preserve resources, and reloads instantly when preferences are updated.
* **Drag-and-Drop Integration**: Customization previews dynamically load the selected GIF, allowing you to easily drag and position the widget inside Pock's customization palette.

---

## Inspiration & References
This widget was built as an improvement on traditional Touch Bar widgets and was inspired by:
* **[Pock](https://github.com/pock/pock)**: The open-source framework managing custom Touch Bar widgets.
* **[Status Widget](https://github.com/pock/status-widget)**: Followed for target setup, lifecycle practices, and customization architecture.
* **[Nyan Cat Touch Bar App](https://github.com/avatsaev/touchbar_nyancat)**: The original standalone Nyan Cat animation utility by Aslan Vatsaev.

---

## How to Build & Run
1. Run `pod install` if dependencies are modified.
2. Open `HelloWorld.xcworkspace` in Xcode.
3. Build the project. The build scheme contains a post-build action that compiles the widget bundle (`.pock`) and prompts Pock to install/reload it automatically.
