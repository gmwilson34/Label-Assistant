import customtkinter as ctk
import cv2
from PIL import Image, ImageTk
import os
from datetime import datetime
import google.generativeai as genai
import pytesseract
import textwrap
import webbrowser
import json

GOOGLE_API_KEY = ''
genai.configure(api_key=GOOGLE_API_KEY)


class CameraApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        # Initialize instance variables
        self.response_label = None
        self.to_label = None
        self.subject_label = None
        self.body = None
        self.recipient = None
        self.subject = None
        self.cap = None
        self.is_running = False
        self.captured_image = None
        self.crop_start = None
        self.crop_end = None
        self.cropping = False
        self.is_capturing = True
        self.cropped_image_path = None
        self.crop_canvas = None
        self.photo = None
        self.display_image = None

        self.title("Label Assistant")
        self.geometry("1920x1080")
        self.configure(fg_color="#1E1E1E")  # Dark background

        # Configure grid layout (3x4)
        self.grid_columnconfigure(0, weight=2)
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=5)
        self.grid_rowconfigure(2, weight=1)
        self.grid_rowconfigure(3, weight=3)

        # Create camera frame
        self.camera_frame = ctk.CTkFrame(self, corner_radius=0, fg_color="transparent")
        self.camera_frame.grid(row=0, column=0, rowspan=3, padx=(20, 0), pady=(20, 10), sticky="nsew")

        # Create a label for the video feed
        self.camera_label = ctk.CTkLabel(self.camera_frame, text="")
        self.camera_label.pack(expand=True, fill="both")

        # Modify the subject frame
        self.subject_frame = ctk.CTkFrame(self, corner_radius=10, fg_color="#2B2B2B")
        self.subject_frame.grid(row=0, column=1, padx=(0, 150), pady=(40, 5), sticky="new")
        self.subject_entry = ctk.CTkEntry(self.subject_frame, placeholder_text="Subject")
        self.subject_entry.pack(pady=5, padx=20, expand=True, fill="both")
        self.subject_entry.bind("<Return>", self.update_subject)

        # Modify the to frame
        self.to_frame = ctk.CTkFrame(self, corner_radius=10, fg_color="#2B2B2B")
        self.to_frame.grid(row=0, column=1, padx=(0, 150), pady=(100, 5), sticky="new")
        self.recipient_entry = ctk.CTkEntry(self.to_frame, placeholder_text="Recipient")
        self.recipient_entry.pack(pady=5, padx=20, expand=True, fill="both")
        self.recipient_entry.bind("<Return>", self.update_recipient)

        # Modify the response frame
        self.response_frame = ctk.CTkFrame(self, corner_radius=10, fg_color="#2B2B2B")
        self.response_frame.grid(row=1, column=1, rowspan=2, padx=(0, 40), pady=(5, 10), sticky="nsew")
        self.body_text = ctk.CTkTextbox(self.response_frame, wrap="word")
        self.body_text.pack(expand=True, fill="both", padx=20, pady=10)
        self.body_text.bind("<KeyRelease>", self.update_body)

        # Create capture button frame
        self.capture_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.capture_frame.grid(row=3, column=0, padx=(20, 10), pady=(0, 80), sticky="ew")

        # Create edit/accept button frame
        self.button_frame = ctk.CTkFrame(self, fg_color="transparent")
        self.button_frame.grid(row=3, column=1, padx=(10, 20), pady=(0, 20), sticky="ew")

        # Add buttons
        button_style = {"fg_color": "#3B7097", "corner_radius": 5, "width": 160, "height": 40}
        edit_button_style = {"fg_color": "#69E281", "corner_radius": 5, "width": 160, "height": 40}
        capture_button_style = {"fg_color": "#777986", "corner_radius": 5, "width": 160, "height": 40}

        self.capture_button = ctk.CTkButton(self.capture_frame, text="Capture and Crop", command=self.capture_and_crop,
                                            **capture_button_style)
        self.capture_button.pack(expand=True)

        self.edit_button = ctk.CTkButton(self.button_frame, text="Edit Preview", command=self.return_to_stream,
                                         **edit_button_style)
        self.edit_button.pack(side="left", padx=10, expand=True)

        self.accept_button = ctk.CTkButton(self.button_frame, text="Accept", command=self.accept_crop, **button_style)
        self.accept_button.pack(side="left", padx=10, expand=True)

        # Configure the button_frame to expand and fill the space, centering its contents
        self.button_frame.grid_columnconfigure(0, weight=1)
        
        self.after(100, self.start_camera)

    # Define a function to get the most recent JPG image path
    @staticmethod
    def get_most_recent_jpg_image_path():
        directory = ""
        # Ensure the directory path ends with a slash
        if not directory.endswith('/'):
            directory += '/'

        # List all files in the directory
        files = os.listdir(directory)

        # Filter out files that are not JPG images
        jpg_files = [file for file in files if file.lower().endswith('.jpg')]

        # Sort the JPG files by modification time in descending order
        jpg_files.sort(key=lambda x: os.path.getmtime(directory + x), reverse=True)

        # Return the full path of the most recently added JPG image
        if jpg_files:
            return directory + jpg_files[0]
        else:
            return None

    # Initialize the OCR engine
    def ocr(self):
        image_path = self.get_most_recent_jpg_image_path()
        #   return OCR_output
        OCR_output = str(pytesseract.image_to_string(image_path))
        user_input = ("""Analyze this OCR output of a received package label: {} Write an email to the recipient (the 
        persons name related to the address 300 FAIR OAKS LANE FRANKFORT KY 40601 is the recipient a company name 
        will not be the recipient. they will have a first and last name only) regarding their received package. 
        Follow this output style exactly:

        Subject: Your Package has Arrived!

        Recipient: FirstName LastName

        Body: Hi FirstName,

            I am happy to inform you that your package from [Shipper Name] at [Shipper Address] has been received and 
            processed. It is ready for pickup at [Recipient Address]. If you have any further questions regarding 
            your package please feel free to reply directly to this email.

        Best regards,

        Chloe Walker""").format(OCR_output)

        # Select Latest Gemini 1.5 Pro Model
        model = genai.GenerativeModel('gemini-1.5-pro-latest')
        # Generate a response using Llama 3
        response = model.generate_content(user_input)
        # Extract the assistant's message
        output = response.text
        assistant_message = '\n'.join(
            ['\n'.join(textwrap.wrap(line, width=50)) for line in output.splitlines()])
        return assistant_message

    def update_subject(self, event):
        self.subject = self.subject_entry.get()

    def update_recipient(self, event):
        self.recipient = self.recipient_entry.get()

    def update_body(self, event):
        self.body = self.body_text.get("1.0", "end-1c")

    def update_label(self):
        ocr_output = self.ocr()
        lines = ocr_output.split('\n')
        self.subject = ""
        self.recipient = ""
        self.body = ""
        capture_body = False
        for line in lines:
            if line.startswith("Subject:"):
                self.subject = line[len("Subject:"):].strip()
            elif line.startswith("Recipient:"):
                self.recipient = line[len("Recipient:"):].strip()
            elif line.startswith("Body:"):
                self.body = line[len("Body:"):].strip() + "\n"
                capture_body = True
            elif capture_body:
                self.body += line + "\n"

        # Update the GUI elements with the extracted information
        self.subject_entry.delete(0, "end")
        self.subject_entry.insert(0, self.subject)
        self.recipient_entry.delete(0, "end")
        self.recipient_entry.insert(0, self.recipient)
        self.body_text.delete("1.0", "end")
        self.body_text.insert("1.0", self.body)

        # Update the GUI elements with the extracted information
        self.subject_label.configure(text="Subject: " + self.subject)
        self.to_label.configure(text="To:" + self.recipient)
        self.response_label.configure(text=self.body)

    def start_camera(self):
        self.cap = cv2.VideoCapture(0)  # 0 is usually the default camera
        self.is_running = True
        self.update_camera()

    def update_camera(self):
        window_width = self.winfo_width()
        subject_width = 500
        available_width = window_width - subject_width
        new_picture_height = int(available_width * 10 / 16)
        new_picture_width = int(available_width)

        if self.is_running and self.is_capturing:
            ret, frame = self.cap.read()
            if ret:
                frame_resized = cv2.resize(frame, (new_picture_width, new_picture_height))
                frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
                image = Image.fromarray(frame_rgb)
                photo = ImageTk.PhotoImage(image=image)
                self.camera_label.configure(image=photo)
                self.camera_label.image = photo

        # Call this method again after a short delay
        self.after(200, self.update_camera)

    def capture_and_crop(self):
        if self.is_capturing:
            ret, frame = self.cap.read()
            if ret:
                self.captured_image = frame
                self.show_cropping_interface()
                self.is_capturing = False
                self.capture_button.configure(text="Confirm Crop")
                self.edit_button.configure(text="Cancel")
        else:
            self.perform_crop()

    def show_cropping_interface(self):
        if self.captured_image is not None:
            self.cropping = True
            window_width = self.winfo_width()
            subject_width = 500
            available_width = window_width - subject_width
            new_picture_height = int(available_width * 10 / 16)
            new_picture_width = int(available_width)

            frame_resized = cv2.resize(self.captured_image, (new_picture_width, new_picture_height))
            frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
            self.display_image = Image.fromarray(frame_rgb)
            self.photo = ImageTk.PhotoImage(self.display_image)

            # Replace the existing label with a canvas
            self.camera_label.destroy()
            self.crop_canvas = ctk.CTkCanvas(self.camera_frame, width=new_picture_width, height=new_picture_height)
            self.crop_canvas.pack(expand=True, fill="both")
            self.crop_canvas.create_image(0, 0, anchor="nw", image=self.photo)

            self.crop_canvas.bind("<ButtonPress-1>", self.start_crop)
            self.crop_canvas.bind("<B1-Motion>", self.draw_crop)
            self.crop_canvas.bind("<ButtonRelease-1>", self.end_crop)

    def start_crop(self, event):
        self.crop_start = (event.x, event.y)

    def draw_crop(self, event):
        if self.crop_start:
            self.crop_canvas.delete("crop_rectangle")
            self.crop_canvas.create_rectangle(self.crop_start[0], self.crop_start[1], event.x, event.y,
                                              outline="red", width=2, tags="crop_rectangle")

    def end_crop(self, event):
        self.crop_end = (event.x, event.y)

    def perform_crop(self):
        if self.crop_start and self.crop_end:
            x1, y1 = min(self.crop_start[0], self.crop_end[0]), min(self.crop_start[1], self.crop_end[1])
            x2, y2 = max(self.crop_start[0], self.crop_end[0]), max(self.crop_start[1], self.crop_end[1])

            window_width = self.winfo_width()
            subject_width = 500
            available_width = window_width - subject_width
            new_picture_height = int(available_width * 10 / 16)
            new_picture_width = int(available_width)

            scale_x = self.captured_image.shape[1] / new_picture_width
            scale_y = self.captured_image.shape[0] / new_picture_height

            x1, y1 = int(x1 * scale_x), int(y1 * scale_y)
            x2, y2 = int(x2 * scale_x), int(y2 * scale_y)

            cropped_image = self.captured_image[y1:y2, x1:x2]
            self.save_cropped_image(cropped_image)
            self.display_cropped_image(cropped_image)

            self.update_label()

    def save_cropped_image(self, image):
        if not os.path.exists('cropped_images'):
            os.makedirs('cropped_images')

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"cropped_image_{timestamp}.jpg"
        self.cropped_image_path = os.path.join('cropped_images', filename)
        cv2.imwrite(self.cropped_image_path, image)

    def display_cropped_image(self, image):
        window_width = self.winfo_width()
        subject_width = 500
        available_width = window_width - subject_width
        new_picture_height = int(available_width * 10 / 16)
        new_picture_width = int(available_width)

        frame_resized = cv2.resize(image, (new_picture_width, new_picture_height))
        frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
        image_pil = Image.fromarray(frame_rgb)
        photo = ImageTk.PhotoImage(image_pil)

        # Remove the canvas and recreate the label
        self.crop_canvas.destroy()
        self.camera_label = ctk.CTkLabel(self.camera_frame, text="")
        self.camera_label.pack(expand=True, fill="both")
        self.camera_label.configure(image=photo)
        self.camera_label.image = photo

        self.cropping = False

    def return_to_stream(self):
        self.is_capturing = True
        self.cropping = False
        self.captured_image = None
        self.crop_start = None
        self.crop_end = None
        self.capture_button.configure(text="Capture and Crop")
        self.edit_button.configure(text="Edit Preview")

        # Remove the canvas if it exists
        if hasattr(self, 'crop_canvas'):
            self.crop_canvas.destroy()

        # Remove the existing camera label if it exists
        if hasattr(self, 'camera_label'):
            self.camera_label.destroy()

        # Recreate the camera label
        self.camera_label = ctk.CTkLabel(self.camera_frame, text="")
        self.camera_label.pack(expand=True, fill="both")

        # Restart the camera feed
        self.update_camera()

    def accept_crop(self):
        if not self.is_capturing and self.cropped_image_path:
            # Delete the cropped image file
            if os.path.exists(self.cropped_image_path):
                os.remove(self.cropped_image_path)

            # Reset the cropped image path
            self.cropped_image_path = None

            # Send email
            self.send_email(self.recipient, self.subject, self.body)

            # Return to the live stream
            self.return_to_stream()

    def stop_camera(self):
        self.is_running = False
        if self.cap is not None:
            self.cap.release()

    def on_closing(self):
        self.stop_camera()
        self.destroy()

    def send_email(self, recipient, subject, body):
        address = self.address_finder(recipient)
        # Construct the mailto link
        mailto_link = f"mailto:{address}?subject={subject}&body={body}"

        # Open the default mail app with the mailto link
        webbrowser.open(mailto_link)

    @staticmethod
    def address_finder(recipient, json_file='directory.json'):
        try:
            # Load the inverted dictionary from the JSON file
            with open(json_file, 'r') as file:
                directory = json.load(file)

            # Convert the directory keys to lowercase for case-insensitive search
            lowercase_directory = {k.lower().strip(): v for k, v in directory.items()}

            # Search for the email address by recipient's name (case-insensitive)
            lowercase_recipient = recipient.lower().strip()
            email_address = lowercase_directory.get(lowercase_recipient, "Email not found")

            return email_address

        except FileNotFoundError:
            print(f"Error: {json_file} not found")
            return "JSON file not found"
        except json.JSONDecodeError:
            print(f"Error: {json_file} is not a valid JSON file")
            return "Invalid JSON file"


if __name__ == "__main__":
    app = CameraApp()
    app.protocol("WM_DELETE_WINDOW", app.on_closing)
    app.mainloop()
