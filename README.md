
## **Construcción de la Imagen Docker**

Para construir la imagen Docker, utiliza el siguiente comando, personalizando el nombre de usuario, UID, y GID si es necesario:

```bash
docker build --build-arg USERNAME=<nombre_usuario> --build-arg USER_UID=<id_usuario> --build-arg USER_GID=<id_grupo> -t <nombre_imagen> .
```

### **Argumentos de Construcción**
- **`USERNAME`**: Define el nombre del usuario dentro del contenedor (predeterminado: `default_user`).
- **`USER_UID`**: Define el ID de usuario dentro del contenedor (predeterminado: `1000`).
- **`USER_GID`**: Define el ID de grupo dentro del contenedor (predeterminado: `1000`).

### **Ejemplo de Construcción**
```bash
docker build --build-arg USERNAME=mi_usuario --build-arg USER_UID=2000 --build-arg USER_GID=2000 -t mi_imagen .
```

---

## **Ejecución del Contenedor Docker**

Una vez que la imagen esté construida, ejecuta el contenedor utilizando este comando:

```bash
docker run --hostname <nombre_host> -it --name <nombre_contenedor> <nombre_imagen>
```

### **Parámetros de Ejecución**
- **`--hostname`**: Define el nombre del host que aparecerá en el prompt del contenedor.
- **`--name`**: Define un nombre amigable para el contenedor, útil para identificarlo fácilmente.

### **Ejemplo de Ejecución**
```bash
docker run --hostname mi_pc -it --name mi_contenedor mi_imagen
```

### **Resultado**
Dentro del contenedor, el prompt del terminal debería verse como:
```plaintext
mi_usuario@mi_pc:~$
```


