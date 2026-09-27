/*
    Avance 2 - Semana 1 (v2): especificacion y cuerpo de PKG_GESTION_MATRICULAS
    Caso: EduConecta - Grupo 3
    Se construye sobre el Avance 1

    Los tipos, tablas y datos del Avance 1 se dan por hecho que ya
    estan creados.
*/

SET SERVEROUTPUT ON

/*
====================================================================
SECUENCIA DE MATRICULAS
====================================================================
*/

-- Empieza en 6 porque el Avance 1 ya uso hasta MAT-2026-0005
CREATE SEQUENCE seq_matriculas
START WITH 6
INCREMENT BY 1;


/*
====================================================================
ESPECIFICACION DEL PAQUETE
====================================================================
*/

CREATE OR REPLACE PACKAGE PKG_GESTION_MATRICULAS AS
    -- Matricula a un estudiante en un curso y devuelve el codigo generado
    PROCEDURE matricular(
        p_cod_estudiante    IN  TABLA_ESTUDIANTES.cod_estudiante%TYPE,
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE,
        p_periodo           IN  TABLA_MATRICULAS.periodo%TYPE,
        p_tipo_beca         IN  TABLA_MATRICULAS.tipo_beca%TYPE,
        p_porcentaje_beca   IN  TABLA_MATRICULAS.porcentaje_beca%TYPE,
        p_cod_matricula     OUT TABLA_MATRICULAS.cod_matricula%TYPE);

    -- Da de baja una matricula EN_CURSO (estado BAJA)
    PROCEDURE dar_de_baja(
        p_cod_matricula     IN  TABLA_MATRICULAS.cod_matricula%TYPE,
        p_resultado         OUT VARCHAR2);

    -- Porcentaje de avance segun los modulos aprobados del curso
    FUNCTION calcular_avance(
        p_cod_matricula     IN  TABLA_MATRICULAS.cod_matricula%TYPE,
        p_modulos_aprobados IN  NUMBER)
        RETURN NUMBER;

    -- Guarda el avance calculado y devuelve los modulos corregidos
    PROCEDURE registrar_avance(
        p_cod_matricula     IN     TABLA_MATRICULAS.cod_matricula%TYPE,
        p_modulos_aprobados IN OUT NUMBER);

    -- Cupos libres que le quedan a un curso
    FUNCTION cupos_disponibles(
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE)
        RETURN NUMBER;

    -- Cantidad de modulos de un curso
    FUNCTION total_modulos(
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE)
        RETURN NUMBER;
END PKG_GESTION_MATRICULAS;
/


/*
====================================================================
CUERPO DEL PAQUETE
====================================================================
*/

CREATE OR REPLACE PACKAGE BODY PKG_GESTION_MATRICULAS AS

    FUNCTION total_modulos(
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE)
        RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM TABLA_CURSOS c, TABLE(c.modulos) mo
        WHERE c.cod_curso = p_cod_curso;
        RETURN v_total;
    END;

    FUNCTION cupos_disponibles(
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE)
        RETURN NUMBER IS
        v_cupo      TABLA_CURSOS.cupo_maximo%TYPE;
        v_ocupados  NUMBER;
    BEGIN
        SELECT c.cupo_maximo INTO v_cupo
        FROM TABLA_CURSOS c
        WHERE c.cod_curso = p_cod_curso;

        -- Solo las matriculas EN_CURSO ocupan cupo
        SELECT COUNT(*) INTO v_ocupados
        FROM TABLA_MATRICULAS m
        WHERE DEREF(m.ref_curso).cod_curso = p_cod_curso
        AND m.estado = 'EN_CURSO';

        RETURN v_cupo - v_ocupados;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'El curso no existe');
    END;

    PROCEDURE matricular(
        p_cod_estudiante    IN  TABLA_ESTUDIANTES.cod_estudiante%TYPE,
        p_cod_curso         IN  TABLA_CURSOS.cod_curso%TYPE,
        p_periodo           IN  TABLA_MATRICULAS.periodo%TYPE,
        p_tipo_beca         IN  TABLA_MATRICULAS.tipo_beca%TYPE,
        p_porcentaje_beca   IN  TABLA_MATRICULAS.porcentaje_beca%TYPE,
        p_cod_matricula     OUT TABLA_MATRICULAS.cod_matricula%TYPE) IS
        e_matricula_duplicada   EXCEPTION;
        e_cupo_lleno            EXCEPTION;
        e_nivel_no_coincide     EXCEPTION;
        v_cantidad      NUMBER;
        v_nivel_est     TABLA_ESTUDIANTES.nivel%TYPE;
        v_nivel_curso   TABLA_CURSOS.nivel%TYPE;
    BEGIN
        SELECT COUNT(*) INTO v_cantidad
        FROM TABLA_ESTUDIANTES e
        WHERE e.cod_estudiante = p_cod_estudiante;

        IF v_cantidad = 0 THEN
            RAISE_APPLICATION_ERROR(-20102, 'El estudiante no existe');
        END IF;

        -- No puede tener dos matriculas EN_CURSO en el mismo curso
        SELECT COUNT(*) INTO v_cantidad
        FROM TABLA_MATRICULAS m
        WHERE DEREF(m.ref_estudiante).cod_estudiante = p_cod_estudiante
        AND DEREF(m.ref_curso).cod_curso = p_cod_curso
        AND m.estado = 'EN_CURSO';

        IF v_cantidad > 0 THEN
            RAISE e_matricula_duplicada;
        END IF;

        IF cupos_disponibles(p_cod_curso) <= 0 THEN
            RAISE e_cupo_lleno;
        END IF;

        -- El nivel del curso debe ser el del estudiante (regla del Avance 1)
        SELECT e.nivel INTO v_nivel_est
        FROM TABLA_ESTUDIANTES e
        WHERE e.cod_estudiante = p_cod_estudiante;

        SELECT c.nivel INTO v_nivel_curso
        FROM TABLA_CURSOS c
        WHERE c.cod_curso = p_cod_curso;

        IF v_nivel_est <> v_nivel_curso THEN
            RAISE e_nivel_no_coincide;
        END IF;

        -- LPAD completa con ceros a la izquierda: 6 -> '0006' (formato del Avance 1)
        p_cod_matricula := 'MAT-2026-' || LPAD(seq_matriculas.NEXTVAL, 4, '0');

        INSERT INTO TABLA_MATRICULAS
        SELECT TIPO_MATRICULA(p_cod_matricula, REF(e), REF(c), p_periodo, SYSDATE,
                              p_tipo_beca, p_porcentaje_beca, 0, NULL, 'EN_CURSO')
        FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
        WHERE e.cod_estudiante = p_cod_estudiante AND c.cod_curso = p_cod_curso;
    EXCEPTION
        WHEN e_matricula_duplicada THEN
            RAISE_APPLICATION_ERROR(-20104,
                'El estudiante ya esta matriculado en el curso');
        WHEN e_cupo_lleno THEN
            RAISE_APPLICATION_ERROR(-20105,
                'El curso no tiene cupos disponibles');
        WHEN e_nivel_no_coincide THEN
            RAISE_APPLICATION_ERROR(-20106,
                'El nivel del curso no coincide con el del estudiante');
    END;

    PROCEDURE dar_de_baja(
        p_cod_matricula     IN  TABLA_MATRICULAS.cod_matricula%TYPE,
        p_resultado         OUT VARCHAR2) IS
        e_matricula_no_activa   EXCEPTION;
        v_estado    TABLA_MATRICULAS.estado%TYPE;
    BEGIN
        SELECT m.estado INTO v_estado
        FROM TABLA_MATRICULAS m
        WHERE m.cod_matricula = p_cod_matricula;

        IF v_estado <> 'EN_CURSO' THEN
            RAISE e_matricula_no_activa;
        END IF;

        -- Se cambia el estado en vez de borrar, para no dejar REF colgantes
        UPDATE TABLA_MATRICULAS
        SET estado = 'BAJA'
        WHERE cod_matricula = p_cod_matricula;

        p_resultado := 'Matricula ' || p_cod_matricula || ' dada de baja';
    EXCEPTION
        WHEN e_matricula_no_activa THEN
            RAISE_APPLICATION_ERROR(-20107,
                'La matricula no esta EN_CURSO');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'La matricula no existe');
    END;

    FUNCTION calcular_avance(
        p_cod_matricula     IN  TABLA_MATRICULAS.cod_matricula%TYPE,
        p_modulos_aprobados IN  NUMBER)
        RETURN NUMBER IS
        v_cod_curso TABLA_CURSOS.cod_curso%TYPE;
        v_total     NUMBER;
        v_avance    NUMBER;
    BEGIN
        SELECT DEREF(m.ref_curso).cod_curso INTO v_cod_curso
        FROM TABLA_MATRICULAS m
        WHERE m.cod_matricula = p_cod_matricula;

        v_total := total_modulos(v_cod_curso);
        IF v_total = 0 THEN
            v_avance := 0;
        ELSIF p_modulos_aprobados >= v_total THEN
            v_avance := 100;
        ELSE
            v_avance := TRUNC(p_modulos_aprobados * 100 / v_total, 2);
        END IF;

        RETURN v_avance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'La matricula no existe');
    END;

    PROCEDURE registrar_avance(
        p_cod_matricula     IN     TABLA_MATRICULAS.cod_matricula%TYPE,
        p_modulos_aprobados IN OUT NUMBER) IS
        e_matricula_no_activa   EXCEPTION;
        v_estado    TABLA_MATRICULAS.estado%TYPE;
        v_cod_curso TABLA_CURSOS.cod_curso%TYPE;
        v_total     NUMBER;
        v_avance    NUMBER;
    BEGIN
        SELECT m.estado, DEREF(m.ref_curso).cod_curso INTO v_estado, v_cod_curso
        FROM TABLA_MATRICULAS m
        WHERE m.cod_matricula = p_cod_matricula;

        IF v_estado <> 'EN_CURSO' THEN
            RAISE e_matricula_no_activa;
        END IF;

        -- Si llegan mas modulos de los que tiene el curso, se corrige
        v_total := total_modulos(v_cod_curso);
        IF p_modulos_aprobados > v_total THEN
            p_modulos_aprobados := v_total;
        END IF;

        v_avance := calcular_avance(p_cod_matricula, p_modulos_aprobados);

        UPDATE TABLA_MATRICULAS
        SET avance_porcentaje = v_avance
        WHERE cod_matricula = p_cod_matricula;
    EXCEPTION
        WHEN e_matricula_no_activa THEN
            RAISE_APPLICATION_ERROR(-20107,
                'La matricula no esta EN_CURSO');
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'La matricula no existe');
    END;

END PKG_GESTION_MATRICULAS;
/


/*
====================================================================
PRUEBAS DE LA SEMANA 1
====================================================================
*/

-- Se deshacen al final para no alterar los datos del Avance 1
SAVEPOINT antes_pruebas_semana1;

-- Prueba 1: matricular (exito). Valentina Ferreyra en BDD-301
DECLARE
    v_cod   TABLA_MATRICULAS.cod_matricula%TYPE;
BEGIN
    PKG_GESTION_MATRICULAS.matricular('EST-2026-003', 'BDD-301', '2026-2', 'SIN_BECA', 0, v_cod);
    DBMS_OUTPUT.PUT_LINE('Matricula creada: ' || v_cod);
END;
/

-- Prueba 2: dar_de_baja (fallo). MAT-2026-0003 ya esta APROBADO
DECLARE
    v_resultado VARCHAR2(100);
BEGIN
    PKG_GESTION_MATRICULAS.dar_de_baja('MAT-2026-0003', v_resultado);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error real de Oracle: ' || SQLERRM);
END;
/

-- Prueba 3: calcular_avance (exito). 2 de los 4 modulos de BDD-301
BEGIN
    DBMS_OUTPUT.PUT_LINE('Avance de MAT-2026-0001: '
        || PKG_GESTION_MATRICULAS.calcular_avance('MAT-2026-0001', 2) || '%');
END;
/

ROLLBACK TO antes_pruebas_semana1;


/*
====================================================================
LIMPIEZA
====================================================================
DROP PACKAGE PKG_GESTION_MATRICULAS;
DROP SEQUENCE seq_matriculas;
*/
