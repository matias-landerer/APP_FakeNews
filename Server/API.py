import parametros
from groq import Groq

client = Groq(api_key=parametros.APIPASS)

def verificar_titular(titular: str) -> dict:
    try:
        chat_completion = client.chat.completions.create(
            messages=[
                {"role": "user", "content": f"¿Es real esta noticia? Dame un procentaje de cuan real es, una muy breve descripcion de porque conluyes eso, y una lista de link con las fuentes que usaste. Separa cada una de estas cosas (porcentaje, descripción, links) con un ';': {titular}"}
            ],
            model="llama-3.3-70b-versatile",
        )
        resultado = chat_completion.choices[0].message.content.split(';')
        score = resultado[0]
        label = resultado[1]
        fuentes = resultado[2].split(',')

        return {"score": score, "label": label, "fuentes": fuentes}
    except Exception as error:
        print(error)

if __name__ == '__main__':
    titular = input('Ingrese el titular: ')
    resultado = verificar_titular(titular)
    print(f"La noticia es {resultado["score"]} real")
    print()
    print(resultado["label"])
    print("\nFuentes:")
    for fuente in resultado["fuentes"]:
        print(fuente)
