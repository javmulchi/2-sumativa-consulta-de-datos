#Sumativa 2 Consulta de datos

**Información del Proyecto**

Autor: Javiera Mulchi

Asignatura: Consulta de datos

Fecha: 30-11-2025

Base de Datos: Oracle Database (PL/SQL)

**Técnicas utilizadas:**

--Sentencias DDL (CREATE TABLE).

--Funciones de agregación: COUNT, SUM, AVG, MIN, MAX.

--Control de transacciones ROLLBACK, COMMIT

--JOIN

**Contenido**

-Contiene la solución a tres casos prácticos:

--Caso 1: Reporte de Asesorías 
Generación de un reporte cruzado que identifica a los profesionales que han prestado servicios ambos sectores (Banca y Retail).

--Caso 2: Resumen de Honorarios (Creación de Tabla)
Automatización de la creación de una tabla de resumen (REPORTE_MES) con estadísticas de honorarios correspondientes al mes de abril del año anterior.

Manejo de fechas dinámicas con ADD_MONTHS(SYSDATE, -12) y EXTRACT.

Caso 3: Modificación Masiva de Sueldos (Merge)
Actualización de los sueldos base de los profesionales basándose en el total de honorarios generados en marzo del año anterior.
