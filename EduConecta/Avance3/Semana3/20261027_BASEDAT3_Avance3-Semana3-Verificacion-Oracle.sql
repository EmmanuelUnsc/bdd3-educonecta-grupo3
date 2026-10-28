/*
    Avance 3 - Semana 3 - Puntos 9 y 10
    Caso: EduConecta - Grupo 3
    Verifica en Oracle (usuario EDUCONECTA) que los ids usados en el stream
    progreso_en_vivo:CNT-001 existen en el nucleo de las Unidades 1 y 2.
*/

/*1. El modulo de CNT-001 (BDD-301, nro_orden 1) es una video-clase*/

SELECT c.cod_curso, m.nro_orden, m.titulo, m.tipo_contenido
  FROM TABLA_CURSOS c, TABLE(c.modulos) m
 WHERE c.cod_curso = 'BDD-301'
   AND m.nro_orden = 1;


/*2. Los productores del stream son matriculas EN_CURSO en BDD-301*/

SELECT m.cod_matricula, e.cod_estudiante, c.cod_curso, m.estado, m.avance_porcentaje
  FROM TABLA_MATRICULAS m, TABLA_ESTUDIANTES e, TABLA_CURSOS c
 WHERE m.ref_estudiante = REF(e)
   AND m.ref_curso      = REF(c)
   AND m.cod_matricula IN ('MAT-2026-0001', 'MAT-2026-0004')
 ORDER BY m.cod_matricula;
