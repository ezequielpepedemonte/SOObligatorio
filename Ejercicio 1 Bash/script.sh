#!/bin/bash

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
        echo "vamo a registrar usuario"
        # Eze
        registrarUsuario;;
      2)
        echo "vamo a registrar mascota";;
        # Caro
      3)
        echo "vamo a ver las Estadísticas";;
        # Nacho
      4)
        menuAdministradorValor=0
        clear
        echo "Has cerrado la sesión";;
      *)
        echo "Opción inválida";;
    esac
  done
}

registrarUsuario() {

}

menuPrincipalValor=1

while [ $menuPrincipalValor -eq 1 ]; do
  read -p "Ingrese usuario: " usuario
  read -p "Ingrese contraseña: " contrasena

  if grep -q "$usuario:$contrasena" administradores.txt; then
    echo "encotraste el usuario administrador"
    menuAdministrador
  elif grep -q "$usuario:$contrasena" clientes.txt; then
    echo "encotraste el usuario cliente"
  else
    echo "no existe este usuario"
  fi
done
