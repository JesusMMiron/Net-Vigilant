ENG
**********
This code is a PowerShell script that monitors the status of various services and endpoints in a network environment. Here is the description of the main parts of the script:

Log path definition: The script checks if certain directories exist in the system and sets the path of the log file based on their existence.
Log start: An entry is added to the log file to indicate that the script has started executing.
State variables definition: Variables are set to record the previous state of various services.
World Till monitoring: It checks if the World Till installation is present. If present, important configurations are read, and a monitoring loop is initiated to check the connectivity to various endpoints.
Betting Till monitoring: Similar to the World Till monitoring, this block checks the presence of the Betting Till installation and tracks the endpoints related to the clients.
ENDPOINT test function: This is a custom function that attempts to establish a TCP connection to an endpoint on a specific port. If the connection is successful, it returns 1; otherwise, it returns 0.

In summary, this script continuously monitors the connectivity to various services and endpoints in a network environment and logs the status changes in a log file for further analysis or tracking.



ESP
*************
Este código es un script de PowerShell que monitorea el estado de varios servicios y endpoints en un entorno de red. Aquí está la descripción de las principales partes del script:

Definición del log path: El script verifica si ciertos directorios existen en el sistema y establece la ruta del archivo de registro en función de su existencia.
Inicio del log: Se agrega una entrada en el archivo de registro para indicar que el script ha comenzado a ejecutarse.
Definición de variables de estado: Se establecen variables para registrar el estado anterior de varios servicios.
Monitoreo de World Till: Se verifica si la instalación de World Till está presente. Si está presente, se leen configuraciones importantes y se inicia un bucle de monitoreo para verificar la conectividad a varios endpoints.
Monitoreo de Betting Till: Similar al monitoreo de World Till, este bloque verifica la presencia de la instalación de Betting Till y realiza un seguimiento de los endpoints relacionados con los clientes.
Función de prueba de ENDPOINT: Esta es una función personalizada que intenta establecer una conexión TCP a un endpoint en un puerto específico. Si la conexión es exitosa, devuelve 1; de lo contrario, devuelve 0.

En resumen, este script monitorea continuamente la conectividad a varios servicios y endpoints en un entorno de red y registra los cambios de estado en un archivo de registro para su posterior análisis o seguimiento.
