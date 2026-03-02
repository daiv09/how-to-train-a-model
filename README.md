# How To Train A Model 🧠

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017%20|%20iPadOS%2017-blue.svg)
![Framework](https://img.shields.io/badge/Framework-SwiftUI%20|%20CoreML%20|%20CreateML-blueviolet.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**How To Train A Model** is an interactive, on-device machine learning laboratory that demystifies the "black box" of AI. It allows anyone—from students to hobbyists—to capture data, train a deep learning model using the Apple Neural Engine, and test it in Augmented Reality, all without writing a single line of code.



---

## 🚀 What the Project Does

NexusML provides a hands-on, three-step pipeline to transform your physical environment into a custom AI model:

1.  **Collect (Show & Tell):** Use the high-speed camera interface to capture diverse image datasets of objects in your surroundings.
2.  **Study (The Training Phase):** Tweak hyperparameters like **Intensity Rate(Epochs)** and **Learning Style (Learning Rate)**. Watch live accuracy charts as the Neural Engine finds patterns in your data.
3.  **See (Spatial Vision):** Deploy your model instantly in an AR viewfinder. Tap objects to see real-time classification and confidence scores.

---

## ✨ Why This Project is Useful

* **Demystifies AI:** Moves beyond theory by showing the real-world impact of hyperparameter tuning (e.g., how high learning rates cause accuracy "jitter").
* **Privacy-First:** Training and inference happen **100% on-device**. No photos or data ever leave your phone.
* **No-Code Learning:** Ideal for educational environments and workshops where the goal is understanding AI concepts rather than debugging code.
* **Hardware Optimized:** Specifically engineered to utilize the **Apple Neural Engine (ANE)** for high-performance, low-latency deep learning.



---

## 🛠 How to Get Started

### Prerequisites
* Xcode 15.0 or later.
* A physical device running iOS 17.0+ (Required for Neural Engine and Camera features).

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/daiv09/how-to-train-a-model.git
    ```
2.  Ensure your physical device is selected as the run destination.
3.  Build and Run (`Cmd + R`).

### Usage Example: Training your first model
1.  **Add Categories:** Create two labels (e.g., "Mug" and "Remote").
2.  **Capture:** Hold the capture button to record ~15 images of each object from multiple angles.
3.  **Configure:** Navigate to the Training screen and select **Intensity Rate** and **Learning Style **.
4.  **Train:** Tap **Start Training** and watch the accuracy climb.
5.  **Test:** Tap **Test in AR** to pinpoint your objects!



---

## 🆘 Where to Get Help

* **Documentation:** For a deeper dive into the technical implementation, see [docs/TECHNICAL.md](docs/TECHNICAL.md).
* **Issue Tracker:** Report bugs or request features via the [GitHub Issues](https://github.com/daiv09/how-to-train-a-model/issues) page.
* **Swift Challenge:** This project was developed by **Daiwiik Harihar** for the Apple Swift Student Challenge 2026.

---

## 👥 Contributors & Maintenance

* **Maintainer:** Daiwiik Harihar ([@daiv09](https://github.com/daiv09))
* **Contributions:** Contributions are what make the open-source community an amazing place to learn and create. Please refer to [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to participate.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
