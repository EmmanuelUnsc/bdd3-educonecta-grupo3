# Guía de estudio — Proyecto Integrador, Avance 1

**Caso EduConecta · Base de Datos III (BDD3T4) · Unidad 1: Bases de Datos Objeto-Relacionales · Grupo 3**

Julio Cruz Kübber · Diego Gorostiaga Gonzales · Dario Tambo Parra · Josue Soliz Mamani

---

Este documento cubre las tres semanas del avance de punta a punta: qué pidió el docente, qué construimos, qué hace cada línea de código y por qué se eligió así. Arranca desde cero: no hace falta haber seguido el desarrollo para entenderlo.

**Si tenés poco tiempo**, leé en este orden: la **Parte A** para saber de qué se trata, la **Parte F** para saber qué te pueden preguntar que no viste en clase, y la sección de la **Parte H** que te toca a vos. Las Partes C, D y E son la referencia técnica completa, para consultar.

## Contenido

| | |
|---|---|
| [Parte A](#parte-a--qué-es-este-trabajo-y-qué-se-entrega) | Qué es este trabajo y qué se entrega |
| [Parte B](#parte-b--por-qué-objeto-relacional) | Por qué objeto-relacional: las cinco ideas del modelo |
| [Parte C](#parte-c--semana-1-los-tipos-de-objeto) | Semana 1 — Los tipos de objeto |
| [Parte D](#parte-d--semana-2-tablas-de-objetos-colecciones-y-referencias) | Semana 2 — Tablas de objetos, colecciones y referencias |
| [Parte E](#parte-e--semana-3-integración-y-verificación) | Semana 3 — Integración y verificación |
| [Parte F](#parte-f--qué-viene-de-clase-y-qué-agregamos-por-encima) | Qué viene de clase y qué agregamos por encima |
| [Parte G](#parte-g--glosario) | Glosario |
| [Parte H](#parte-h--la-defensa-oral-repartida-en-cuatro) | La defensa oral, repartida en cuatro |

---

# Parte A — Qué es este trabajo y qué se entrega

## A.1 El encargo, en una página

La Unidad 1 de la materia trata bases de datos objeto-relacionales en Oracle. El Proyecto Integrador reparte siete casos de negocio entre los grupos; al Grupo 3 le tocó **EduConecta**. La consigna es actuar como el equipo de Ingeniería de Datos contratado para diseñar e implementar el núcleo transaccional del sistema.

La guía del docente no trae la solución: trae el contexto, el problema, el modelo de datos esperado —qué estructuras deben existir, no cómo escribirlas— y quince actividades repartidas en tres semanas. El diseño concreto es responsabilidad del equipo, y hay que justificarlo por escrito. Todo cierra en el **Encuentro 8** con una defensa oral de 10 a 15 minutos con preguntas individuales.

## A.2 El caso y la Pregunta Rectora

EduConecta es una plataforma de educación superior a distancia con sedes virtuales en tres países —Bolivia, Perú y Argentina— que ofrece programas de pregrado y de posgrado. Su catálogo de cursos tiene estructura variable, la lógica de becas y matrícula es cada vez más compleja, y la institución necesita seguimiento en tiempo real del avance estudiantil y analítica de rendimiento académico.

Todo el trabajo se juzga contra esta pregunta, que conviene poder citar de memoria:

> «¿Cómo diseñar una plataforma de datos que permita a EduConecta gestionar matrículas y becas de forma confiable, alojar contenido educativo de estructura variable, dar seguimiento en tiempo real al avance de los estudiantes y analizar el rendimiento académico institucional?»

Fijate que enuncia **cuatro exigencias distintas**, no una. Cada decisión de diseño del proyecto responde a alguna de esas cuatro, y ésa es siempre una forma válida de empezar a contestar cualquier pregunta del comité.

## A.3 Las quince actividades y lo que produjeron

| Sem. | Actividades | Qué produjo |
|---|---|---|
| **1** | 1 a 6: discutir atributos, redactar el documento de modelado, crear el tipo anidado y el principal, el constructor validado, el método propio, y verificar con `DESCRIBE`. | `educonecta.sql`<br>Documento de modelado (3 pág.)<br>2 capturas |
| **2** | 7 a 11: tabla de objetos principal, elegir y justificar la colección, tabla transaccional conectada por `REF`, tres filas de prueba en cada tabla, y las cuatro operaciones CRUD. | `educonecta_semana2.sql`<br>Documento de Semana 2<br>4 capturas |
| **3** | 12 a 15: informe final de integración, verificar la consistencia de los datos, completar la Lista de Verificación, y ensayar la defensa oral. | `educonecta_semana3.sql`<br>Informe final (5 pág.) |

> **Ojo con la Sección 7.** La tabla de entregables del docente pide script SQL y export de datos solo para las Semanas 1 y 2. Para la **Semana 3 hay un solo archivo que entregar**: el *informe final de integración* (máximo 5 páginas). La otra fila, «Defensa oral», describe el formato del acto —una exposición de 10 a 15 minutos con preguntas individuales— y se rinde en vivo en el Encuentro 8, no se sube. El script de verificación y sus capturas tampoco son entregables formales; el script sí debe estar versionado en el repositorio Git del equipo, porque es el punto 11 de la Lista de Verificación.

## A.4 Cómo se evalúa

Hay dos instrumentos, y los dos están en la guía del docente:

- **La Lista de Verificación (Sección 9).** Once puntos que el equipo debe poder marcar afirmativamente antes de presentarse. Están respondidos uno por uno en la Tabla 3 del informe final.
- **Las Preguntas para la Defensa (Sección 10).** Cinco preguntas técnicas más una sexta individual y distinta para cada integrante: *«explique, en sus propias palabras, la parte específica que usted implementó directamente»*. Esa última no se puede preparar de memoria.

---

# Parte B — Por qué objeto-relacional

## B.1 El problema que resuelve

En un modelo relacional puro, todo son tablas planas de columnas simples unidas por claves foráneas. Funciona, pero obliga a partir en pedazos cosas que en el negocio son una sola: una dirección se desarma en tres columnas, una lista de módulos exige una tabla aparte, y para volver a armar el objeto hay que escribir `JOIN` cada vez.

El modelo objeto-relacional de Oracle agrega tres capacidades sobre el relacional: **definir tipos propios con comportamiento**, **guardar colecciones dentro de una fila**, y **apuntar a un objeto con un puntero real** en lugar de copiar su clave. Eso es lo que ejercita esta unidad.

## B.2 Las cinco ideas que hay que tener claras

| Idea | En una frase | Dónde aparece |
|---|---|---|
| **Tipo de objeto** | Una plantilla con atributos y métodos, como una clase. Se crea con `CREATE TYPE` y se usa como si fuera un tipo de dato más. | `TIPO_DIRECCION`, `TIPO_ESTUDIANTE` |
| **Objeto anidado** | Un atributo cuyo tipo es a su vez un tipo de objeto: el objeto vive adentro de otro. | `direccion` dentro de `TIPO_ESTUDIANTE` |
| **Tabla de objetos** | Una tabla donde cada fila es un objeto completo y tiene identidad propia (OID). Se crea con `CREATE TABLE ... OF`. | Las tres tablas |
| **Referencia (REF)** | Un puntero persistente a un objeto de una tabla de objetos. Se navega con `DEREF` en lugar de reunir por clave. | `TABLA_MATRICULAS`, prerrequisitos |
| **Colección** | Varios valores guardados dentro de una sola fila: `VARRAY` si el máximo está fijo, Nested Table si no. | `modulos`, `prerrequisitos` |

> **En una frase:** el modelo guarda objetos con comportamiento, colecciones dentro de la fila, y punteros entre objetos. Si entendés esas tres cosas, entendés todo el avance.

---

# Parte C — Semana 1: los tipos de objeto

*Archivo: `Semana1/educonecta.sql`*

## C.1 Qué pedía

Crear primero el tipo anidado y después el principal que lo contiene; implementar un constructor con al menos una validación de negocio y un método propio; verificar con `DESCRIBE`. Nada más: **la Semana 1 no crea ni una sola tabla.**

## C.2 TIPO_DIRECCION, el objeto anidado

```sql
CREATE OR REPLACE TYPE TIPO_DIRECCION AS OBJECT (
    calle   VARCHAR2(120 CHAR),
    ciudad  VARCHAR2(60 CHAR),
    pais    VARCHAR2(40 CHAR),
    CONSTRUCTOR FUNCTION TIPO_DIRECCION(p_calle VARCHAR2, p_ciudad VARCHAR2,
                                        p_pais VARCHAR2) RETURN SELF AS RESULT,
    MEMBER FUNCTION formato_texto RETURN VARCHAR2
);
```

| Parte | Qué hace y por qué |
|---|---|
| `AS OBJECT` | Declara un tipo de objeto, no una tabla. Es solo la plantilla: todavía no existe ningún dato. |
| `VARCHAR2(120 CHAR)` | El `CHAR` indica que el límite se cuenta en caracteres y no en bytes. Importa porque las tildes y la ñ ocupan más de un byte en UTF-8. |
| `CONSTRUCTOR FUNCTION` | Reemplaza al constructor por defecto. Como recibe tres parámetros para tres atributos, **comparte su firma y lo sustituye**: no queda forma de crear una dirección sin pasar por la validación. |
| `RETURN SELF AS RESULT` | Sintaxis obligatoria del constructor: devuelve la propia instancia que acaba de construir. |
| `MEMBER FUNCTION` | Un método del tipo. Se invoca con notación de punto sobre el objeto. |

### El cuerpo: dónde está la validación

```sql
v_pais := TRANSLATE(UPPER(TRIM(p_pais)), 'ÁÉÍÓÚÜÑ', 'AEIOUUN');

IF v_pais IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'El pais es obligatorio.');
END IF;
IF v_pais NOT IN ('BOLIVIA', 'PERU', 'ARGENTINA') THEN
    RAISE_APPLICATION_ERROR(-20002, 'Pais no habilitado: ' || p_pais);
END IF;

SELF.calle := p_calle;  SELF.ciudad := p_ciudad;  SELF.pais := v_pais;
RETURN;
```

| Parte | Qué hace y por qué |
|---|---|
| `TRIM` / `UPPER` | Quitan espacios sobrantes y pasan a mayúsculas, para que `« peru »` y `«PERU»` sean lo mismo. |
| `TRANSLATE` | Cambia carácter por carácter: la Á se vuelve A, la É se vuelve E. Es lo que convierte «Perú» en «PERU». Sin esto serían dos sedes distintas al agrupar. |
| `RAISE_APPLICATION_ERROR` | Aborta la creación del objeto con un error propio. Los números entre −20000 y −20999 están reservados para errores definidos por el usuario. |
| `SELF.pais := v_pais` | Guarda el valor **ya normalizado**, no el que llegó. Por eso en la base queda `PERU` aunque el `INSERT` diga `'Perú'`. |

El método propio centraliza el formato de salida dentro del tipo, para que un cambio de presentación no obligue a tocar las consultas:

```sql
RETURN calle || ', ' || ciudad || ', ' || pais;
```

## C.3 TIPO_ESTUDIANTE, el tipo principal

Tiene trece atributos. El que importa para esta unidad es el octavo:

```sql
direccion  TIPO_DIRECCION,   -- un tipo de objeto usado como tipo de dato
```

Su constructor valida el nivel académico (`PREGRADO` o `POSGRADO`) y sus métodos son tres:

| Método | Qué hace | Por qué está |
|---|---|---|
| `nombre_completo()` | Devuelve `apellidos \|\| ', ' \|\| nombres` | Centraliza el orden de los listados institucionales en un solo lugar. |
| `edad()` | `FLOOR(MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12)` | La edad se **calcula, no se almacena**: un valor guardado queda viejo al día siguiente del cumpleaños. |
| `clave_orden()`<br>`MAP MEMBER` | Devuelve `cod_estudiante` | Da a Oracle un valor escalar para comparar y ordenar **objetos completos** del tipo. |

> **Precisión que suma en la defensa:** el `MAP` hace falta para comparar y ordenar objetos enteros. Sobre un atributo suelto —ordenar por apellido, por ejemplo— Oracle ordena sin él. Decirlo con esa precisión es mejor que la versión general.

## C.4 La verificación con DESCRIBE

`DESCRIBE` lista la estructura de un tipo: sus atributos y sus métodos. Es la evidencia que pide la actividad 6 y lo que muestran las dos capturas de la Semana 1.

```sql
DESCRIBE TIPO_DIRECCION
DESCRIBE TIPO_ESTUDIANTE
```

---

# Parte D — Semana 2: tablas de objetos, colecciones y referencias

*Archivo: `Semana2/educonecta_semana2.sql`*

## D.1 La tabla de objetos, y por qué no una columna de tipo objeto

```sql
CREATE TABLE TABLA_ESTUDIANTES OF TIPO_ESTUDIANTE (
    cod_estudiante PRIMARY KEY
);
```

Oracle admite dos formas de guardar objetos: una tabla relacional con una columna de tipo objeto, o una tabla de objetos declarada con `CREATE TABLE ... OF`, donde cada fila es en sí misma un objeto.

Elegimos la segunda **por una razón funcional, no estética**: `REF()` opera únicamente sobre filas de tablas de objetos, porque solo esas tienen un identificador de objeto (OID) referenciable. Sobre una columna de tipo objeto la sentencia ni siquiera se ejecuta. Como el modelo exige que la matrícula apunte al estudiante con `REF`, cualquier otro patrón vuelve el requerimiento inalcanzable.

Además, en una tabla de objetos los atributos del tipo se comportan como columnas y admiten restricciones sobre ellos. Por eso la clave primaria es `cod_estudiante`, un identificador que ya existe en el negocio, sin inventar una clave técnica.

## D.2 Las colecciones del catálogo

### Los módulos: Nested Table de objetos

```sql
CREATE OR REPLACE TYPE TIPO_MODULO AS OBJECT (
    nro_orden NUMBER(3), titulo VARCHAR2(100 CHAR),
    horas_academicas NUMBER(4), tipo_contenido VARCHAR2(20 CHAR) );

CREATE OR REPLACE TYPE TIPO_MODULOS_TAB AS TABLE OF TIPO_MODULO;
```

El criterio de elección es el de clase: **si el límite superior de la colección lo fija una regla de negocio, corresponde `VARRAY`; si depende del crecimiento de los datos, corresponde Nested Table.** Los módulos caen del segundo lado, porque el enunciado describe un catálogo de estructura variable que crece al publicarse contenido y un curso puede reestructurarse entre versiones del plan. Con `VARRAY` habría que fijar un tope arbitrario y recrear el tipo al excederlo.

| | VARRAY | Nested Table |
|---|---|---|
| **Tamaño** | Máximo fijo, declarado | Sin límite |
| **Almacenamiento** | En línea con la fila | Fuera de línea, en su propio segmento (`STORE AS`) |
| **Orden** | Se conserva | No garantizado |
| **DML** | Se reemplaza entera | Se puede modificar un elemento suelto con `TABLE()` |

> **El razonamiento inverso, que conviene tener listo:** si el atributo variable hubiera sido la lista de modalidades habilitadas por la institución —un conjunto cerrado de tres valores donde además el orden expresa preferencia—, el `VARRAY` habría sido lo correcto. En nuestro modelo la modalidad es un atributo escalar, precisamente porque no es variable.

### Los prerrequisitos: Nested Table de referencias

Un prerrequisito no es un dato del curso: es una **relación con otro curso** del mismo catálogo. Por eso no se guarda el código copiado sino un `REF`, que se navega con `DEREF`.

```sql
CREATE TYPE TIPO_CURSO;                    -- declaración incompleta
/
CREATE OR REPLACE TYPE TIPO_PRERREQUISITOS_TAB AS TABLE OF REF TIPO_CURSO;
/
CREATE OR REPLACE TYPE TIPO_CURSO AS OBJECT ( ... );
```

Esa primera línea suelta es **obligatoria**: `TIPO_PRERREQUISITOS_TAB` referencia a `TIPO_CURSO` y `TIPO_CURSO` contiene a `TIPO_PRERREQUISITOS_TAB`. Hay una dependencia circular, y Oracle la resuelve declarando primero el tipo de forma incompleta. Sin esa línea el script no compila.

```sql
CREATE TABLE TABLA_CURSOS OF TIPO_CURSO ( cod_curso PRIMARY KEY )
NESTED TABLE modulos        STORE AS cursos_modulos_tab
NESTED TABLE prerrequisitos STORE AS cursos_prerrequisitos_tab;
```

`STORE AS` nombra el segmento físico donde se guarda cada colección. Es obligatorio para las Nested Table y es lo que las mantiene fuera de la fila del curso.

## D.3 La tabla transaccional

```sql
CREATE TABLE TABLA_MATRICULAS OF TIPO_MATRICULA (
    cod_matricula  PRIMARY KEY,
    ref_estudiante SCOPE IS TABLA_ESTUDIANTES,
    ref_curso      SCOPE IS TABLA_CURSOS
);
```

| Concepto | Qué hace | Qué **NO** hace |
|---|---|---|
| `REF` | Guarda un puntero al objeto, no una copia de su clave. Se navega con `DEREF` y no hace falta ningún `JOIN`. | No copia datos: si el estudiante cambia de apellido, la matrícula lo ve al instante. |
| `SCOPE IS` | Fija a qué tabla puede apuntar la referencia. Reduce su tamaño físico e impide apuntar a la tabla equivocada. | **No es una clave foránea.** Si se borra la fila apuntada, la referencia sobrevive apuntando a un OID inexistente. |

La matrícula guarda además periodo, tipo de beca, porcentaje, avance y nota final: datos que son **de la relación** y no pertenecen ni al estudiante ni al curso. El mismo estudiante tiene una nota distinta en cada curso.

## D.4 Los datos de prueba y las consultas de verificación

Los objetos se insertan **siempre invocando el constructor** del tipo, nunca columna por columna, para que las validaciones de la Semana 1 se ejecuten. Las referencias se toman con `REF()` sobre las tablas de destino:

```sql
INSERT INTO TABLA_MATRICULAS
SELECT TIPO_MATRICULA('MAT-2026-0001', REF(e), REF(c), '2026-2', ...)
FROM TABLA_ESTUDIANTES e, TABLA_CURSOS c
WHERE e.cod_estudiante = 'EST-2026-001' AND c.cod_curso = 'BDD-301';
```

Y los prerrequisitos se pueblan convirtiendo un conjunto de referencias en una colección:

```sql
UPDATE TABLA_CURSOS c
   SET c.prerrequisitos = CAST(MULTISET(
           SELECT REF(p) FROM TABLA_CURSOS p
           WHERE p.cod_curso IN ('BDD-101', 'PRG-102')
       ) AS TIPO_PRERREQUISITOS_TAB)
 WHERE c.cod_curso = 'BDD-301';
```

`MULTISET` junta las filas de la subconsulta en un conjunto y `CAST` lo convierte al tipo de colección declarado. Es la forma estándar de llenar una Nested Table a partir de una consulta.

### Las tres formas de leer que hay que reconocer

```sql
-- 1. Notación de punto sobre el objeto anidado y llamada a un método
SELECT e.cod_estudiante, e.nombre_completo(), e.edad(), e.direccion.ciudad
  FROM TABLA_ESTUDIANTES e;

-- 2. Navegación por referencia, sin JOIN
SELECT m.cod_matricula, DEREF(m.ref_estudiante).apellidos,
       DEREF(m.ref_curso).nombre
  FROM TABLA_MATRICULAS m;

-- 3. Aplanado de la colección, para listar y para agregar
SELECT c.cod_curso, COUNT(*), SUM(m.horas_academicas)
  FROM TABLA_CURSOS c, TABLE(c.modulos) m
 GROUP BY c.cod_curso;
```

> **Sobre `COLUMN_VALUE`:** cuando la Nested Table es de objetos, sus elementos tienen atributos con nombre (`m.horas_academicas`). Cuando es de tipo escalar —como la colección de `REF`— no hay nombres, y Oracle expone el elemento con la pseudo-columna `COLUMN_VALUE`. Por eso los prerrequisitos se leen con `DEREF(p.COLUMN_VALUE).cod_curso`.

## D.5 Las cuatro operaciones CRUD

| Operación | Lo que se ejercitó sobre el esquema |
|---|---|
| **CREATE** | Alta de un estudiante con el constructor; alta de un módulo dentro de una colección ya existente con `INSERT INTO TABLE(...)`; alta de una matrícula que toma sus dos referencias con `REF()`. |
| **READ** | Las tres formas de lectura de arriba: notación de punto y métodos, navegación con `DEREF`, y aplanado con `TABLE()` en listado y en agregación. |
| **UPDATE** | Un atributo simple; un atributo dentro del objeto anidado; y un elemento suelto de la Nested Table sin reescribir la colección. |
| **DELETE** | Baja de un elemento de la colección; baja de una fila completa; y la comprobación del riesgo de integridad con `IS DANGLING` entre `SAVEPOINT` y `ROLLBACK TO`. |

> **Detalle que puede caer:** para modificar un atributo dentro del objeto anidado hace falta **alias de tabla**. Esto falla:
> `UPDATE TABLA_ESTUDIANTES SET direccion.calle = ...`
> Esto funciona:
> `UPDATE TABLA_ESTUDIANTES e SET e.direccion.calle = ...`

## D.6 La prueba de IS DANGLING

```sql
SAVEPOINT antes_de_prueba_dangling;
DELETE FROM TABLA_ESTUDIANTES WHERE cod_estudiante = 'EST-2026-003';

SELECT m.cod_matricula FROM TABLA_MATRICULAS m
 WHERE m.ref_estudiante IS DANGLING;

ROLLBACK TO SAVEPOINT antes_de_prueba_dangling;
```

Oracle **no propaga la eliminación a través de un `REF`**. La matrícula sobrevive apuntando a un OID que ya no existe, y `DEREF` devuelve `NULL` sin lanzar error: el problema no se manifiesta al ocurrir sino al emitir un reporte, que es el peor momento posible. `SAVEPOINT` marca un punto de la transacción y `ROLLBACK TO` vuelve a él, de modo que la prueba no deja rastro.

---

# Parte E — Semana 3: integración y verificación

*Archivos: `Semana3/educonecta_semana3.sql` (entrega) y `..._comentado.sql` (estudio)*

## E.1 Qué pedía

Cuatro cosas: el informe final de integración explicando cómo el esquema resuelve la Pregunta Rectora; verificar que los datos son consistentes entre todas las estructuras, es decir que **los mismos identificadores aparezcan correctamente en ambas tablas**; completar la Lista de Verificación; y ensayar la defensa.

## E.2 La ampliación del catálogo

EduConecta ofrece pregrado y posgrado, pero el catálogo tenía solo cursos de pregrado. La Semana 3 incorpora **CDD-501**, «Modelado de Datos para Ciencia de Datos» (POSGRADO, 6 créditos, 4 módulos, prerrequisito BDD-101), matricula ahí al estudiante de maestría y agrega una segunda matrícula para que ningún curso quede sin inscriptos.

Tiene un valor argumental además del práctico: el catálogo absorbió un curso nuevo, con su colección y su referencia, **sin tocar ni un tipo ni una consulta**. Es la demostración de que la estructura variable funciona.

> **Regla que quedó fijada:** un estudiante solo se matricula en cursos de su mismo nivel académico. No se admiten matrículas de nivelación. Es una decisión del equipo, no del enunciado, y el bloque 7 del script la comprueba.

## E.3 Las comprobaciones

El script hace ocho comprobaciones, cada una con una consulta suelta. No hay vista, ni subconsultas anidadas, ni nada que no se haya visto en clase.

| # | Comprobación | Cómo | Resultado |
|---|---|---|---|
| 1 | Filas en cada estructura | `COUNT(*)` | 3 · 4 · 4 · 13 · 3 |
| 2 | **Los mismos identificadores en ambas tablas** | `DEREF` + reunión por `REF(e)` | Coinciden en las 4 matrículas |
| 3 | Referencias colgantes | `IS DANGLING` | Ninguna |
| 4 | Prerrequisitos resueltos | `TABLE()` + `DEREF(p.COLUMN_VALUE)` | Los 3 hacia cursos existentes |
| 5 | Colección de módulos poblada | `TABLE()` + `GROUP BY` | 64 · 80 · 82 · 54 horas |
| 6 | Validaciones del constructor vigentes | notación de punto | «Perú» guardado como `PERU` |
| 7 | Nivel del curso vs nivel del estudiante | `DEREF` | Coinciden en las 4 matrículas |
| 8 | Riesgo de integridad | `SAVEPOINT` + `IS DANGLING` + `ROLLBACK TO` | Reproducido y revertido |

La número 2 es **la que pide literalmente la actividad 13**. Las otras siete son el mismo tipo de comprobación aplicada al resto de las estructuras.

### La consulta central

```sql
SELECT m.cod_matricula,
       DEREF(m.ref_estudiante).cod_estudiante AS id_por_referencia,
       e.cod_estudiante                       AS id_en_tabla,
       DEREF(m.ref_curso).cod_curso           AS curso_por_referencia,
       c.cod_curso                            AS curso_en_tabla
  FROM TABLA_MATRICULAS m, TABLA_ESTUDIANTES e, TABLA_CURSOS c
 WHERE m.ref_estudiante = REF(e)
   AND m.ref_curso      = REF(c)
 ORDER BY m.cod_matricula;
```

Lo importante de entender: **las tablas se reúnen por igualdad de referencias**, no comparando códigos. El `WHERE m.ref_estudiante = REF(e)` dice «traeme el estudiante al que esta matrícula apunta». Recién después, en el `SELECT`, se muestran los dos identificadores lado a lado para que se vea que son el mismo. Si una referencia apuntara a otro objeto, las dos columnas no coincidirían.

## E.4 La prueba del riesgo de integridad

El último bloque reproduce lo que `SCOPE IS` **no** protege:

```sql
SAVEPOINT antes_de_prueba_dangling;
DELETE FROM TABLA_ESTUDIANTES WHERE cod_estudiante = 'EST-2026-003';

SELECT m.cod_matricula, m.periodo, m.estado FROM TABLA_MATRICULAS m
 WHERE m.ref_estudiante IS DANGLING;              -- aparece MAT-2026-0003

SELECT m.cod_matricula, DEREF(m.ref_estudiante).apellidos
  FROM TABLA_MATRICULAS m;                        -- el apellido sale vacío, sin error

ROLLBACK TO SAVEPOINT antes_de_prueba_dangling;
```

Las dos consultas del medio muestran las dos caras del problema: la matrícula sigue ahí pero su referencia quedó colgante, y `DEREF` devuelve `NULL` **sin lanzar error**. Por eso el problema no se nota al ocurrir sino al emitir un reporte. El `ROLLBACK TO` deja todo como estaba.

## E.5 Los números finales

| Estructura | Filas |
|---|---|
| `TABLA_ESTUDIANTES` | 3 |
| `TABLA_CURSOS` | 4 |
| `TABLA_MATRICULAS` | 4 |
| `modulos` (colección anidada) | 13 |
| `prerrequisitos` (colección de REF) | 3 |
| **Carga horaria** | BDD-101 → 64 h · BDD-301 → 80 h · CDD-501 → 82 h · PRG-102 → 54 h |
| **Verificación** | Las 8 comprobaciones del script, todas correctas |

---

# Parte F — Qué viene de clase y qué agregamos por encima

Esta parte existe por una razón práctica: **si en la defensa aparece código que nadie del equipo puede explicar, se nota.** Acá está separado lo que la guía del docente respalda explícitamente de lo que el equipo agregó por decisión propia.

## F.1 Respaldado por la guía del docente

La guía nombra estos temas con su encuentro o laboratorio, así que son terreno firme:

| Construcción | Dónde lo respalda la guía |
|---|---|
| `CREATE TYPE`, objeto anidado, constructor validado, método propio | Actividades 3 a 5, «la sintaxis ya practicada en el Encuentro 1» |
| `DESCRIBE` | Actividad 6 |
| `CREATE TABLE ... OF` con `PRIMARY KEY` | Actividad 7, «la sintaxis del Encuentro 3» |
| `VARRAY` vs Nested Table y su justificación | Actividad 8, «el criterio de tamaño acotado vs. no acotado ya visto en clase» |
| `REF` y tabla transaccional | Actividad 9 y Sección 5 del modelo esperado |
| Las cuatro operaciones CRUD | Actividad 11, «Tema 1.6, tal como se trabajó en el Laboratorio 2» |
| `DEREF` y `TABLE()` | Tabla de entregables de la Semana 2 |
| `IS DANGLING` | Lista de Verificación, Sección 9 |

## F.2 Agregado del equipo, por encima de lo pedido

Nada de esto está mal, pero conviene saber que es nuestro y tener la explicación lista:

| Construcción | Dónde aparece | Cómo se justifica si preguntan |
|---|---|---|
| `MAP MEMBER FUNCTION` | `TIPO_ESTUDIANTE` | Sin un método MAP, Oracle no puede comparar ni ordenar objetos completos del tipo, y la analítica por estudiante queda fuera de alcance. |
| `SCOPE IS` | `TABLA_MATRICULAS` | La guía pide `REF`; `SCOPE IS` lo refina acotando el destino. Reduce el tamaño de la referencia e impide apuntar a la tabla equivocada. |
| Declaración incompleta `CREATE TYPE TIPO_CURSO;` | Semana 2 | No es opcional: los prerrequisitos como `REF` crean una dependencia circular que Oracle solo resuelve así. |
| `CAST(MULTISET(...))` | Prerrequisitos | Es la forma estándar de poblar una Nested Table a partir de una consulta. |
| `SAVEPOINT` / `ROLLBACK TO` | Semanas 2 y 3 | Permite probar el riesgo de las referencias sin dejar la base alterada. |
| Las comprobaciones 5, 6 y 7 del script | Semana 3 | La actividad 13 pide solo la número 2. Las demás aplican la misma idea al resto de las estructuras y no usan nada que no esté en la lista de arriba. |

> **Si el comité pregunta por qué ocho y no una:** la actividad pide verificar la consistencia *entre todas las estructuras del esquema*. La número 2 cubre las dos tablas unidas por `REF`; las otras cubren las dos colecciones anidadas y los dominios del constructor, que también son estructuras del esquema.

---

# Parte G — Glosario

| Término | Definición |
|---|---|
| **Tipo de objeto** | Plantilla con atributos y métodos, como una clase. Se crea con `CREATE TYPE`. |
| **Objeto anidado** | Atributo cuyo tipo es a su vez un tipo de objeto. |
| **Constructor** | Función que crea una instancia del tipo. Con la misma firma que el constructor por defecto, lo reemplaza y no queda vía de alta sin validar. |
| **MEMBER FUNCTION** | Método propio del tipo, invocable con notación de punto sobre el objeto. |
| **MAP MEMBER** | Método que devuelve un escalar por el cual Oracle compara y ordena objetos completos del tipo. |
| **Tabla de objetos** | Tabla creada con `CREATE TABLE ... OF`: cada fila es un objeto y tiene OID. |
| **OID** | Identificador interno único de un objeto en una tabla de objetos. Es lo que apunta un `REF`. |
| **REF** | Puntero persistente a un objeto de una tabla de objetos. |
| **DEREF** | Operación inversa: a partir de un `REF` devuelve el objeto apuntado. |
| **SCOPE IS** | Restricción que fija a qué tabla de objetos puede apuntar una columna `REF`. |
| **IS DANGLING** | Predicado que detecta una referencia que apunta a un objeto ya eliminado. |
| **VARRAY** | Colección de tamaño máximo fijo, almacenada en línea, que se reemplaza entera. |
| **Nested Table** | Colección sin límite superior, almacenada fuera de línea, con DML por elemento. |
| **STORE AS** | Cláusula que nombra el segmento donde se guarda una Nested Table. |
| **TABLE()** | Operador que aplana una colección para tratarla como filas en una consulta. |
| **COLUMN_VALUE** | Pseudo-columna con la que Oracle expone los elementos de una Nested Table de tipo escalar, como una colección de `REF`. |
| **MULTISET** | Operador que junta las filas de una subconsulta en un conjunto, para convertirlo en colección con `CAST`. |
| **SAVEPOINT** | Marca dentro de una transacción a la que se puede volver con `ROLLBACK TO`. |
| **RAISE_APPLICATION_ERROR** | Lanza un error propio, con número entre −20000 y −20999. |

---

# Parte H — La defensa oral, repartida en cuatro

Cada uno defiende lo que implementó. La pregunta 6 de la Sección 10 es individual y distinta para cada integrante, así que no se puede cubrir con una respuesta aprendida.

## H.1 Julio — el objeto anidado y el constructor

*Preguntas 1 y 2 de la Sección 10.*

**Las ideas que hay que poder decir con palabras propias**

- **Por qué anidar.** Calle, ciudad y país forman una unidad de sentido: se crean, se leen y se validan siempre juntos. Encapsularlas hace que la validación y el formato viajen con el dato hacia cualquier estructura que lo contenga.
- **Por qué no una tabla aparte.** La dirección no tiene identidad propia: no se consulta ni se comparte por sí sola. Es un atributo compuesto, no una entidad.
- **Qué protege la validación.** Que solo se registren estudiantes de las tres sedes donde EduConecta opera. Sin ella el dato sucio recién aparecería al emitir el reporte.
- **Por qué normalizar.** Para que «Perú», «peru» y «PERU» sean un mismo valor. Sin eso serían tres sedes distintas al agrupar.

**Preguntas trampa**

- *¿No podían usar un `CHECK` en la tabla?* — Sí, pero la regla quedaría atada a esa tabla; en el constructor viaja con el tipo.
- *¿No queda una puerta trasera con el constructor por defecto?* — No: comparte su firma y lo sustituye.
- *¿Y si abren sede en Chile?* — Hay que modificar y recompilar el cuerpo del tipo. Es el costo de tener la regla en el código; a cambio no puede saltearse.

## H.2 Diego — el tipo principal, la tabla de objetos y la verificación

*Preguntas 2 y 6 de la Sección 10.*

**Las ideas que hay que poder decir con palabras propias**

- **Por qué tabla de objetos.** `REF()` solo opera sobre filas con OID, y solo las tablas `CREATE TABLE ... OF` lo tienen. Con una columna de tipo objeto el requerimiento es inalcanzable.
- **Por qué esa clave primaria.** `cod_estudiante` ya existe en el negocio; evita una clave técnica artificial.
- **Por qué `edad()` se calcula.** Un valor almacenado queda viejo al día siguiente del cumpleaños.
- **Qué agrega la verificación.** El constructor valida en el alta pero no en un `UPDATE`, y `SCOPE IS` no impide que desaparezca el objeto apuntado. Los controles cubren ese hueco.

**Preguntas trampa**

- *¿No se puede ordenar por apellido sin `MAP`?* — Sí se puede; el `MAP` hace falta para objetos completos. Decirlo con esa precisión.
- *¿Por qué ocho comprobaciones y no una?* — La actividad pide verificar entre **todas** las estructuras. Una cubre las tablas unidas por `REF`; las otras, las dos colecciones anidadas y los dominios del constructor.
- *¿Cómo saben que la comprobación no es complaciente?* — Por el bloque 8: al borrar un estudiante dentro de un `SAVEPOINT`, la referencia queda colgante y `DEREF` devuelve `NULL`. El `ROLLBACK TO` lo revierte.

## H.3 Dario — las colecciones del catálogo

*Preguntas 5 y 6 de la Sección 10.*

**Las ideas que hay que poder decir con palabras propias**

- **El criterio.** Máximo fijado por regla de negocio, `VARRAY`. Dependiente del crecimiento de los datos, Nested Table.
- **Por qué los módulos.** Catálogo de estructura variable, sin cota conocida. Un `VARRAY` obligaría a fijar un tope arbitrario y recrear el tipo al excederlo.
- **Las dos ventajas operativas.** Almacenamiento fuera de línea con `STORE AS`, y DML sobre un elemento suelto con `TABLE()`.
- **Por qué los prerrequisitos son `REF`.** Son relaciones entre objetos del propio catálogo, no datos del curso. Se navegan con `DEREF`.

**Preguntas trampa**

- *¿Para qué el `CREATE TYPE` suelto?* — Resuelve la dependencia circular; sin él el script no compila.
- *¿Qué es `COLUMN_VALUE`?* — La pseudo-columna que expone los elementos de una Nested Table de tipo escalar, como la de `REF`.
- *¿Qué impide un prerrequisito circular?* — El motor no lo impide y hoy no está cubierto. Sería la siguiente extensión natural del modelo.

## H.4 Josue — las referencias y la transacción

*Preguntas 3 y 4 de la Sección 10, que se ejecutan en vivo.*

**Las ideas que hay que poder decir con palabras propias**

- **Por qué es la transacción central.** Vincula dos entidades con dos referencias separadas y guarda lo propio de la relación: periodo, beca, avance y nota.
- **Qué hace `SCOPE IS`.** Fija a qué tabla puede apuntar cada referencia; reduce su tamaño e impide apuntar a la tabla equivocada.
- **Qué NO hace `SCOPE IS`.** No es clave foránea. Si se borra la fila apuntada, la referencia sobrevive apuntando a un OID inexistente.
- **Por qué eso es peligroso.** `DEREF` devuelve `NULL` sin error: el problema se manifiesta recién al emitir un reporte.

**Preguntas trampa**

- *¿Por qué no una clave foránea normal?* — El modelo exige `REF`. Sabemos qué garantía se pierde y la comprobamos con `IS DANGLING`.
- *¿Por qué la nota está en la matrícula?* — Porque es un dato de la relación: el mismo estudiante tiene una nota distinta en cada curso.
- *Si `SCOPE IS` no protege del borrado, ¿para qué está?* — Reduce el tamaño físico de la referencia y garantiza que apunte a la tabla correcta.

## H.5 Orden, tiempos y reglas de ensayo

El docente fija **10 a 15 minutos**. Este reparto suma **13:30**, para dejar margen.

| Tiempo | Acumulado | Quién | Qué |
|---|---|---|---|
| 0:30 | 0:30 | Todos | Portada y apertura |
| 1:30 | 2:00 | Diego | Pregunta Rectora y visión general del esquema |
| 2:00 | 4:00 | Julio | Objeto anidado y validación del constructor |
| 1:30 | 5:30 | Diego | Tipo principal y patrón de tabla de objetos |
| 2:00 | 7:30 | Dario | Nested Table vs VARRAY y prerrequisitos como REF |
| 3:30 | 11:00 | Josue | Doble REF, demostración con DEREF y con IS DANGLING |
| 1:45 | 12:45 | Diego | Verificación de consistencia entre estructuras |
| 0:45 | 13:30 | Todos | Cierre y respuesta a la Pregunta Rectora |

**Cuatro reglas**

1. Cada uno ensaya su bloque en voz alta y cronometrado, sin leer nada y sin apoyo de los demás. Si hace falta leer, todavía no está aprendido.
2. Repaso cruzado: cada integrante le hace una pregunta incómoda al bloque de otro, para que nadie dependa de que le pregunten justo lo que preparó.
3. La pregunta 6 se responde con palabras propias sobre lo que uno hizo. No hay frase que sirva.
4. Josue prueba las consultas en vivo sobre la base conectada, incluido el `ROLLBACK`, antes de que empiece la defensa.

**Si te quedás en blanco**

Volvé a la Pregunta Rectora y a la exigencia que resuelve tu parte: matrículas y becas confiables, contenido de estructura variable, seguimiento en tiempo real, analítica de rendimiento. Cualquier decisión de diseño del proyecto se explica como respuesta a una de esas cuatro, y siempre es una forma válida de empezar.

**Chequeo final antes del Encuentro 8**

- [ ] Los cuatro pueden citar la Pregunta Rectora.
- [ ] Los cuatro conocen los números: 3 estudiantes, 4 cursos, 4 matrículas, 13 módulos, 3 prerrequisitos.
- [ ] Cada uno respondió su bloque sin apoyo, cronometrado.
- [ ] Las demostraciones en vivo se probaron sobre la base conectada.
- [ ] Todos leyeron la Parte F y saben qué es agregado del equipo.
