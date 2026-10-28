# Avance 2 — Cambios del equipo (Grupo 3, EduConecta)

El equipo eligió la **rama B**: el Avance 1 se reentrega corregido (v2) y el Avance 2 se construye sobre él. La rama A (Avance 1 intacto + `ALTER TYPE`) ya no se usa.

## Por qué hubo que cambiar algo

1. **El cupo máximo no existía.** La guía del Avance 2 pide impedir que un curso reciba más matrículas de las que su cupo máximo permite, pero la guía del Avance 1 nunca pidió cupos, así que `TIPO_CURSO` no los tenía.
2. **SCOPE:** el ingeniero recomendó no usar `SCOPE IS` y trabajar solo con `REF` / `DEREF`.
3. **La Semana 1 del Avance 2 era inconsistente.** El PDF describía `PKG_EDUCONECTA` y el SQL tenía `PKG_GESTION_MATRICULAS`. Va una **versión 2** en la que PDF y SQL coinciden.
4. **Excepciones como en clase (26/09).** Antes las 4 excepciones propias estaban en la especificación del paquete y se atrapaban por nombre desde afuera, algo que no se vio en clase. Ahora cada subprograma declara la suya, la lanza con `RAISE` y la atrapa en su propia sección `EXCEPTION`, donde la convierte con `RAISE_APPLICATION_ERROR` (igual que el ejemplo de `e_stock_insuficiente` del 18/09). La especificación queda solo con procedimientos y funciones, y `total_modulos` pasó a ser pública.

## Estructura

| Carpeta | Contenido |
|---|---|
| `Avance1_v2/` | Avance 1 corregido: sin `SCOPE IS` y con `cupo_maximo` en `TIPO_CURSO` (BDD-101: 3, PRG-102: 2, BDD-301: 3, CDD-501: 2) |
| `Avance2/Semana1/` | Documento de diseño v2 (.docx/.pdf) y script del paquete |
| `Avance2/Semana2/` | Script del trigger, pruebas e integración |
| `Avance2/Semana3/` | Informe final de integración (.odt/.pdf) |

## El paquete PKG_GESTION_MATRICULAS

| Subprograma | Qué hace | Errores |
|---|---|---|
| `matricular` (PROCEDURE, OUT código) | Valida estudiante, duplicado, cupo y nivel; genera `MAT-2026-0006…` con `seq_matriculas` | -20102 estudiante no existe, -20104 duplicada, -20105 cupo lleno, -20106 nivel |
| `dar_de_baja` (PROCEDURE, OUT resultado) | Pasa la matrícula a BAJA | -20103 no existe, -20107 no está EN_CURSO |
| `calcular_avance` (FUNCTION) | % de módulos aprobados sobre el total del curso | -20103 |
| `registrar_avance` (PROCEDURE, IN OUT módulos) | Guarda el avance y corrige excesos | -20103, -20107 |
| `cupos_disponibles` (FUNCTION) | Cupo máximo menos matrículas EN_CURSO (la usa el trigger) | -20101 curso no existe |
| `total_modulos` (FUNCTION) | Cuenta los módulos del curso con `TABLE()` | — |

**Trigger `TRG_VALIDA_CUPO_CURSO`:** `AFTER INSERT OR UPDATE OF estado, ref_curso`, a nivel **STATEMENT**, error -20110. La versión `BEFORE ... FOR EACH ROW` da **ORA-04091 (tabla mutante)**; eso se explica en el informe.

## Orden de ejecución (SQL Developer, usuario EDUCONECTA)

1. `Avance1_v2/20260925_BASEDAT3_ScriptFinal-Semana3_v2.sql`
2. `Avance2/Semana1/20260926_BASEDAT3_Avance2-Semana1_v2.sql`
3. `Avance2/Semana2/20260926_BASEDAT3_Avance2-Semana2.sql`

Las pruebas terminan con `ROLLBACK TO`, así que se pueden repetir. La secuencia no retrocede: para ver `MAT-2026-0006` en las capturas hay que correr desde cero (las limpiezas están comentadas al final de cada script).

## Pendiente del equipo

- [ ] Reemplazar las 2 capturas marcadas en el informe de la Semana 3 (salida de la violación 1 y DESCRIBE con 6 subprogramas).
- [ ] Reenviar la Semana 1 (v2).
- [ ] Subir la Semana 2: script + capturas de las pruebas del trigger.
- [ ] Subir los scripts a Git.
- [ ] Repartir la defensa (ver `01_Teoria_Informes/20260926_Guia_Estudio_Avance2_Trigger.md`).

---

# Avance 3 — MongoDB + Redis Streams

| Carpeta | Contenido |
|---|---|
| `Avance3/Semana1/` | Documento de modelado (lógico, conceptual, físico) |
| `Avance3/Semana2/` | Script MongoDB (`contenido_cursos`, `foros_discusion`, 3 agregaciones), export `.json` y verificación de ids en Oracle |
| `Avance3/Semana3/` | Script Redis `progreso_en_vivo`, verificación Oracle de las matrículas del stream, capturas y salida real de la demo e informe final de integración (`docs/`, .odt/.pdf) |

## Orden de ejecución

1. Oracle ya cargado con los scripts del Avance 1 v2 y Avance 2.
2. `Avance3/Semana2/20261020_BASEDAT3_Avance3-Semana2-Script-MongoDB.txt` en mongosh / Compass.
3. `Avance3/Semana3/20261027_BASEDAT3_Avance3-Semana3-Redis-progreso_en_vivo.redis` en **dos** `redis-cli` (suscriptor primero, después productor).
4. Opcional: los `.sql` de verificación de las Semanas 2 y 3 en SQL Developer (usuario EDUCONECTA).

Redis local rápido: `docker run --rm -d --name redis-educonecta -p 6379:6379 redis:7` y `docker exec -it redis-educonecta redis-cli`.

## Pendiente del equipo

- [ ] Estudiar la guía de defensa (se compartió aparte por el grupo).
- [ ] Ensayar la demo en vivo de Redis (pregunta 4).
