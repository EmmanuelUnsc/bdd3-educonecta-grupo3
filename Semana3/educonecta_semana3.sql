/*Semana 3 - Verificacion de consistencia - Caso EduConecta - Grupo 3*/

/*Ampliacion del catalogo al nivel de posgrado*/

INSERT INTO TABLA_CURSOS VALUES (
    TIPO_CURSO('CDD-501', 'Modelado de Datos para Ciencia de Datos', 6, 'POSGRADO', 'VIRTUAL',
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
