#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define MAX_MATERIAS 20

typedef struct {
    char *codigo;
    char *nombre;
    int prereqs[MAX_MATERIAS];
    int prereq_count;
    int completado;
} Materia;

Materia materias[MAX_MATERIAS];
int num_materias = 0;

pthread_mutex_t lock;

void inicializar_materias() {
    num_materias = 20;
    pthread_mutex_init(&lock, NULL);

    materias[0] = (Materia){"IP", "Introducción a la Programación", {}, 0, 0};
    materias[1] = (Materia){"M1", "Matemáticas I", {}, 0, 0};
    materias[2] = (Materia){"F1", "Física I", {}, 0, 0};
    materias[3] = (Materia){"ED", "Estructuras de Datos", {0}, 1, 0};
    materias[4] = (Materia){"M2", "Matemáticas II", {1}, 1, 0};
    materias[5] = (Materia){"F2", "Física II", {2}, 1, 0};
    materias[6] = (Materia){"PA", "Programación Avanzada", {3, 4}, 2, 0};
    materias[7] = (Materia){"BD", "Bases de Datos", {3}, 1, 0};
    materias[8] = (Materia){"RC", "Redes de Computadoras", {6, 5}, 2, 0};
    materias[9] = (Materia){"SO", "Sistemas Operativos", {6, 8}, 2, 0};
    materias[10] = (Materia){"IS", "Ingeniería de Software", {6}, 1, 0};
    materias[11] = (Materia){"SI", "Seguridad Informática", {8, 7}, 2, 0};
    materias[12] = (Materia){"IA", "Inteligencia Artificial", {6, 4}, 2, 0};
    materias[13] = (Materia){"CG", "Computación Gráfica", {5, 6}, 2, 0};
    materias[14] = (Materia){"DW", "Desarrollo Web", {7, 8}, 2, 0};
    materias[15] = (Materia){"SD", "Sistemas Distribuidos", {9, 8}, 2, 0};
    materias[16] = (Materia){"BG", "Big Data", {7, 4}, 2, 0};
    materias[17] = (Materia){"RO", "Robótica", {5, 6}, 2, 0};
    materias[18] = (Materia){"CS", "Ciberseguridad", {11, 9}, 2, 0};
    materias[19] = (Materia){"AA", "Análisis de Algoritmos", {6, 4}, 2, 0};
}

int requisitos_completos(int index) {
    for (int i = 0; i < materias[index].prereq_count; i++) {
        if (!materias[materias[index].prereqs[i]].completado) {
            return 0;
        }
    }
    return 1;
}

void *procesar_materia(void *arg) {
    int index = *(int *)arg;

    pthread_mutex_lock(&lock);
    if (!materias[index].completado && requisitos_completos(index)) {
        printf("Comenzando %s: %s\n", materias[index].codigo, materias[index].nombre);
        materias[index].completado = 1;
    }
    pthread_mutex_unlock(&lock);

    free(arg);
    return NULL;
}

void ejecutar_materias() {
    int materias_pendientes = num_materias;
    pthread_t threads[MAX_MATERIAS];

    while (materias_pendientes > 0) {
        int thread_count = 0;

        for (int i = 0; i < num_materias; i++) {
            if (!materias[i].completado && requisitos_completos(i)) {
                int *arg = malloc(sizeof(int));
                *arg = i;
                pthread_create(&threads[thread_count++], NULL, procesar_materia, arg);
            }
        }

        for (int i = 0; i < thread_count; i++) {
            pthread_join(threads[i], NULL);
        }

        materias_pendientes = 0;
        for (int i = 0; i < num_materias; i++) {
            if (!materias[i].completado) {
                materias_pendientes++;
            }
        }
    }
}

int main() {
    inicializar_materias();
    ejecutar_materias();
    pthread_mutex_destroy(&lock);
    return 0;
}
