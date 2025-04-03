import google.generativeai as genai
from langchain_community.document_loaders import DirectoryLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_google_genai import ChatGoogleGenerativeAI
# from langchain.chains import RetrievalQA
from langchain.chains import ConversationalRetrievalChain 

class ModeloRAG:
    def __init__(self, google_api_key: str, documentos_path: str = "Documentos"):

        genai.configure(api_key=google_api_key)
        self.google_api_key = google_api_key

        # 1. Carregar documentos
        loader = DirectoryLoader(documentos_path, glob="*.txt")
        documents = loader.load()

        # 2. Dividir documentos em chunks
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
        self.texts = text_splitter.split_documents(documents)

        # 3. Criar embeddings e banco de dados vetorial
        embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
        self.vectorstore = FAISS.from_documents(self.texts, embeddings)

        # 4. 
        # para o rag 
        self.llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", google_api_key=google_api_key, max_output_tokens=500) 
        # para contar tokens
        self.model = genai.GenerativeModel('gemini-1.5-flash', generation_config=genai.GenerationConfig(max_output_tokens=150))

        # 5. Criar a cadeia RAG
        self.qa_chain = ConversationalRetrievalChain.from_llm(
            llm=self.llm,
            retriever=self.vectorstore.as_retriever(),
            return_source_documents = True
        )
        self.chat_history = [] 

    def gerar_resposta(self, pergunta: str) -> dict:
        pergunta_Prompt = f"Você é um assistente virtual da UFABC especializado em responder perguntas para alunos com base em documentos fornecidos. Seja claro, conciso e utilize o contexto fornecido para responder às perguntas. Se não souber, apenas diga que não tem informações suficientes.\n\nVocê deve responder a seguinte pergunta: {pergunta}"

        token_count = self.model.count_tokens(pergunta).total_tokens
        token_countPrompt = self.model.count_tokens(pergunta_Prompt).total_tokens
        
        if token_count > 50:
            return {
                "result": "A pergunta é muito longa. Digite uma pergunta mais curta.",
                "token_count": token_count,
                "token_countPrompt": token_countPrompt  # Added here
            }

        try:
            resposta = self.qa_chain({
                "question": pergunta_Prompt, 
                "chat_history": self.chat_history if self.chat_history else []
            })
            
            if 'answer' in resposta:
                self.chat_history.append((pergunta, resposta['answer']))
                return {
                    "result": resposta['answer'],
                    "token_count": token_count,
                    "token_countPrompt": token_countPrompt
                }
            else:
                return {
                    "result": "Desculpe, não consegui processar sua pergunta. Pode tentar reformular?",
                    "token_count": token_count,
                    "token_countPrompt": token_countPrompt  # Added here
                }
                
        except Exception as e:
            logger.error(f"Error in gerar_resposta: {str(e)}")
            return {
                "result": f"Desculpe, ocorreu um erro ao processar sua pergunta. Tente novamente.",
                "token_count": token_count,
                "token_countPrompt": token_countPrompt  # Added here
            }