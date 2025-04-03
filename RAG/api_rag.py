from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from modelo_rag import ModeloRAG  # classe 
import logging
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
modelo_rag = ModeloRAG(google_api_key=GOOGLE_API_KEY)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Pergunta(BaseModel):
    query: str

@app.post("/generate")
async def gerar_resposta(pergunta: Pergunta):
    try:
        resposta = await asyncio.wait_for(
            asyncio.to_thread(modelo_rag.gerar_resposta, pergunta.query),
            timeout=30.0
        )
        logger.info(f"Successfully generated response for query: {pergunta.query[:150]}...")
        return {
            "Gemini": resposta["result"],
            "token_count": resposta["token_count"],
            "chat_history": modelo_rag.chat_history,
            "token_countPrompt": resposta["token_countPrompt"] # Adding chat history to response
        }
    except asyncio.TimeoutError:
        logger.error("Request timed out")
        raise HTTPException(status_code=504, detail="Request timed out")
    except Exception as e:
        logger.error(f"Error in API endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}