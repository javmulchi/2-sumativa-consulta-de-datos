/* =========================================================
 Evaluacion sumativa semana 6
  Alumna: Javiera Mulchi
  Asignatura: Consulta de datos
  Fecha:30-11-2025
   ========================================================= */
ROLLBACK;

--Caso 1: Reporte de asesorías
   
SELECT
    p.id_profesional,
    p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre       AS nombre_completo,
    -- Banca
    SUM(CASE WHEN e.cod_sector = 3 THEN 1 ELSE 0 END)          AS nro_asesorias_banca,
    TO_CHAR(
        NVL(SUM(CASE WHEN e.cod_sector = 3 THEN a.honorario ELSE 0 END), 0),
        '$999,999,999'
    )                                                          AS monto_banca_fmt,
    -- Retail
    SUM(CASE WHEN e.cod_sector = 4 THEN 1 ELSE 0 END)          AS nro_asesorias_retail,
    TO_CHAR(
        NVL(SUM(CASE WHEN e.cod_sector = 4 THEN a.honorario ELSE 0 END), 0),
        '$999,999,999'
    )                                                          AS monto_retail_fmt,
    -- Totales
    COUNT(*)                                                   AS total_asesorias,
    TO_CHAR(
        NVL(SUM(a.honorario), 0),
        '$999,999,999'
    )                                                          AS total_honorarios_fmt
FROM profesional p
JOIN asesoria a ON a.id_profesional = p.id_profesional
JOIN empresa e  ON e.cod_empresa = a.cod_empresa
WHERE p.id_profesional IN (
    SELECT id_profesional FROM asesoria a2 JOIN empresa e2 ON e2.cod_empresa = a2.cod_empresa WHERE e2.cod_sector = 3
    INTERSECT
    SELECT id_profesional FROM asesoria a3 JOIN empresa e3 ON e3.cod_empresa = a3.cod_empresa WHERE e3.cod_sector = 4
)
GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre
ORDER BY p.id_profesional;

-- Caso 2: Resumen de honorarios 

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REPORTE_MES PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignora error si la tabla no existe
END;
/

CREATE TABLE REPORTE_MES (
    id_profesional      NUMBER(10),
    nombre_profesional  VARCHAR2(60),
    nombre_profesion    VARCHAR2(25),
    nombre_comuna       VARCHAR2(20),
    nro_asesorias       NUMBER(3),
    total_honorarios    NUMBER(12),
    promedio_honorario  NUMBER(12),
    min_honorario       NUMBER(12),
    max_honorario       NUMBER(12)
);

INSERT INTO REPORTE_MES
SELECT
    p.id_profesional,
    p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre,
    prf.nombre_profesion,
    c.nom_comuna,
    COUNT(*),
    -- NVL asegura que si no hay suma, guarde 0 y no NULL
    NVL(SUM(a.honorario), 0),
    ROUND(NVL(AVG(a.honorario), 0)),
    NVL(MIN(a.honorario), 0),
    NVL(MAX(a.honorario), 0)
FROM profesional p
JOIN profesion prf ON p.cod_profesion = prf.cod_profesion
JOIN comuna c      ON p.cod_comuna = c.cod_comuna
JOIN asesoria a    ON a.id_profesional = p.id_profesional
WHERE
    EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12))
    AND EXTRACT(MONTH FROM a.fin_asesoria) = 4
GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre, prf.nombre_profesion, c.nom_comuna;

SELECT 
    nombre_profesional, 
    nro_asesorias, 
    TO_CHAR(total_honorarios, '$999,999,999') as total_fmt 
FROM REPORTE_MES 
ORDER BY total_honorarios DESC;

--Caso 3: Modificación de sueldos 
SELECT
    p.id_profesional,
    p.appaterno || ' ' || p.nombre AS nombre,
    TO_CHAR(p.sueldo, '$999,999,999') AS sueldo_actual,
    TO_CHAR(SUM(a.honorario), '$999,999,999') AS honorarios_marzo,
    CASE 
        WHEN SUM(a.honorario) < 1000000 THEN 'Aumento 10%'
        ELSE 'Aumento 15%'
    END AS accion_a_realizar
FROM profesional p
JOIN asesoria a ON a.id_profesional = p.id_profesional
WHERE EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12))
  AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
GROUP BY p.id_profesional, p.appaterno, p.nombre, p.sueldo
ORDER BY p.id_profesional;
MERGE INTO profesional p
USING (
    SELECT
        a.id_profesional,
        SUM(a.honorario) AS total_honorarios_marzo
    FROM asesoria a
    WHERE EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12))
      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
    GROUP BY a.id_profesional
) t
ON (p.id_profesional = t.id_profesional)
WHEN MATCHED THEN
    UPDATE SET p.sueldo = ROUND(
        p.sueldo * CASE 
            WHEN t.total_honorarios_marzo < 1000000 THEN 1.10 
            ELSE 1.15 
        END
    );
SELECT
    p.id_profesional,
    p.appaterno || ' ' || p.nombre AS nombre,
    TO_CHAR(p.sueldo, '$999,999,999') AS nuevo_sueldo
FROM profesional p
WHERE p.id_profesional IN (
    SELECT DISTINCT id_profesional FROM asesoria a 
    WHERE EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE, -12))
      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
)
ORDER BY p.id_profesional;
COMMIT;