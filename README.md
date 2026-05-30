# GIF Touchbar Pock Widget

A custom [Pock](https://github.com/pock/pock) widget designed to display and animate GIFs directly in your MacBook Touch Bar. 

## Features & Implementation
* **GPU-Accelerated**: Implemented using Core Animation (`CABasicAnimation`) on layer-backed views, keeping CPU overhead at virtual **0%** to preserve battery life.
* **Dynamic Sizing**: Uses Auto Layout matching Pock's framework requirements to stretch and fill all available remaining space in your Touch Bar.
* **Auto-Clipping**: Employs subview clipping (`masksToBounds`) to ensure the animation never overflows or overlaps neighboring Touch Bar widgets.
* **Lifecycle Aware**: Automatically starts the animation when the widget appears (`viewDidAppear()`) and pauses/stops it when hidden (`viewWillDisappear()`) to prevent resource drain.

---

## Inspiration & References
This widget was built as an improvement on traditional Touch Bar widgets and was inspired by:
* **[Pock](https://github.com/pock/pock)**: The open-source framework managing custom Touch Bar widgets.
* **[Status Widget](https://github.com/pock/status-widget)**: Followed for target setup, lifecycle practices, and customization architecture.
* **[Nyan Cat Touch Bar App](https://github.com/avatsaev/touchbar_nyancat)**: The original standalone Nyan Cat animation utility by Aslan Vatsaev.

---

## Current Status & Roadmap
* **Current State**: Displays the classic Nyan Cat GIF traversing the Touch Bar. No user-configuration UI is available yet.
* **Roadmap**:
  * [ ] Add a Preference Pane to allow selecting any custom GIF.
  * [ ] Support setting custom animation durations and speeds.
  * [ ] Allow turning translation on/off (looping the GIF in a static position).

---

## How to Build & Run
1. Run `pod install` if dependencies are modified.
2. Open `HelloWorld.xcworkspace` in Xcode.
3. Build the project. The build scheme contains a post-build action that compiles the widget bundle (`.pock`) and prompts Pock to install/reload it automatically.
