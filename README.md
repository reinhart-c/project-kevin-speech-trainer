# Kevin

A public speaking trainer app that helps you improve your fluency and tone when reading a transcript aloud. It evaluates your speech based on how closely your spoken words align with the provided transcript and gives feedback on your emotional tone using a machine learning model.


## Features

- **Speech Fluency Analysis**  
  Records your speech and compares it to a transcript, highlighting:
  - **Missed words** (words in the transcript that weren’t spoken)
  - **Extra words** (words you said that weren’t in the transcript)

- **Tone/Emotion Detection**  
  Uses a custom-trained `mlmodel` to detect the emotional tone of your **voice**.

- **Video Recording**  
  Captures a video of you speaking for personal review, but only the **audio** is analyzed.


## Tech Stack

- **Language & Frameworks**: Swift, SwiftUI, Combine
- **Audio/Video**: AVFoundation, AVKit, Speech
- **Machine Learning**: CoreML (with `mlmodel` created using CreateML)
- **Persistence**: SwiftData
- **Linting**: SwiftLint

> **Note:** The CreateML training project is not included, only the `.mlmodel` file is used.


## Linting

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions.


## Contributors

| Name | Role |
|------|------|
| [Vincent W](https://github.com/Incentt)| Product Manager |
| [Reinhart C](https://github.com/reinhart-c) | Tech Lead, ML Engineer |
| [T Fazariz B](https://github.com/Teukufazariz) | UI Engineer |
| [Alifa R](https://github.com/alifarpl) | Feature Engineer |
| [Reymunda A](https://github.com/reymunda) | UI/UX Designer |
| [Theodora S](https://github.com/Lufiera) | UI/UX Designer |


## Acknowledgments

- Datasets used: [SAVEE](http://kahlan.eps.surrey.ac.uk/savee/) and [TESS](https://tspace.library.utoronto.ca/handle/1807/24487)
