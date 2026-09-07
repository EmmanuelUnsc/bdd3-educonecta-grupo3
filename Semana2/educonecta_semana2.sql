CREATE TABLE TABLA_ESTUDIANTES OF TIPO_ESTUDIANTE (
    cod_estudiante PRIMARY KEY
);

CREATE OR REPLACE TYPE TIPO_MODULO AS OBJECT (
    nro_orden           NUMBER(3),
    titulo              VARCHAR2(100 CHAR),
    horas_academicas    NUMBER(4),
    tipo_contenido      VARCHAR2(20 CHAR)
);
/

CREATE OR REPLACE TYPE TIPO_MODULOS_TAB AS TABLE OF TIPO_MODULO;
/

CREATE TYPE TIPO_CURSO;
/

CREATE OR REPLACE TYPE TIPO_PRERREQUISITOS_TAB AS TABLE OF REF TIPO_CURSO;
/

CREATE OR REPLACE TYPE TIPO_CURSO AS OBJECT (
    cod_curso           VARCHAR2(15 CHAR),
    nombre              VARCHAR2(100 CHAR),
    creditos            NUMBER(2),
    nivel               VARCHAR2(10 CHAR),
    modalidad           VARCHAR2(20 CHAR),
    modulos             TIPO_MODULOS_TAB,
    prerrequisitos      TIPO_PRERREQUISITOS_TAB
);
/

CREATE TABLE TABLA_CURSOS OF TIPO_CURSO (
    cod_curso PRIMARY KEY
)
NESTED TABLE modulos        STORE AS cursos_modulos_tab
NESTED TABLE prerrequisitos STORE AS cursos_prerrequisitos_tab;

CREATE OR REPLACE TYPE TIPO_MATRICULA AS OBJECT (
    cod_matricula       VARCHAR2(20 CHAR),
    ref_estudiante      REF TIPO_ESTUDIANTE,
    ref_curso           REF TIPO_CURSO,
    periodo             VARCHAR2(10 CHAR),
    fecha_matricula     DATE,
    tipo_beca           VARCHAR2(20 CHAR),
    porcentaje_beca     NUMBER(5,2),
    avance_porcentaje   NUMBER(5,2),
    nota_final          NUMBER(5,2),
    estado              VARCHAR2(15 CHAR)
);
/

CREATE TABLE TABLA_MATRICULAS OF TIPO_MATRICULA (
    cod_matricula   PRIMARY KEY,
    ref_estudiante  SCOPE IS TABLA_ESTUDIANTES,
    ref_curso       SCOPE IS TABLA_CURSOS
);

INSERT INTO TABLA_ESTUDIANTES VALUES (
    TIPO_ESTUDIANTE('EST-2026-001', 'CI', '8452136',
        'Camila Andrea', 'Rojas Villarroel',
        DATE '2004-03-12', 'camila.rojas@educonecta.edu',
        TIPO_DIRECCION('Av. Ballivian 1240', 'Cochabamba', 'Bolivia'),
        'Sede Bolivia', 'PREGRADO', 'Ingenieria de Sistemas Informaticos',
        DATE '2023-02-06', 'ACTIVO')
);

INSERT INTO TABLA_ESTUDIANTES VALUES (
    TIPO_ESTUDIANTE('EST-2026-002', 'DNI', '74125836',
        'Mateo Alonso', 'Quispe Ramos',
        DATE '1998-11-25', 'mateo.quispe@educonecta.edu',
        TIPO_DIRECCION('Jr. Puno 350', 'Lima', 'Perú'),
        'Sede Peru', 'POSGRADO', 'Maestria en Ciencia de Datos',
        DATE '2025-03-10', 'ACTIVO')
);

INSERT INTO TABLA_ESTUDIANTES VALUES (
    TIPO_ESTUDIANTE('EST-2026-003', 'DNI', '40218765',
        'Valentina', 'Ferreyra Duarte',
        DATE '2002-07-08', 'valentina.ferreyra@educonecta.edu',
        TIPO_DIRECCION('Calle Corrientes 880', 'Rosario', 'Argentina'),
        'Sede Argentina', 'PREGRADO', 'Administracion de Empresas',
        DATE '2022-08-15', 'ACTIVO')
);

COMMIT;

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('BDD-101', 'Fundamentos de Bases de Datos', 4, 'PREGRADO', 'VIRTUAL',
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Modelo entidad-relacion', 20, 'VIDEO'),
            TIPO_MODULO(2, 'Algebra relacional y SQL', 28, 'TALLER'),
            TIPO_MODULO(3, 'Normalizacion hasta 3FN', 16, 'LECTURA')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('PRG-102', 'Programacion Orientada a Objetos', 5, 'PREGRADO', 'ASINCRONICO',
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Clases, objetos y encapsulamiento', 24, 'VIDEO'),
            TIPO_MODULO(2, 'Herencia y polimorfismo', 30, 'TALLER')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('BDD-301', 'Bases de Datos Objeto-Relacionales', 6, 'PREGRADO', 'VIRTUAL',
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Tipos de objeto y constructores', 18, 'VIDEO'),
            TIPO_MODULO(2, 'Tablas de objetos y referencias REF', 22, 'TALLER'),
            TIPO_MODULO(3, 'Colecciones VARRAY y Nested Table', 22, 'TALLER'),
            TIPO_MODULO(4, 'Consultas objeto-relacionales', 14, 'EVALUACION')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

COMMIT;

UPDATE TABLA_CURSOS c
   SET c.prerrequisitos = CAST(MULTISET(
           SELECT REF(p) FROM TABLA_CURSOS p
           WHERE p.cod_curso IN ('BDD-101', 'PRG-102')
       ) AS TIPO_PRERREQUISITOS_TAB)
 WHERE c.cod_curso = 'BDD-301';

COMMIT;

INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0001', REF(e), REF(c), '2026-2',
                      DATE '2026-08-05', 'EXCELENCIA', 40, 65, NULL, 'EN_CURSO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-001' AND c.cod_curso = 'BDD-301';

INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0002', REF(e), REF(c), '2026-2',
                      DATE '2026-08-06', 'SIN_BECA', 0, 30, NULL, 'EN_CURSO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-002' AND c.cod_curso = 'PRG-102';

INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0003', REF(e), REF(c), '2026-1',
                      DATE '2026-02-09', 'SOCIOECONOMICA', 25, 100, 78, 'APROBADO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-003' AND c.cod_curso = 'BDD-101';

COMMIT;

INSERT INTO TABLA_ESTUDIANTES VALUES (
    TIPO_ESTUDIANTE('EST-2026-004', 'CI', '9317204',
        'Sebastian', 'Mendoza Arce',
        DATE '2001-05-30', 'sebastian.mendoza@educonecta.edu',
        TIPO_DIRECCION('Calle Sucre 145', 'Santa Cruz', 'Bolivia'),
        'Sede Bolivia', 'PREGRADO', 'Ingenieria de Sistemas Informaticos',
        DATE '2024-02-05', 'ACTIVO')
);

INSERT INTO TABLE(SELECT c.modulos FROM TABLA_CURSOS c WHERE c.cod_curso = 'BDD-101')
VALUES (TIPO_MODULO(4, 'Transacciones y concurrencia', 18, 'VIDEO'));

INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0004', REF(e), REF(c), '2026-2',
                      SYSDATE, 'DEPORTIVA', 15, 10, NULL, 'EN_CURSO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-004' AND c.cod_curso = 'BDD-301';

COMMIT;

SELECT e.cod_estudiante,
       e.nombre_completo() AS estudiante,
       e.edad() AS edad,
       e.direccion.ciudad AS ciudad,
       e.direccion.pais AS pais,
       e.nivel,
       e.sede
FROM TABLA_ESTUDIANTES e
ORDER BY e.cod_estudiante;

SELECT c.cod_curso, c.nombre, c.creditos, c.nivel, c.modalidad
FROM TABLA_CURSOS c
ORDER BY c.cod_curso;

SELECT c.cod_curso, m.nro_orden, m.titulo, m.horas_academicas, m.tipo_contenido
FROM TABLA_CURSOS c, TABLE(c.modulos) m
ORDER BY c.cod_curso, m.nro_orden;

SELECT c.cod_curso, COUNT(*) AS modulos, SUM(m.horas_academicas) AS horas_totales
FROM TABLA_CURSOS c, TABLE(c.modulos) m
GROUP BY c.cod_curso
ORDER BY c.cod_curso;

SELECT c.cod_curso,
       DEREF(p.COLUMN_VALUE).cod_curso AS cod_prerrequisito,
       DEREF(p.COLUMN_VALUE).nombre AS prerrequisito
FROM TABLA_CURSOS c, TABLE(c.prerrequisitos) p
ORDER BY c.cod_curso, cod_prerrequisito;

SELECT m.cod_matricula,
       m.periodo,
       DEREF(m.ref_estudiante).cod_estudiante AS cod_estudiante,
       DEREF(m.ref_estudiante).apellidos AS apellidos,
       DEREF(m.ref_curso).cod_curso AS cod_curso,
       DEREF(m.ref_curso).nombre AS curso,
       DEREF(m.ref_curso).creditos AS creditos,
       m.tipo_beca,
       m.porcentaje_beca,
       m.avance_porcentaje,
       m.nota_final,
       m.estado
FROM TABLA_MATRICULAS m
ORDER BY m.cod_matricula;

SELECT c.cod_curso,
       DEREF(p.COLUMN_VALUE).cod_curso AS cod_prerrequisito,
       DEREF(p.COLUMN_VALUE).nombre AS prerrequisito
FROM TABLA_CURSOS c, TABLE(c.prerrequisitos) p
ORDER BY c.cod_curso, cod_prerrequisito;

UPDATE TABLA_ESTUDIANTES
   SET email_institucional = 'c.rojas@educonecta.edu'
 WHERE cod_estudiante = 'EST-2026-001';

UPDATE TABLA_ESTUDIANTES e
   SET e.direccion.calle = 'Av. Ballivian 1240, Torre B'
 WHERE e.cod_estudiante = 'EST-2026-001';

UPDATE TABLE(SELECT c.modulos FROM TABLA_CURSOS c WHERE c.cod_curso = 'BDD-301') m
   SET m.horas_academicas = 26
 WHERE m.nro_orden = 3;

UPDATE TABLA_MATRICULAS
   SET avance_porcentaje = 80
 WHERE cod_matricula = 'MAT-2026-0001';

COMMIT;

DELETE FROM TABLE(SELECT c.modulos FROM TABLA_CURSOS c WHERE c.cod_curso = 'BDD-101') m
WHERE m.nro_orden = 4;

DELETE FROM TABLA_MATRICULAS
WHERE cod_matricula = 'MAT-2026-0004';

DELETE FROM TABLA_ESTUDIANTES
WHERE cod_estudiante = 'EST-2026-004';

COMMIT;

SAVEPOINT antes_de_prueba_dangling;

DELETE FROM TABLA_ESTUDIANTES WHERE cod_estudiante = 'EST-2026-003';

SELECT m.cod_matricula, m.periodo, m.estado
FROM TABLA_MATRICULAS m
WHERE m.ref_estudiante IS DANGLING;

SELECT m.cod_matricula, DEREF(m.ref_estudiante).apellidos AS estudiante
FROM TABLA_MATRICULAS m
ORDER BY m.cod_matricula;

ROLLBACK TO SAVEPOINT antes_de_prueba_dangling;

SELECT COUNT(*) AS refs_colgantes FROM TABLA_MATRICULAS WHERE ref_estudiante IS DANGLING;

COMMIT;

DESCRIBE TIPO_MODULO
DESCRIBE TIPO_CURSO
DESCRIBE TIPO_MATRICULA
DESCRIBE TABLA_ESTUDIANTES
DESCRIBE TABLA_CURSOS
DESCRIBE TABLA_MATRICULAS
