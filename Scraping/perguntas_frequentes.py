import requests
from bs4 import BeautifulSoup

# URL da página
url = "https://www.ufabc.edu.br/perguntas-frequentes"

# Fazendo a requisição HTTP
response = requests.get(url)

# Verificando se a requisição foi bem-sucedida
if response.status_code == 200:
    # Parseando o conteúdo HTML com BeautifulSoup
    soup = BeautifulSoup(response.content, "html.parser")

    # Encontrando a seção de conteúdo principal
    content_section = soup.find("section", id="content-section")

    # Extraindo todos os textos da seção de conteúdo
    textos = content_section.get_text(separator="\n")

    # Processando o texto para melhorar a formatação
    linhas = textos.splitlines()  # Divide o texto em linhas
    linhas_filtradas = [linha.strip() for linha in linhas if linha.strip()]  # Remove linhas vazias e espaços extras
    texto_formatado = "\n".join(linhas_filtradas)  # Junta as linhas novamente

    # Salvando os textos em um arquivo .txt
    with open("perguntas_frequentes_formatado.txt", "w", encoding="utf-8") as arquivo:
        arquivo.write(texto_formatado)
    print("Textos formatados salvos em 'perguntas_frequentes_formatado.txt'")
else:
    print(f"Erro ao acessar o site. Código de status: {response.status_code}")