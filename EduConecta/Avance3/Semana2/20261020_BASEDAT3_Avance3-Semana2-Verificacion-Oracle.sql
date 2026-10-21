/*
    Avance 3 - Semana 2 - Punto 8
    Caso: EduConecta - Grupo 3
    Verifica en Oracle (usuario EDUCONECTA) que los ids usados en
    contenido_cursos y foros_discusion existen en el nucleo de las Unidades 1 y 2.
*/

/*1. Los modulos a los que apuntan CNT-001, CNT-002 y CNT-003 (cod_curso + nro_orden)*/

SELECT c.cod_curso, m.nro_orden, m.titulo, m.tipo_contenido
  FROM TABLA_CURSOS c, TABLE(c.modulos) m
 WHERE (c.cod_curso = 'BDD-301' AND m.nro_orden IN (1, 4))
    OR (c.cod_curso = 'BDD-101' AND m.nro_orden = 3)
 ORDER BY c.cod_curso, m.nro_orden;


/*2. Cada autor de resena esta matriculado en el curso de su contenido*/

SELECT m.cod_matricula, e.cod_estudiante, c.cod_curso, m.estado
  FROM TABLA_MATRICULAS m, TABLA_ESTUDIANTES e, TABLA_CURSOS c
 WHERE m.ref_estudiante = REF(e)
   AND m.ref_curso      = REF(c)
   AND ((e.cod_estudiante = 'EST-2026-001' AND c.cod_curso = 'BDD-301')
     OR (e.cod_estudiante = 'EST-2026-003' AND c.cod_curso = 'BDD-101'))
 ORDER BY m.cod_matricula;
