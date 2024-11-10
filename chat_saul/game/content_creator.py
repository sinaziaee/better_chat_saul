from dotenv import load_dotenv
load_dotenv()
import os
import streamlit as st
import google.generativeai as genai
from PyPDF2 import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain.vectorstores import FAISS
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains.question_answering import load_qa_chain
from langchain.prompts import PromptTemplate
import requests


genai.configure(api_key=os.getenv('GENAI_API_KEY'))

DJANGO_BACKEND_URL = "http://10.13.104.34:8000"  # Replace with your actual backend URL

# Initialize session states
if 'generated_content' not in st.session_state:
    st.session_state.generated_content = None
if 'form_data' not in st.session_state:
    st.session_state.form_data = None

def get_pdf_text(pdf_docs):
    text = ''
    for pdf in pdf_docs:
        pdf = PdfReader(pdf)
        for page in pdf.pages:
            text += page.extract_text()
    return text

def get_text_chunks(text):
    splitter = RecursiveCharacterTextSplitter(chunk_size=10000, chunk_overlap=1000)
    chunks = splitter.split_text(text)
    return chunks

def get_vector_store(text_chunks):
    embeddings = GoogleGenerativeAIEmbeddings(model='models/embedding-001')
    vector_store = FAISS.from_texts(text_chunks, embedding=embeddings)
    vector_store.save_local('faiss_index')
    return vector_store

def get_conversational_chain():
    prompt_template = """
    You are a helpful content generator. Based on the provided context, you need to generate content in a structured and clear format.  
    Generate exactly 2 learning materials and 2 quizzes based on the provided context. Each learning material must have a title and detailed content.
    Each quiz must have a question, four options (labeled Option 1 to Option 4), the correct answer, and the number of points.

    Use the following strict format to ensure clarity:

    # Learning Material 1
    Title: <Title>
    Content: <Detailed Content>

    # Learning Material 2
    Title: <Title>
    Content: <Detailed Content>

    # Quiz 1
    Question: <Question>
    Option 1: <Option 1>
    Option 2: <Option 2>
    Option 3: <Option 3>
    Option 4: <Option 4>
    Answer: <Correct Option>
    Points: <Points>

    # Quiz 2
    Question: <Question>
    Option 1: <Option 1>
    Option 2: <Option 2>
    Option 3: <Option 3>
    Option 4: <Option 4>
    Answer: <Correct Option>
    Points: <Points>

    Context: {context}
    Question: Generate comprehensive learning materials and quizzes based on the provided content.

    Answer:
    """
    model = ChatGoogleGenerativeAI(model="gemini-pro", temperature=0.3)
    prompt = PromptTemplate(template=prompt_template, input_variables=["context", "question"])
    chain = load_qa_chain(model, chain_type="stuff", prompt=prompt)
    return chain

def parse_generated_content(content):
    sections = content.split('#')[1:]  # Split by # and remove empty first element
    parsed = {
        'learning_materials': [],
        'quizzes': []
    }
    
    for section in sections:
        if 'Learning Material' in section:
            lines = section.strip().split('\n')
            title_line = next(line for line in lines if 'Title:' in line)
            title = title_line.replace('Title:', '').strip()
            
            content_start = next(i for i, line in enumerate(lines) if 'Content:' in line)
            content_lines = []
            for line in lines[content_start + 1:]:
                if line.strip() and not line.startswith('Title:'):
                    content_lines.append(line.strip())
            
            material = {
                'title': title,
                'content': '\n'.join(content_lines)
            }
            parsed['learning_materials'].append(material)
        elif 'Quiz' in section:
            lines = [line.strip() for line in section.strip().split('\n') if line.strip()]
            quiz = {
                'question': next(line.replace('Question:', '').strip() for line in lines if 'Question:' in line),
                'option1': next(line.replace('Option 1:', '').strip() for line in lines if 'Option 1:' in line),
                'option2': next(line.replace('Option 2:', '').strip() for line in lines if 'Option 2:' in line),
                'option3': next(line.replace('Option 3:', '').strip() for line in lines if 'Option 3:' in line),
                'option4': next(line.replace('Option 4:', '').strip() for line in lines if 'Option 4:' in line),
                'answer': next(line.replace('Answer:', '').strip() for line in lines if 'Answer:' in line),
                'points': next(line.replace('Points:', '').strip() for line in lines if 'Points:' in line)
            }
            parsed['quizzes'].append(quiz)
    
    return parsed

def generate_content():
    embeddings = GoogleGenerativeAIEmbeddings(model='models/embedding-001')
    new_db = FAISS.load_local('faiss_index', embeddings, allow_dangerous_deserialization=True)
    docs = new_db.similarity_search("Generate learning materials")
    
    chain = get_conversational_chain()
    
    response = chain(
        {"input_documents": docs, "question": "Generate learning materials"}
        , return_only_outputs=True
    )
    
    return parse_generated_content(response["output_text"])

def collect_form_data():
    """Collect all form data into a dictionary"""
    form_data = {
        'learning_materials': [],
        'quizzes': []
    }
    
    # Collect learning materials
    for i in range(1, 3):  # For 2 learning materials
        material = {
            'title': st.session_state[f"title_{i}"],
            'content': st.session_state[f"content_{i}"]
        }
        form_data['learning_materials'].append(material)
    
    # Collect quizzes
    for i in range(1, 3):  # For 2 quizzes
        quiz = {
            'question': st.session_state[f"question_{i}"],
            'option1': st.session_state[f"quiz_{i}_option_1"],
            'option2': st.session_state[f"quiz_{i}_option_2"],
            'option3': st.session_state[f"quiz_{i}_option_3"],
            'option4': st.session_state[f"quiz_{i}_option_4"],
            'answer': st.session_state[f"answer_{i}"],
            'points': st.session_state[f"points_{i}"]
        }
        form_data['quizzes'].append(quiz)
    
    return form_data

def send_to_django(form_data, category_id):
    """Send the form data to Django backend"""
    try:
        # Add category_id to the form data
        data = {**form_data, 'category_id': category_id}
        
        # Send POST request to Django
        response = requests.post(
            f"{DJANGO_BACKEND_URL}/api/game/contents/create-content/",
            json=data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            return True, "Content saved successfully to database!"
        else:
            return False, f"Error: {response.json().get('message', 'Unknown error')}"
            
    except Exception as e:
        return False, f"Error connecting to backend: {str(e)}"

def display_interactive_content(content):
    # Display Learning Materials
    for i, material in enumerate(content['learning_materials'], 1):
        st.subheader(f"Learning Material {i}")
        st.text_input(f"Title {i}", value=material['title'], key=f"title_{i}")
        st.text_area(f"Content {i}", value=material['content'], height=200, key=f"content_{i}")
        st.markdown("---")

    # Display Quizzes
    for i, quiz in enumerate(content['quizzes'], 1):
        categories = get_categories()  # You'll need to implement this to fetch categories from Django
        # Add unique key for each quiz's category selectbox
        category_id = st.selectbox(
            "Select Category",
            options=[(cat['id'], cat['name']) for cat in categories],
            format_func=lambda x: x[1],
            key=f"category_select_{i}"  # Add unique key here
        )[0]
        
        st.subheader(f"Quiz {i}")
        st.text_input(f"Question {i}", value=quiz['question'], key=f"question_{i}")
        
        # Display options using individual keys
        st.text_input(f"Option 1 for Quiz {i}", value=quiz['option1'], key=f"quiz_{i}_option_1")
        st.text_input(f"Option 2 for Quiz {i}", value=quiz['option2'], key=f"quiz_{i}_option_2")
        st.text_input(f"Option 3 for Quiz {i}", value=quiz['option3'], key=f"quiz_{i}_option_3")
        st.text_input(f"Option 4 for Quiz {i}", value=quiz['option4'], key=f"quiz_{i}_option_4")
        
        st.text_input(f"Correct Answer for Quiz {i}", value=quiz['answer'], key=f"answer_{i}")
        
        points_key = f"points_{i}"
        if points_key not in st.session_state:
            st.session_state[points_key] = int(quiz['points'])
            
        st.number_input(
            f"Points for Quiz {i}", 
            min_value=0,
            value=st.session_state[points_key],
            key=points_key
        )
        st.markdown("---")
    
    # Add submit button
    # if st.button("Submit Changes"):
    #     st.session_state.form_data = collect_form_data()
    #     st.success("Changes saved successfully!")
    #     st.write("Saved data:", st.session_state.form_data)

    if st.button("Submit Changes"):
        form_data = collect_form_data()
        success, message = send_to_django(form_data, category_id)
        
        if success:
            st.success(message)
            st.session_state.form_data = form_data  # Store in session state
        else:
            st.error(message)

def main():
    st.set_page_config("Learning Materials Generator")
    st.header("Content Creator 📚")

    with st.sidebar:
        st.title("Menu:")
        pdf_docs = st.file_uploader("Upload your PDF Files and Click on the Submit & Process Button", accept_multiple_files=True)
        if st.button("Submit & Process"):
            # get_categories()
            with st.spinner("Processing..."):
                raw_text = get_pdf_text(pdf_docs)
                text_chunks = get_text_chunks(raw_text)
                get_vector_store(text_chunks)
                st.success("Done")

    if st.button("Generate Content"):
        with st.spinner("Generating learning materials..."):
            st.session_state.generated_content = generate_content()
            st.session_state.form_data = None  # Reset form data when generating new content

    # Display content if it exists in session state
    if st.session_state.generated_content is not None:
        display_interactive_content(st.session_state.generated_content)

def get_categories():
    """Fetch categories from Django backend"""
    try:
        print("======================================================")
        print(f"{DJANGO_BACKEND_URL}/api/game/categories/")
        print("======================================================")
        response = requests.get(f"{DJANGO_BACKEND_URL}/api/game/categories/")
        if response.status_code == 200:
            print(response.json())
            return response.json()
        return []
    except Exception:
        st.error("Could not fetch categories from backend")
        return []

if __name__ == "__main__":
    main()

