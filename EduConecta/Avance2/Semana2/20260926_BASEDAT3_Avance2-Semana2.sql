/*
    Avance 2 - Semana 2: trigger TRG_VALIDA_CUPO_CURSO, pruebas e integracion
    Caso: EduConecta - Grupo 3
    Se construye sobre el Avance 1

    El paquete PKG_GESTION_MATRICULAS y la secuencia de la Semana 1
    se dan por hecho que ya estan creados.
*/

SET SERVEROUTPUT ON

/*
====================================================================
TRIGGER DE RESGUARDO: TRG_VALIDA_CUPO_CURSO
====================================================================
*/

/*
    AFTER: se revisa cuando la sentencia ya termino, asi el conteo de
    matriculas EN_CURSO ya incluye las filas nuevas.
    STATEMENT (sin FOR EACH ROW): un trigger de fila no puede contar
    filas de su propia tabla (ORA-04091, tabla mutante).
    Vigila el INSERT, el cambio de estado y el cambio de curso.
*/
CREATE OR REPLACE TRIGGER TRG_VALIDA_CUPO_CURSO
AFTER INSERT OR UPDATE OF estado, ref_curso ON TABLA_MATRICULAS
DECLARE
    CURSOR c_cursos IS
        SELECT c.cod_curso
        FROM TABLA_CURSOS c;
BEGIN
    FOR r IN c_cursos LOOP
        IF PKG_GESTION_MATRICULAS.cupos_disponibles(r.cod_curso) < 0 THEN
            RAISE_APPLICATION_ERROR(-20110,
                'El curso ' || r.cod_curso || ' supera su cupo maximo');
        END IF;
    END LOOP;
END;
/


/*
====================================================================
PRUEBAS DE CADA SUBPROGRAMA (EXITO Y FALLO)
====================================================================
*/

-- Todo lo de esta seccion se deshace al final
SAVEPOINT antes_pruebas_paquete;

-- Prueba 1: cupos_disponibles
-- Exito: cupos libres de cada curso
DECLARE
    CURSOR c_cursos IS
        SELECT c.cod_curso, c.cupo_maximo
        FROM TABLA_CURSOS c
        ORDER BY c.cod_curso;
BEGIN
    FOR r IN c_cursos LOOP
        DBMS_OUTPUT.PUT_LINE(r.cod_curso || ' | Cupo: ' || r.cupo_maximo
            || ' | Libres: ' || PKG_GESTION_MATRICULAS.cupos_disponibles(r.cod_curso));
    END LOOP;
END;
/

-- Fallo: el curso no existe
BEGIN
    DBMS_OUTPUT.PUT_LINE(PKG_GESTION_MATRICULAS.cupos_disponibles('XX-999'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Prueba 2: matricular
-- Exito: Valentina Ferreyra (PREGRADO) en BDD-301
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-003', 'BDD-301', '2026-2', 'SIN_BECA', 0, v_cod);
    DBMS_OUTPUT.PUT_LINE('Matricula creada: ' || v_cod);
    DBMS_OUTPUT.PUT_LINE('Cupos en BDD-301: '
        || PKG_GESTION_MATRICULAS.cupos_disponibles('BDD-301'));
END;
/

-- Fallo: Valentina ya esta EN_CURSO en BDD-301
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-003', 'BDD-301', '2026-2', 'SIN_BECA', 0, v_cod);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Fallo: Mateo Quispe es de POSGRADO y BDD-101 es de PREGRADO
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-002', 'BDD-101', '2026-2', 'SIN_BECA', 0, v_cod);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Fallo: el estudiante no existe
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-999', 'BDD-101', '2026-2', 'SIN_BECA', 0, v_cod);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Prueba 3: calcular_avance
-- Exito: Mateo (MAT-2026-0002) aprobo 1 de los 4 modulos de CDD-501
BEGIN
    DBMS_OUTPUT.PUT_LINE('Avance de MAT-2026-0002: '
        || PKG_GESTION_MATRICULAS.calcular_avance('MAT-2026-0002', 1) || '%');
END;
/

-- Fallo: la matricula no existe
BEGIN
    DBMS_OUTPUT.PUT_LINE(PKG_GESTION_MATRICULAS.calcular_avance('MAT-2026-9999', 1));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Prueba 4: registrar_avance
-- Exito: Camila (MAT-2026-0001) aprobo 3 de los 4 modulos de BDD-301
DECLARE
    v_modulos   NUMBER := 3;
    v_avance    TABLA_MATRICULAS.avance_porcentaje%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.registrar_avance('MAT-2026-0001', v_modulos);

    SELECT m.avance_porcentaje INTO v_avance
    FROM TABLA_MATRICULAS m
    WHERE m.cod_matricula = 'MAT-2026-0001';

    DBMS_OUTPUT.PUT_LINE('Modulos guardados: ' || v_modulos || ' | Avance: ' || v_avance || '%');
END;
/

-- Exito con correccion: se envian 5 modulos, pero PRG-102 solo tiene 2
DECLARE
    v_modulos   NUMBER := 5;
    v_avance    TABLA_MATRICULAS.avance_porcentaje%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Modulos enviados: ' || v_modulos);
    PKG_GESTION_MATRICULAS.registrar_avance('MAT-2026-0005', v_modulos);

    SELECT m.avance_porcentaje INTO v_avance
    FROM TABLA_MATRICULAS m
    WHERE m.cod_matricula = 'MAT-2026-0005';

    DBMS_OUTPUT.PUT_LINE('Modulos guardados: ' || v_modulos || ' | Avance: ' || v_avance || '%');
END;
/

-- Fallo: MAT-2026-0003 ya esta APROBADO
DECLARE
    v_modulos   NUMBER := 2;
BEGIN
    PKG_GESTION_MATRICULAS.registrar_avance('MAT-2026-0003', v_modulos);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Prueba 5: dar_de_baja
-- Exito: Camila deja PRG-102 (MAT-2026-0005) y libera un cupo
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    PKG_GESTION_MATRICULAS.dar_de_baja('MAT-2026-0005', v_resultado);
    DBMS_OUTPUT.PUT_LINE(v_resultado);
    DBMS_OUTPUT.PUT_LINE('Cupos en PRG-102: '
        || PKG_GESTION_MATRICULAS.cupos_disponibles('PRG-102'));
END;
/

-- Fallo: MAT-2026-0003 esta APROBADO, no EN_CURSO
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    PKG_GESTION_MATRICULAS.dar_de_baja('MAT-2026-0003', v_resultado);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Fallo: la matricula no existe
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    PKG_GESTION_MATRICULAS.dar_de_baja('MAT-2026-9999', v_resultado);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Se deshacen las pruebas del paquete
ROLLBACK TO antes_pruebas_paquete;


/*
====================================================================
PRUEBAS DEL TRIGGER (CASO EXITOSO Y VIOLACION DE LA REGLA)
====================================================================
*/

/*
    PRG-102 tiene cupo 2 y una matricula EN_CURSO (MAT-2026-0005).
    Se llena el curso y luego se intenta pasar el cupo a proposito.
*/
SAVEPOINT antes_pruebas_trigger;

-- Caso exitoso: Valentina ocupa el ultimo cupo de PRG-102
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-003', 'PRG-102', '2026-2', 'SIN_BECA', 0, v_cod);
    DBMS_OUTPUT.PUT_LINE('Matricula creada: ' || v_cod);
    DBMS_OUTPUT.PUT_LINE('Cupos en PRG-102: '
        || PKG_GESTION_MATRICULAS.cupos_disponibles('PRG-102'));
END;
/

-- Violacion 1: por el paquete (matricular la rechaza antes del INSERT, ORA-20105)
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-002', 'PRG-102', '2026-2', 'SIN_BECA', 0, v_cod);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Violacion 2: INSERT directo saltandose el paquete (lo detiene el trigger)
INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-9001', REF(e), REF(c), '2026-2',
                      SYSDATE, 'SIN_BECA', 0, 0, NULL, 'EN_CURSO')
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-002' AND c.cod_curso = 'PRG-102';

-- Violacion 3: cambio de curso con UPDATE, como el de MAT-2026-0002 en la Semana 3
UPDATE TABLA_MATRICULAS m
   SET m.ref_curso = (SELECT REF(c) FROM TABLA_CURSOS c WHERE c.cod_curso = 'PRG-102')
 WHERE m.cod_matricula = 'MAT-2026-0001';

-- Verificacion: PRG-102 sigue con 2 matriculas y MAT-2026-0001 sigue en BDD-301
SELECT m.cod_matricula,
    DEREF(m.ref_estudiante).nombre_completo() AS estudiante,
    DEREF(m.ref_curso).cod_curso AS curso,
    m.estado
FROM TABLA_MATRICULAS m
ORDER BY m.cod_matricula;

-- Se deshacen las pruebas del trigger
ROLLBACK TO antes_pruebas_trigger;


/*
====================================================================
INTEGRACION CON LOS DATOS REALES DEL AVANCE 1
====================================================================
*/

-- Matriculas del Avance 1 y su avance segun los modulos de su curso
DECLARE
    CURSOR c_matriculas IS
        SELECT m.cod_matricula,
            DEREF(m.ref_estudiante).nombre_completo() AS estudiante,
            DEREF(m.ref_curso).cod_curso AS cod_curso,
            m.estado,
            m.avance_porcentaje
        FROM TABLA_MATRICULAS m
        ORDER BY m.cod_matricula;
BEGIN
    FOR r IN c_matriculas LOOP
        DBMS_OUTPUT.PUT_LINE(r.cod_matricula || ' | ' || r.estudiante || ' | ' || r.cod_curso
            || ' | ' || r.estado || ' | Avance guardado: ' || r.avance_porcentaje
            || '% | 1 modulo equivale a: '
            || PKG_GESTION_MATRICULAS.calcular_avance(r.cod_matricula, 1) || '%');
    END LOOP;
END;
/

-- Cupos de cada curso: matriculas EN_CURSO contra el cupo maximo
DECLARE
    CURSOR c_cursos IS
        SELECT c.cod_curso, c.nombre, c.cupo_maximo
        FROM TABLA_CURSOS c
        ORDER BY c.cod_curso;
    v_libres    NUMBER;
BEGIN
    FOR r IN c_cursos LOOP
        v_libres := PKG_GESTION_MATRICULAS.cupos_disponibles(r.cod_curso);
        DBMS_OUTPUT.PUT_LINE(r.cod_curso || ' | ' || r.nombre
            || ' | En curso: ' || (r.cupo_maximo - v_libres)
            || ' de ' || r.cupo_maximo || ' | Libres: ' || v_libres);
    END LOOP;
END;
/

-- El trigger revisa todas las matriculas reales y ninguna pasa el cupo
UPDATE TABLA_MATRICULAS
SET estado = estado;

ROLLBACK;


/*
====================================================================
VERIFICACION DE NOMBRES (SECCION 5 DE LA GUIA)
====================================================================
*/

DESCRIBE PKG_GESTION_MATRICULAS

SELECT trigger_name, trigger_type, triggering_event, table_name, status
FROM USER_TRIGGERS;


/*
====================================================================
LIMPIEZA
====================================================================
DROP TRIGGER TRG_VALIDA_CUPO_CURSO;
*/
