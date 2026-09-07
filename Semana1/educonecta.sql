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
