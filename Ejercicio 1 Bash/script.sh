#!/bin/bash
validarNumeroEnteroPositivo() {
  [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ] #Funciónn sacada de ChatGPT.
}

registrarUsuario() {
  echo -e "Ingrese nombre completo del usuario:"
  read nombre
  echo -e "Ingrese cédula del usuario:"
  read cedula
  echo -e "Ingrese número de teléfono del usuario:"
  read telefono
  echo -e "Ingrese fecha de nacimiento (dd/mm/yyyy):"
  read fechaNacimiento

  # Verificar si el usuario ya existe en algun archivo
  if grep -q "$cedula" clientes.txt || grep -q "$cedula" administradores.txt; then
    echo -e "El usuario ya existe."
  else
    # Se pregunta si el cliente será administrador o cliente.
    echo -e "¿El usuario será cliente o administrador? (Ingrese 'cliente' o 'admin')"
    read tipoUsuario

    if [ "$tipoUsuario" = "cliente" ]; then
      echo -e "$nombre:$cedula:$telefono:$fechaNacimiento" >> clientes.txt
      echo -e "Usuario cliente registrado exitosamente."
    elif [ "$tipoUsuario" = "admin" ]; then
      echo -e "$nombre:$cedula:$telefono:$fechaNacimiento" >> administradores.txt
      echo -e "Usuario administrador registrado exitosamente."
    else
      echo -e "Tipo de usuario inválido."
    fi
  fi
}

registrarMascota() {
  echo "Ingrese número identificador de la mascota:"
  read identificador

  # Verificar que el número identificador no se repita
  if grep -q "^$identificador-" mascotas.txt; then
    echo "El número identificador ya existe."
  else
    echo -e "Ingrese tipo de mascota (Perro, Gato, etc.):"
    read tipo
    echo -e "Ingrese nombre de la mascota:"
    read nombre
    echo -e "Ingrese sexo de la mascota (Macho, Hembra):"
    read sexo
    echo -e "Ingrese edad de la mascota (debe ser mayor a 0):"
    read edad

    # Validar que la edad sea un número entero mayor a 0
    if validarNumeroEnteroPositivo "$edad"; then
      echo -e "Ingrese descripción de la mascota:"
      read descripcion
      fechaIngreso=$(date +"%d/%m/%Y") # Fecha actual de ingreso

      # Registrar la mascota
      echo -e "$identificador-$tipo-$nombre-$sexo-$edad-$descripcion-$fechaIngreso" >> mascotas.txt
      echo -e "Mascota registrada exitosamente."
    else
      echo -e "Edad inválida. Debe ser un número mayor a 0."
    fi
  fi
}

#En la mayoria se usó IA debido a que no salía la solución correcta.
verEstadisticas() { 
  totalMascotas=$(cat mascotas.txt | wc -l)
  totalAdopciones=$(cat adopciones.txt | wc -l)

  if [ "$totalAdopciones" -gt 0 ]; then
    echo "Estadísticas de adopción:"

    # Porcentaje de adopción por tipo de mascota
    echo -e "Porcentaje de adopción por tipo de mascota:"
    for tipo in $(cut -d'-' -f2 adopciones.txt | sort | uniq); do
      totalPorTipo=$(grep "$tipo" adopciones.txt | wc -l)
      porcentaje=$(awk "BEGIN {printf \"%.2f\", ($totalPorTipo / $totalAdopciones) * 100}")
      echo "$tipo: $porcentaje%"
    done

    # Mes con más adopciones
    echo -e "Mes con más adopciones:"
    mesConMasAdopciones=$(cut -d'-' -f8 adopciones.txt | cut -d'/' -f2 | sort | uniq -c | sort -nr | head -n1)
    echo -e "Mes: $(echo $mesConMasAdopciones | awk '{print $2}'), Adopciones: $(echo $mesConMasAdopciones | awk '{print $1}')"

    # Edad promedio de animales adoptados
    echo -e "Edad promedio de los animales adoptados:"
    edadPromedio=$(awk -F'-' '{sum+=$5; count++} END {if (count > 0) print sum / count}' adopciones.txt) 
    echo -e "Edad promedio: $edadPromedio años"
  else
    echo -e "No se han registrado adopciones."
  fi
  echo -e ""
  echo -e "Presione cualquier tecla para cerrar."
  read -n 1 # Pausa para que el usuario lea el listado
}


listarMascotas() {
  echo -e "Mascotas disponibles para adopción:"
  awk -F'-' '{print "ID: " $1 ", Tipo: " $2 ", Nombre: " $3 ", Sexo: " $4 ", Edad: " $5 ", Descripción: " $6 ", Fecha de Ingreso: " $7}' mascotas.txt
  echo -e "\nPresiona cualquier tecla para continuar..."
  read -n 1 # Pausa para que el usuario lea el listado
}

adoptarMascota() {
  listarMascotas
  echo -e ""
  echo -e "Ingrese el número identificador de la mascota que desea adoptar:"
  read mascotaId

  # Verificar si la mascota existe en el archivo
  if grep -q "^$mascotaId-" mascotas.txt; then
    # Obtener la línea completa de la mascota seleccionada
    lineaMascota=$(grep "^$mascotaId-" mascotas.txt)

    # Eliminar solo la línea específica de la mascota seleccionada
    sed -i "/^$mascotaId-/d" mascotas.txt

    # Registrar la adopción en el archivo adopciones.txt
    fecha=$(date +"%d/%m/%Y")
    echo -e "$lineaMascota - Adoptado el $fecha" >> adopciones.txt
    echo -e "Has adoptado a la mascota con ID $mascotaId."
  else
    echo -e "Mascota no encontrada."
  fi
}



menuAdministrador() {
  menuAdministradorValor=1

  while [ $menuAdministradorValor -eq 1 ]; do
    clear
    echo -e "(1) Registrar Usuario \n"
    echo -e "(2) Registrar Mascota \n"
    echo -e "(3) Ver Estadísticas \n"
    echo -e "(4) Salir \n"
    read opcion

    case $opcion in
      1)
        registrarUsuario;;
      2)
        registrarMascota;;
      3)
        verEstadisticas;;
      4)
        menuAdministradorValor=0
        clear
        echo "Has cerrado la sesión";;
      *)
        echo "Opción inválida";;
    esac
  done
}

menuUsuario() {
  menuUsuarioValor=1

  while [ $menuUsuarioValor -eq 1 ]; do
    clear
    echo -e "(1) Mascotas disponibles para adopción. \n"
    echo -e "(2) Adoptar mascota. \n"
    echo -e "(3) Salir. \n"
    read opcion

    case $opcion in
      1)
        listarMascotas;;
      2)
        adoptarMascota;;
      3)
        menuUsuarioValor=0
        clear
        echo "Has cerrado la sesión";;
      *)
        echo "Opción inválida";;
    esac
  done
}

menuPrincipalValor=1

while [ $menuPrincipalValor -eq 1 ]; do
  read -p "Ingrese usuario: " usuario
  read -p "Ingrese contraseña: " contrasena

  if grep -q "$usuario:$contrasena" administradores.txt; then
    echo "Bienvenido administrador."
    menuAdministrador
  elif grep -q "$usuario:$contrasena" clientes.txt; then
    echo "Bienvenido cliente."
    menuUsuario
  else
    echo "Credenciales incorrectas o usuario sin registrar."
  fi
done
