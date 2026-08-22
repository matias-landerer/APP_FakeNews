import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const secondary = Color(0xFFEF342A);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Fake News Detector",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1D1B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E4D8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: secondary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        "Bienvenido/a a Fake News Detector!!\n"
                        "Como el nombre lo indica, se trata de un detector de noticias falsas.\n"
                        "¿CÓMO FUNCIONA?\nFácil. Solamente ingresas el titular de cualquier noticia, y la app te entregará un porcentaje de veracidad, "
                        "una descripción de por qué se llegó a esa conclusión y una listas con las fuentes que se usaron.\n"
                        "CONSIDERACIONES IMPORTANTES:\n- El titular debe ser descriptivo. Hay muchas noticias con titulares muy vagos. Por ejemplo,"
                        " un reportaje que estudia el indice de felicidad en Chile podría llamarse \"¿Qué tan felices somos los chilenos?\" "
                        "Lo cuál claramente no es suficiente para determinar su veracidad. Titulares como \"Presidente anuncia nueva ley\" también son vagos,"
                        " pues no se aclara el país ni la ley en específico (la app no asume que se trata de Chile o cualquier otro sitio).\n- El análisis"
                        " de veracidad es hecho por una IA, por lo que es importante siempre revisar las fuentes entregadas en lugar de creer en el resultado"
                        " ciegamente.\n- Esta app es un detector de noticias falsas, NO ES UN LLM, por lo que la manera correcta de usarla es introducir un"
                        " titular de noticia o un acontecimiento leido en redes sociales con el fin de saber si en verdad ocurrió. No funcionará bien si se"
                        " le hacen preguntas, ni tampoco reaccionará si se le pide que haga algo que no sea analizar un titular.\nSISTEMA DE CRÉDITOS:\nCada"
                        " análisis gasta un crédito, y para conseguir más se compra un paquete. Al crear una cuenta se incluyen 20 créditos gratuitos."
                        "\nRecomendación: probar bien la app con esos 20 créditos y si la app resulta útil, evaluar si vale la pena obtener más.\n\nPor favor,"
                        " cualquier tipo de error encontrado en la app (ya sea en la verificación del titular, en la interfaz o en la conexión al servidor)"
                        " comunicar a fake.news.detector.support@gmail.com\nMUCHAS GRACIAS POR USAR LA APP :)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
