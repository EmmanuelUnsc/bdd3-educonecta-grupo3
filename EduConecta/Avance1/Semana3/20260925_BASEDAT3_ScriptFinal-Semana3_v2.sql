/*
    Avance 1 - Version 2 (Semanas 1, 2 y 3)
    Caso: EduConecta - Grupo 3

    Cambios respecto a la v1 (20260907_BASEDAT3_ScriptFinal-Semana3.sql):
    1. TABLA_MATRICULAS ya no usa SCOPE IS: las referencias se crean
       con REF y se navegan con DEREF, como recomendo el docente.
    2. TIPO_CURSO tiene el atributo cupo_maximo, que necesita el
       Avance 2 (trigger TRG_VALIDA_CUPO_CURSO).
*/

/*Tipo Direccion*/
CREATE OR REPLACE TYPE TIPO_DIRECCION AS OBJECT (
    calle       VARCHAR2(120 CHAR),
    ciudad      VARCHAR2(60 CHAR),
    pais        VARCHAR2(40 CHAR),

    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle     VARCHAR2,
        p_ciudad    VARCHAR2,
        p_pais      VARCHAR2
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION formato_texto RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY TIPO_DIRECCION AS

    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle     VARCHAR2,
        p_ciudad    VARCHAR2,
        p_pais      VARCHAR2
    ) RETURN SELF AS RESULT IS
        v_pais VARCHAR2(40 CHAR);
    BEGIN
        v_pais := TRANSLATE(UPPER(TRIM(p_pais)), 'ÁÉÍÓÚÜÑ', 'AEIOUUN');

        IF v_pais IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'El pais es obligatorio.');
        END IF;

        IF v_pais NOT IN ('BOLIVIA', 'PERU', 'ARGENTINA') THEN
            RAISE_APPLICATION_ERROR(-20002, 'Pais no habilitado: ' || p_pais);
        END IF;

        SELF.calle  := p_calle;
        SELF.ciudad := p_ciudad;
        SELF.pais   := v_pais;

        RETURN;
    END;

    MEMBER FUNCTION formato_texto RETURN VARCHAR2 IS
    BEGIN
        RETURN calle || ', ' || ciudad || ', ' || pais;
    END formato_texto;

END;
/

/*Tipo Estudiante*/
CREATE OR REPLACE TYPE TIPO_ESTUDIANTE AS OBJECT (
    cod_estudiante      VARCHAR2(15 CHAR),
    tipo_documento      VARCHAR2(15 CHAR),
    nro_documento       VARCHAR2(20 CHAR),
    nombres             VARCHAR2(60 CHAR),
    apellidos           VARCHAR2(60 CHAR),
    fecha_nacimiento    DATE,
    email_institucional VARCHAR2(254 CHAR),
    direccion           TIPO_DIRECCION,
    sede                VARCHAR2(40 CHAR),
    nivel               VARCHAR2(10 CHAR),
    programa            VARCHAR2(80 CHAR),
    fecha_ingreso       DATE,
    estado              VARCHAR2(15 CHAR),

    CONSTRUCTOR FUNCTION TIPO_ESTUDIANTE(
        p_cod_estudiante        VARCHAR2,
        p_tipo_documento        VARCHAR2,
        p_nro_documento         VARCHAR2,
        p_nombres               VARCHAR2,
        p_apellidos             VARCHAR2,
        p_fecha_nacimiento      DATE,
        p_email_institucional   VARCHAR2,
        p_direccion             TIPO_DIRECCION,
        p_sede                  VARCHAR2,
        p_nivel                 VARCHAR2,
        p_programa              VARCHAR2,
        p_fecha_ingreso         DATE,
        p_estado                VARCHAR2
    ) RETURN SELF AS RESULT,

    MEMBER FUNCTION nombre_completo RETURN VARCHAR2,

    MEMBER FUNCTION edad RETURN NUMBER,

    MAP MEMBER FUNCTION clave_orden RETURN VARCHAR2

);
/

CREATE OR REPLACE TYPE BODY TIPO_ESTUDIANTE AS

    CONSTRUCTOR FUNCTION TIPO_ESTUDIANTE(
        p_cod_estudiante        VARCHAR2,
        p_tipo_documento        VARCHAR2,
        p_nro_documento         VARCHAR2,
        p_nombres               VARCHAR2,
        p_apellidos             VARCHAR2,
        p_fecha_nacimiento      DATE,
        p_email_institucional   VARCHAR2,
        p_direccion             TIPO_DIRECCION,
        p_sede                  VARCHAR2,
        p_nivel                 VARCHAR2,
        p_programa              VARCHAR2,
        p_fecha_ingreso         DATE,
        p_estado                VARCHAR2
    ) RETURN SELF AS RESULT IS
        v_nivel     VARCHAR2(40 CHAR);
    BEGIN
        v_nivel := UPPER(TRIM(p_nivel));

        IF v_nivel IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'El nivel es obligatorio.');
        END IF;

        IF v_nivel NOT IN ('PREGRADO', 'POSGRADO') THEN
            RAISE_APPLICATION_ERROR(-20004, 'Nivel no habilitado: ' || p_nivel);
        END IF;

        SELF.cod_estudiante         := p_cod_estudiante;
        SELF.tipo_documento         := p_tipo_documento;
        SELF.nro_documento          := p_nro_documento;
        SELF.nombres                := p_nombres;
        SELF.apellidos              := p_apellidos;
        SELF.fecha_nacimiento       := p_fecha_nacimiento;
        SELF.email_institucional    := p_email_institucional;
        SELF.direccion              := p_direccion;
        SELF.sede                   := p_sede;
        SELF.nivel                  := v_nivel;
        SELF.programa               := p_programa;
        SELF.fecha_ingreso          := p_fecha_ingreso;
        SELF.estado                 := p_estado;

        RETURN;
    END;

    MEMBER FUNCTION nombre_completo RETURN VARCHAR2 IS
    BEGIN
        RETURN apellidos || ', ' || nombres;
    END nombre_completo;

    MEMBER FUNCTION edad RETURN NUMBER IS
    BEGIN
        IF fecha_nacimiento IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12);
    END edad;

    MAP MEMBER FUNCTION clave_orden RETURN VARCHAR2 IS
    BEGIN
        RETURN cod_estudiante;
    END clave_orden;

END;
/

/*Verificacion*/
DESCRIBE TIPO_DIRECCION
DESCRIBE TIPO_ESTUDIANTE

/*SEMANA 2*/
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
    cupo_maximo         NUMBER(3),
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
    cod_matricula   PRIMARY KEY
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
    TIPO_CURSO('BDD-101', 'Fundamentos de Bases de Datos', 4, 'PREGRADO', 'VIRTUAL', 3,
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Modelo entidad-relacion', 20, 'VIDEO'),
            TIPO_MODULO(2, 'Algebra relacional y SQL', 28, 'TALLER'),
            TIPO_MODULO(3, 'Normalizacion hasta 3FN', 16, 'LECTURA')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('PRG-102', 'Programacion Orientada a Objetos', 5, 'PREGRADO', 'ASINCRONICO', 2,
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Clases, objetos y encapsulamiento', 24, 'VIDEO'),
            TIPO_MODULO(2, 'Herencia y polimorfismo', 30, 'TALLER')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('BDD-301', 'Bases de Datos Objeto-Relacionales', 6, 'PREGRADO', 'VIRTUAL', 3,
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

SELECT c.cod_curso, c.nombre, c.creditos, c.nivel, c.modalidad, c.cupo_maximo
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

/*SEMANA 3*/
/*Semana 3 - Verificacion de consistencia - Caso EduConecta - Grupo 3*/

/*Ampliacion del catalogo al nivel de posgrado*/

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('CDD-501', 'Modelado de Datos para Ciencia de Datos', 6, 'POSGRADO', 'VIRTUAL', 2,
        TIPO_MODULOS_TAB(
            TIPO_MODULO(1, 'Modelos de datos para analitica', 22, 'VIDEO'),
            TIPO_MODULO(2, 'Almacenes de datos y modelado dimensional', 26, 'TALLER'),
            TIPO_MODULO(3, 'Calidad y gobierno de datos', 18, 'TALLER'),
            TIPO_MODULO(4, 'Proyecto integrador de modelado', 16, 'EVALUACION')
        ),
        TIPO_PRERREQUISITOS_TAB())
);

UPDATE TABLA_CURSOS c
   SET c.prerrequisitos = CAST(MULTISET(
           SELECT REF(p) FROM TABLA_CURSOS p WHERE p.cod_curso = 'BDD-101'
       ) AS TIPO_PRERREQUISITOS_TAB)
 WHERE c.cod_curso = 'CDD-501';

UPDATE TABLA_MATRICULAS m
   SET m.ref_curso = (SELECT REF(c) FROM TABLA_CURSOS c WHERE c.cod_curso = 'CDD-501')
 WHERE m.cod_matricula = 'MAT-2026-0002';

INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0005', REF(e), REF(c), '2026-2',
                      DATE '2026-08-05', 'EXCELENCIA', 40, 20, NULL, 'EN_CURSO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-001' AND c.cod_curso = 'PRG-102';

COMMIT;


/*1. Cuantas filas hay en cada estructura del esquema*/

SELECT COUNT(*) AS estudiantes FROM TABLA_ESTUDIANTES;

SELECT COUNT(*) AS cursos FROM TABLA_CURSOS;

SELECT COUNT(*) AS matriculas FROM TABLA_MATRICULAS;

SELECT COUNT(*) AS modulos FROM TABLA_CURSOS c, TABLE(c.modulos) m;

SELECT COUNT(*) AS prerrequisitos FROM TABLA_CURSOS c, TABLE(c.prerrequisitos) p;


/*2. Los mismos identificadores en ambas tablas*/

SELECT m.cod_matricula,
       DEREF(m.ref_estudiante).cod_estudiante AS id_por_referencia,
       e.cod_estudiante                       AS id_en_tabla,
       DEREF(m.ref_curso).cod_curso           AS curso_por_referencia,
       c.cod_curso                            AS curso_en_tabla
  FROM TABLA_MATRICULAS m, TABLA_ESTUDIANTES e, TABLA_CURSOS c
 WHERE m.ref_estudiante = REF(e)
   AND m.ref_curso      = REF(c)
 ORDER BY m.cod_matricula;


/*3. Ninguna referencia quedo colgante*/

SELECT COUNT(*) AS refs_colgantes
  FROM TABLA_MATRICULAS
 WHERE ref_estudiante IS DANGLING OR ref_curso IS DANGLING;


/*4. Los prerrequisitos apuntan a cursos que existen en el catalogo*/

SELECT c.cod_curso,
       DEREF(p.COLUMN_VALUE).cod_curso AS prerrequisito,
       DEREF(p.COLUMN_VALUE).nombre    AS nombre
  FROM TABLA_CURSOS c, TABLE(c.prerrequisitos) p
 ORDER BY c.cod_curso, prerrequisito;


/*5. La coleccion de modulos esta poblada en todos los cursos*/

SELECT c.cod_curso,
       COUNT(*)                AS modulos,
       SUM(m.horas_academicas) AS horas_totales
  FROM TABLA_CURSOS c, TABLE(c.modulos) m
 GROUP BY c.cod_curso
 ORDER BY c.cod_curso;


/*6. Las validaciones del constructor siguen vigentes en los datos*/

SELECT e.cod_estudiante,
       e.nombre_completo() AS estudiante,
       e.direccion.pais    AS pais,
       e.sede,
       e.nivel
  FROM TABLA_ESTUDIANTES e
 ORDER BY e.cod_estudiante;


/*7. El nivel del curso coincide con el nivel del estudiante en toda matricula*/

SELECT m.cod_matricula,
       DEREF(m.ref_estudiante).nivel AS nivel_estudiante,
       DEREF(m.ref_curso).nivel      AS nivel_curso
  FROM TABLA_MATRICULAS m
 ORDER BY m.cod_matricula;


/*8. Riesgo de integridad de las referencias*/

SAVEPOINT antes_de_prueba_dangling;

DELETE FROM TABLA_ESTUDIANTES WHERE cod_estudiante = 'EST-2026-003';

SELECT m.cod_matricula, m.periodo, m.estado
  FROM TABLA_MATRICULAS m
 WHERE m.ref_estudiante IS DANGLING;

SELECT m.cod_matricula, DEREF(m.ref_estudiante).apellidos AS estudiante
  FROM TABLA_MATRICULAS m
 ORDER BY m.cod_matricula;

ROLLBACK TO SAVEPOINT antes_de_prueba_dangling;

SELECT COUNT(*) AS refs_colgantes_tras_rollback
  FROM TABLA_MATRICULAS
 WHERE ref_estudiante IS DANGLING OR ref_curso IS DANGLING;

COMMIT;
