# komercia_app

# dev

1. Copiar el .env.template y renombrarlo a .env


# prod
Para cambiar el nombre de la aplicación y publicar:
1-Instalar el paquete change_app_package_name en dev
2-Corres comando: dart run change_app_package_name:main com.dominio.name (recomendado)

Para cambiar el icono
1-Instalar el paquete flutter_launcher_icons en dev
2-Correr comando: dart run flutter_launcher_icons

Generar key store
1-cd "C:\Program Files\Android\Android Studio\jbr\bin"
2-keytool -genkey -v -keystore "%USERPROFILE%\upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
