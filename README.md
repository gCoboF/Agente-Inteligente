# 🤖 Agente Inteligente RAG com FastAPI e Gemini

Um sistema avançado de perguntas e respostas implementando arquitetura RAG (Retrieval Augmented Generation) com FastAPI, utilizando o modelo Gemini da Google para geração de respostas contextualizadas.

## 📌 Visão Geral

![RAG Architecture](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*5zyLpZ5xQ2NvbFqA5M10Pg.png)  
*(Diagrama conceitual da arquitetura RAG)*

O sistema combina:
- Recuperação de informação vetorial
- Geração contextualizada de respostas
- Gerenciamento de conversação

## 🚀 Funcionalidades Principais

| Funcionalidade | Descrição |
|--------------|-----------|
| 📄 Respostas baseadas em documentos | Consulta a base de conhecimento vetorial antes de gerar respostas |
| 🗣️ Contexto de conversa | Mantém histórico da sessão para respostas contextualizadas |
| 🔢 Gerenciamento de tokens | Monitora uso de tokens para controle de custos |
| ⏱️ Timeout inteligente | Prevenção de longas esperas em consultas complexas |
| 🌐 Suporte CORS | Configuração flexível para integração frontend |

## 🛠️ Stack Tecnológica

- **Backend**: 
  - `FastAPI` (Framework web moderno)
  - `Uvicorn` (ASGI server)
- **IA/ML**: 
  - `Google Gemini` (LLM avançado)
  - `LangChain` (Orquestração de fluxos LLM)
- **Banco de Dados Vetorial**: 
  - `FAISS` (Facebook AI Similarity Search)
- **Embeddings**: 
  - `HuggingFace` (Modelos de embeddings)

## ⚙️ Configuração

### Pré-requisitos
- Python 3.9+
- Conta no Google AI Studio (para chave API Gemini)

### Instalação
```bash
# Instalar dependências
pip install -r requirements.txt

# Ou manualmente:
pip install fastapi uvicorn langchain google-generativeai faiss-cpu python-dotenv
Variáveis de Ambiente
Crie um arquivo .env na raiz do projeto:

ini
Copy
GEMINI_API_KEY=sua_chave_aqui
MAX_TOKENS=1000
TIMEOUT=30
🎚️ Uso da API
Endpoints Disponíveis
Método	Endpoint	Descrição
POST	/generate	Processa consultas e retorna respostas
GET	/health	Verifica status do serviço
Exemplo de Requisição
python
Copy
import requests

url = "http://localhost:8000/generate"
payload = {
    "query": "Explique o conceito de RAG",
    "chat_history": []  # Opcional
}

response = requests.post(url, json=payload)
print(response.json())
Estrutura da Resposta
json
Copy
{
    "response": "Resposta gerada pelo modelo Gemini",
    "metadata": {
        "token_count": 215,
        "processing_time": 1.45,
        "sources": ["doc1.pdf", "doc2.txt"]
    },
    "chat_history": [...]#   A g e n t e - I n t e l i g e n t e  
 