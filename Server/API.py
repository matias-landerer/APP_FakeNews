import parametros
from google import genai
from google.genai import types

client = genai.Client(api_key=parametros.GEMINI_API_KEY)

# Modelo recomendado para el free tier con grounding.
# Si quieres cambiarlo, edita esta constante (ej: "gemini-2.5-flash-lite" o
# "gemini-3-flash-preview" segun lo que tengas habilitado en tu proyecto).
MODEL_ID = "gemini-2.5-flash"


def verificar_titular(titular: str) -> dict:
    try:
        prompt = (
            f"¿Es real esta noticia? Dame un procentaje de cuan real es, "
            f"una muy breve descripcion de porque conluyes eso. "
            f"Separa el porcentaje y la descripción con un ';' "
            f"(no incluyas links en el texto, las fuentes se entregan aparte): "
            f"{titular}"
        )

        response = client.models.generate_content(
            model=MODEL_ID,
            contents=prompt,
            config=types.GenerateContentConfig(
                tools=[types.Tool(google_search=types.GoogleSearch())],
            ),
        )

        texto = (response.text or "").strip()
        partes = texto.split(';', 1)
        score = partes[0].strip() if len(partes) >= 1 else ""
        label = partes[1].strip() if len(partes) >= 2 else texto

        # Extraer fuentes reales desde grounding_metadata
        fuentes = []
        try:
            candidate = response.candidates[0]
            grounding = getattr(candidate, "grounding_metadata", None)
            chunks = getattr(grounding, "grounding_chunks", None) or []
            for chunk in chunks:
                web = getattr(chunk, "web", None)
                if web is None:
                    continue
                uri = getattr(web, "uri", None)
                if uri and uri not in fuentes:
                    fuentes.append(uri)
        except (AttributeError, IndexError, TypeError):
            fuentes = []

        return {"score": score, "label": label, "fuentes": fuentes}
    except Exception as error:
        print(error)
        return {"score": "", "label": f"Error al consultar el modelo: {error}", "fuentes": []}


if __name__ == '__main__':
    titular = input('Ingrese el titular: ')
    resultado = verificar_titular(titular)
    print(f"La noticia es {resultado['score']} real")
    print()
    print(resultado["label"])
    print("\nFuentes:")
    for fuente in resultado["fuentes"]:
        print(fuente)