# Free Install

FInstall, un script en Bash que permite a los usuarios instalar y manejar paquetes APK del repositorio oficial de F-Droid a través de conexión *previa* por ADB.

## ¿Cómo funciona?

FInstall funciona a través de una interfaz CLI, puede ver los comandos disponibles usando el argumento "help".

* El manejo de APKs se realiza de manera segura con las siguientes medidas:
* Descarga del repositorio oficial de F-Droid
* No se permite la instalación de APKs locales
* Cada APK descargado se verifica con GPG, evitando archivos falsificados.
* Usa un método de instalación oficial: ADB.
* Solo se permite desinstalar aplicaciones previamente instaladas mediante FInstall, evitando romper componentes importantes del sistema.

## Dependencias

FInstall necesita un entorno donde exista:

* Bash
* curl
* GnuPG
* jq
* coreutils
* ADB

## Sin necesidad de una PC con GNU/Linux

Si no tiene una PC o un sistema GNU/Linux instalado, eso no es un problema, FInstall ha sido probado en el entorno de **Termux** y presenta el mismo comportamiento esperado que en una PC, solo es necesario tener instaladas las dependencias ya mencionadas.

### Ejemplo de uso

```
$ bash finstall.sh install org.gnu.emacs
Downloading APK...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 58918k 100 58918k   0     0  1484k     0   0:00:39  0:00:39 --:--:--  1496k
Downloading ASC...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   659 100   659   0     0  1046     0  --:--:-- --:--:-- --:--:--  1046
Verified: org.gnu.emacs_300200003.apk
Performing Streamed Install
Success
```

Puede que adicionalmente reciba una salida de GPG mostrando detalles de la firma.

## Licencia

FInstall se distribuye bajo la licencia MIT, vea el archivo LICENSE para más información.

Recuerde que el programa se provee "TAL CUAL" (AS IS) SIN GARANTIAS.

El usuario es responsable del uso que haga de este programa, FInstall no distribuye ni crea APKs, solo instala lo que el usuario le solicite desde repositorios de terceros.

### Contribuir

Puedes contribuir reportando errores, mejorando la documentación, proponiendo nuevas funciones y haciendo ajustes al código a través de una solicitud de fusión, toda contribución es bienvenida.
