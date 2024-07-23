# LabelAssistant - Package Label Scanner and Email Generator

## Overview

LabelAssistant is a Python application that uses your computer's camera to scan package labels, extract information using OCR (Optical Character Recognition), and automatically generate emails to notify recipients about their arrived packages. This application is designed to streamline the process of managing incoming packages in an office or mail room setting.

## Features

- Live camera feed for capturing package labels
- Image cropping functionality for precise label scanning
- OCR integration to extract information from package labels
- Automatic email content generation using Google's Generative AI
- User-friendly interface for editing and sending notification emails
- Integration with a local directory to match recipient names with email addresses
- Custom application icon for easy identification

## Prerequisites

Before installing LabelAssistant, ensure you have the following:

1. Windows operating system
2. Administrative privileges on your computer
3. Internet connection
4. A webcam or connected camera device

## Installation

1. Download the `install.bat` script from the project repository.
2. Right-click on `install.bat` and select "Run as administrator".
3. Follow the prompts to complete the installation process.

The installation script will set up the following components:
- Python 3 (latest version)
- Git
- Required Python packages (customtkinter, opencv-python-headless, pillow, google-generativeai, pytesseract)
- Tesseract OCR
- A desktop shortcut with a custom icon

## Configuration

Before running the application, you need to set up a few things:

1. Google API Key:
   - Obtain a Google API key for the Generative AI service.
   - Replace the placeholder API key in `main.py`:
     ```python
     GOOGLE_API_KEY = 'YOUR_GOOGLE_API_KEY_HERE'
     ```

2. Directory JSON:
   - Create a `directory.json` file in the same directory as `main.py`.
   - Populate it with recipient names and their corresponding email addresses:
     ```json
     {
       "John Doe": "john.doe@example.com",
       "Jane Smith": "jane.smith@example.com"
     }
     ```

3. Tesseract OCR:
   - The installation script should have set up Tesseract OCR.
   - If you encounter issues, ensure that the Tesseract executable is in your system PATH.

4. Changing the .jpg Directory:
   - The application image directory is empty and will need to be updated to the project directory.
   - To change this, locate the following line in `main.py`:
     ```python
     @staticmethod
     def get_most_recent_jpg_image_path():
        directory = "DIRECTORY_PATH"
     ```
   - Replace 'DIRECTORY_PATH' with your desired directory path.

5. Custom Icon:
   - The application uses a custom icon for the desktop shortcut.
   - If you want to change the icon, replace the `app_icon.ico` file in the project root directory with your desired icon file (must be in .ico format).

## Usage

1. Double-click the 'LabelAssistant' shortcut on your desktop to start the application.

2. Using the application:
   - The main window will show a live feed from your camera.
   - Position the package label in view of the camera.
   - Click "Capture and Crop" to take a picture and crop the label area.
   - Use your mouse to draw a rectangle around the label information.
   - Click "Confirm Crop" to process the image.

3. Editing the email:
   - The application will automatically generate an email based on the scanned label.
   - You can edit the Subject, Recipient, and Body fields as needed.
   - Click "Accept" to open your default email client with the generated email.

4. Sending the email:
   - Your default email client will open with the pre-filled email.
   - Review the email and make any final adjustments.
   - Send the email to notify the recipient about their package.

## Troubleshooting

- If the camera feed doesn't appear, ensure your webcam is properly connected and not in use by another application.
- If OCR results are poor, try adjusting the lighting or camera focus for a clearer image of the label.
- If email addresses are not found, check that the recipient's name in the `directory.json` file matches exactly with the name extracted from the label.
- If the application fails to start, ensure that all dependencies are correctly installed and that the virtual environment is activated.

## Customization

- To modify the email template, locate the `ocr()` method in `main.py` and adjust the `user_input` string.
- To change the application's appearance, modify the CTk theme and widget styles in the `LabelAssistant` class.

## Support

For issues, feature requests, or contributions, please open an issue on the project's GitHub repository: https://github.com/gmwilson34/Label-Assistant.git

## License

MIT License

Copyright (c) 2024 Graham Wilson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
