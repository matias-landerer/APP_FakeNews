# FakeNewsDetector:
Fake News Detector es una aplicación capaz de recibir el titular de una noticia en formato de texto, y determinar la veracidad de esta.
Al ingresar el titular entrega un porcentaje que representa que tan real es la noticia, una breve descripción explicando el por qué se llegó a esa conclusión, y una lista de links que llevan a las fuentes usadas para obtener el resultado.

## Flujo de la APP:
Al iniciar la aplicación te pide iniciar sesión o registrarte. Luego se entra directamente a la página principal, en la cual se puede ingresar el titular de la noticia que se busca consultar. En esta página también se puede seleccionar un boton de opciones, el cual al presionarlo despliega una serie de, valga la redundancia, opciones, entre las cuales se encuentran el cerrar sesión, ver las estadísticas (datos sobre el uso como el número de consultas realizadas, cuales fueron, etc.), una sección de información (algo parecido a este README pero enfocado al público) y comprar créditos (más detalles sobre esto más adelante).
### Opciones: Cerrar sesión.
Se cierra la sesión y se vuelve a la página de inicio de sesión / registro.
### Opciones: Estadísticas.
Muestra un numero con todas las consultas realizadas, y a continuación una lista con cada consulta, con el titular y el resultado (porcentaje y descripción).
### Opciones: Información.
Una presentación para los usuarios. Les explica lo que hace la app y como pueden usarla, pero sin terminos técnicos.
### Opciones: Créditos.
El modelo de negocio de Fake News Detector consiste en que los clientes tienen una serie de créditos y con 1 crédito realizan una consulta. Parten con unos 20/30 créditos gratis ára que prueben el servicio, y luego compran cŕeditos para seguir consumiendo. La compra la hacen en este apartado.

## Tecnologías usadas:
### Python/Flask:
Usado para la API rest del servidor, encargada del inicio de sesión, registro, seguridad, analisis de la noticia, etc.
### Dart/Flutter:
Usado para el frontend de la aplicación. El programa que descargan y usan los usuarios. Se encarga de enviar y recibir información del servidor y desplegarla al usuario.
### Postgresql:
Usado para la base de datos.
