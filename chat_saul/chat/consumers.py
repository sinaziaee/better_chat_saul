# consumers.py

import json
import os
from asgiref.sync import sync_to_async
import google.generativeai as genai
from dotenv import load_dotenv
from channels.generic.websocket import AsyncWebsocketConsumer
from .models import ChatMessage, ChatSession, ChatFile  # Import ChatFile
import PyPDF2

# Load environment variables and configure Gemini
load_dotenv()
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

# Set up the configuration for the Gemini model
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model_vision_dict = {
    True: "gemini-1.5-pro",
    False: "gemini-1.5-flash",
}

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.session_id = self.scope['url_route']['kwargs'].get('session_id')
        self.chat_session = await self.get_or_create_session(self.session_id)

        # Initialize chat history and file-based context
        self.history = await self.load_history()
        self.file_context = await self.load_file_context()

        await self.accept()
        await self.send(text_data=json.dumps({
            'role': "model",
            'message': "Connected to chat with Gemini! You can upload documents or images and ask questions."
        }))

        # Send past messages and file-based context back to the user
        for entry in self.history + self.file_context:
            role = "user" if entry["role"] == "user" else "model"
            await self.send(text_data=json.dumps({
                'role': role,
                'message': f"{entry['parts'][0]}"
            }))

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        """
        Handles incoming messages and file-related actions from the WebSocket.
        """
        data = json.loads(text_data)
        print('received data:', data)
        if 'file_id' in data:
            file_id = data['file_id']
            file_type = data.get('file_type', 'unknown')
            gemini_response = await self.process_file(file_id, file_type)
            await self.send(text_data=json.dumps({
                'role': "model",
                'message': f"{gemini_response}"
            }))
        elif 'message' in data:
            is_vision_model = data.get('is_vision_model', False)
            user_message = data['message']
            await self.save_message(sender='user', text=data['message'])
            context = self.history + self.file_context
            model_response = await self.get_gemini_response(user_message, context, model_vision_dict[is_vision_model])
            self.history.append({"role": "model", "parts": [model_response]})
            await self.save_message(sender='model', text=model_response)
            await self.send(text_data=json.dumps({
                'role': "model",
                'message': f"{model_response}"
            }))

    @sync_to_async
    def get_or_create_session(self, session_id):
        return ChatSession.objects.get_or_create(id=session_id)[0]

    @sync_to_async
    def save_message(self, sender, text):
        ChatMessage.objects.create(chat_session=self.chat_session, sender=sender, text=text)

    @sync_to_async
    def load_history(self):
        messages = ChatMessage.objects.filter(chat_session=self.chat_session, sender__in=["user", "model"]).order_by('timestamp')
        history = []
        for msg in messages:
            role = "user" if msg.sender == "user" else "model"
            history.append({"role": role, "parts": [msg.text]})
        return history

    @sync_to_async
    def load_file_context(self):
        """
        Load previously processed files' content for this session.
        """
        files = ChatFile.objects.filter(chat_session=self.chat_session)
        context = []
        for chat_file in files:
            if chat_file.content:
                context.append({"role": "model", "parts": [f"[FILE_CONTEXT] {chat_file.content}"]})
        return context

    async def file_uploaded(self, event):
        """
        Handler for the 'file_uploaded' event sent from the UploadFileView.
        """
        file_id = event['file_id']
        file_type = event.get('file_type', 'unknown')

        gemini_response = await self.process_file(file_id, file_type)
        await self.send(text_data=json.dumps({
            'role': "model",
            'message': f"{gemini_response}"
        }))

    async def process_file(self, file_id, file_type):
        try:
            # Get the ChatFile object
            chat_file = await self.get_chat_file(file_id)

            # Get the file path
            file_path = chat_file.file.path

            if file_type == "document":
                # content = await self.extract_text_from_document(file_path)
                content = self.extract_text_from_document(file_path)
                summary_content = self.generate_summary_of_document_with_gemini(content)
                print(summary_content)
                # Save the content into the ChatFile object
                await self.save_file_content(chat_file, content)
                # Update file context
                self.file_context.append({"role": "model", "parts": [f"[FILE_CONTEXT] {content}"]})
                await self.save_message(sender='model', text=f"[FILE_CONTEXT] {content}")
                # return f"Document uploaded and processed successfully."
                return summary_content
            elif file_type == "image":
                print('Processing image...')
                # description = await self.describe_image(file_path)
                description = self.describe_image(file_path)
                # Save the description into the ChatFile object
                await self.save_file_content(chat_file, description)
                self.file_context.append({"role": "model", "parts": [f"[FILE_CONTEXT] {description}"]})
                await self.save_message(sender='model', text=f"[FILE_CONTEXT] {description}")
                return description
                # return f"Image uploaded and processed successfully."
            else:
                return f"Unsupported file type: {file_type}"
        except Exception as e:
            return f"Error processing file: {str(e)}"
        
    def generate_summary_of_document_with_gemini(self, content):
        try:
            # Map context to the expected schema
            chat_history = [
                {"role": "user", "parts": [content]}
            ]

            # Start a Gemini chat session with the updated history
            chat_session = genai.GenerativeModel(
                model_name=model_vision_dict[False],
                generation_config=generation_config,
            ).start_chat(history=chat_history)

            # Get Gemini's response
            response = chat_session.send_message("Summarize the document.")
            return response.text

        except Exception as e:
            return f"Error getting Gemini response: {str(e)}"

    @sync_to_async
    def get_chat_file(self, file_id):
        return ChatFile.objects.get(id=file_id)

    @sync_to_async
    def save_file_content(self, chat_file, content):
        chat_file.content = content
        chat_file.save()

    # async def extract_text_from_document(self, file_path):
    def extract_text_from_document(self, file_path):
        """
        Extract text content from a document (e.g., PDF or plain text).
        """
        try:
            if file_path.endswith(".txt"):
                with open(file_path, "r") as file:
                    return file.read()
            elif file_path.endswith(".pdf"):
                with open(file_path, "rb") as file:
                    reader = PyPDF2.PdfReader(file)
                    return " ".join(page.extract_text() for page in reader.pages)
            else:
                return "Unsupported document format."
        except Exception as e:
            return f"Error processing document: {str(e)}"


    # async def describe_image(self, file_path):
    def describe_image(self, file_path):
        """
        Generate a description for an uploaded image using Gemini.
        """
        try:
            # Read the image file in binary format
            with open(file_path, "rb") as file:
                image_data = file.read()

            # Check if Gemini expects base64-encoded data
            import base64
            encoded_image = base64.b64encode(image_data).decode('utf-8')

            # Use Gemini's API to describe the image
            chat_session = genai.GenerativeModel(
                model_name=model_vision_dict[True],
                generation_config=generation_config,
            ).start_chat(history=[])

            # If Gemini uses a specific prompt for image descriptions
            prompt = "Describe the content of the following image:"
            response = chat_session.send_message(
                prompt + f" [IMAGE_DATA]: {encoded_image}"  # Append encoded image to the prompt if needed
            )
            print('response:', response.text)
            return response.text

        except Exception as e:
            print('error:', e)
            return f"Error processing image with Gemini: {str(e)}"



    async def get_gemini_response(self, user_message, context, model_name):
        try:
            # Map context to the expected schema
            chat_history = [
                {"role": entry.get("role"), "parts": [entry.get("parts")[0]]}
                for entry in context
            ]

            # Add the current user message to the chat history
            chat_history.append({"role": "user", "parts": [user_message]})

            # Start a Gemini chat session with the updated history
            chat_session = genai.GenerativeModel(
                model_name=model_name,
                generation_config=generation_config,
            ).start_chat(history=chat_history)

            # Get Gemini's response
            response = chat_session.send_message(user_message)
            return response.text

        except Exception as e:
            return f"Error getting Gemini response: {str(e)}"
