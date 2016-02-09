create or replace PACKAGE BODY PAQ_ARCHIVOS_PLANOS_INTERNOS IS
  PROCEDURE SP_PLANO_INTERNO_ACCIDENTE(PFECHA_DESDE       IN DATE,
                                       PFECHA_HASTA       IN DATE,
                                       PLISTA_FORMULARIOS IN VARCHAR2,
                                       PTIPO_REPORTE      IN VARCHAR2,
                                       POPERACION         IN VARCHAR2,
                                       PCURSOR            OUT SYS_REFCURSOR) IS
    --VarSentencia varchar(2000);
    vlista_consecutivos VARCHAR2(500);
    vformulario         VARCHAR2(50);
    vmensaje            VARCHAR2(600);
    --vcantida            NUMBER;
    --VCONTAR             NUMBER;
  BEGIN
  
    dbms_output.put_line('antes de calculando..');
    EXECUTE IMMEDIATE 'ALTER SESSION set nls_territory = ''SPAIN'''; -- Para que tome siempre 1 como Lunes'
    dbms_output.put_line('calculando..');
    --    --''AMERICA'''; -- Para que tome siempre dia 1 como Domingo
    IF PLISTA_FORMULARIOS IS NOT NULL THEN
      vlista_consecutivos := PLISTA_FORMULARIOS;
      LOOP
        IF (INSTR(vlista_consecutivos, ',') > 0) THEN
          vformulario         := SUBSTR(vlista_consecutivos,
                                        1,
                                        instr(vlista_consecutivos, ',') - 1);
          vlista_consecutivos := SUBSTR(vlista_consecutivos,
                                        instr(vlista_consecutivos, ',') + 1);
        ELSE
          vformulario         := vlista_consecutivos;
          vlista_consecutivos := NULL;
        END IF;
      
        INSERT INTO sigat.lista_formularios
          (idformulario)
        VALUES
          (vformulario);
        EXIT WHEN vlista_consecutivos is null;
      END LOOP;
      COMMIT;
    END IF;
  
    --log
    --SELECT COUNT(1) INTO vcantida FROM sigat.lista_formularios;
  
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Registros a procesar: '||vcantida);
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Fecha desde: '||PFECHA_DESDE);
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Fecha hasta: '||PFECHA_HASTA);
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Lista Form: '||PLISTA_FORMULARIOS);
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Tipo de reporte: '||PTIPO_REPORTE);
    --    INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Operacion: '||POPERACION);
  
    IF UPPER(POPERACION) = 'S' AND (PTIPO_REPORTE = 'ACCIDENTES') THEN
    
      dbms_output.put_line('ENTRA ACCIDENTE: S..');
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        --dbms_output.put_line('cursor..');
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          NVL(TO_CHAR(TRUNC(A.FECHA), 'DAY'), ' ') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          NVL(A.OFICINA, ' ') CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(DECODE(A.Objeto_Fijo,
                                     11,
                                     A.OTRO_OBJETO_FIJO,
                                     A.OBJETO_FIJO),
                              ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(DECODE(A.Objeto_Fijo,
                                     11,
                                     FN_DOMVALOR('cDomAccObjetoFijoOtro',
                                                 A.OTRO_OBJETO_FIJO),
                                     FN_DOMVALOR('cDomAccObjetoFijo',
                                                 A.OBJETO_FIJO)),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          CASE
                            WHEN A.DIRNUMERO IS NULL THEN
                             TO_CHAR(SUBSTR(NVL(A.direccion, ' '),
                                            INSTR(A.direccion, 'AV', 1, 1) + 3,
                                            INSTR(A.direccion, '-', 1, 1) -
                                            INSTR(A.direccion, 'AV', 1, 1) - 3))
                            ELSE
                             A.DIRNUMERO
                          END NUMERO_VIA_1, --Listo 20
                          --NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, ' ') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          NVL(tc.consecutivo, ' ') AS CONSECUTIVO, --Listo 50***
                          --ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('CE', 'CG')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS codigo_hipotesis_conductor_1,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('CE', 'CG')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS descri_hipotesis_conductor_1,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('CE', 'CG')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS codigo_hipotesis_conductor_2,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('CE', 'CG')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS descri_hipotesis_conductor_2,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PE')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS codigo_hipotesis_peaton_1,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PE')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS descri_hipotesis_peaton_1,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PE')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS codigo_hipotesis_peaton_2,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PE')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS descri_hipotesis_peaton_2,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VH')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS codigo_hipotesis_vehiculo_1,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VH')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS descri_hipotesis_vehiculo_1,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VH')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS codigo_hipotesis_vehiculo_2,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VH')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS descri_hipotesis_vehiculo_2,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PA')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS codigo_hipotesis_pasajero_1,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PA')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS descri_hipotesis_pasajero_1,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PA')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS codigo_hipotesis_pasajero_2,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('PA')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS descri_hipotesis_pasajero_2, --Listo 66***
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VI')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS CODIGO_HIPOTESIS_VIA_1,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VI')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 1),
                              ' ') AS DESCRI_HIPOTESIS_VIA_1,
                          NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VI')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS CODIGO_HIPOTESIS_VIA_2,
                          NVL((SELECT T.NOMBRE
                                FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                               WHERE TRIM(C.CODIGO_CAUSA) =
                                     TRIM(T.CODIGO_CAUSA)
                                 AND D.DOMINIO = 'cDomAccClaseCausa'
                                 AND D.CODIGO IN ('VI')
                                 AND T.TIPO = D.CODIGO
                                 AND C.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND C.CODIGO_VEHICULO = 2),
                              ' ') AS DESCRI_HIPOTESIS_VIA_2,
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          0 VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo --NOMBRE
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          0    AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          0    AS CONDUCTOR_EDAD,
                          0    AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          0    AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          0    AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          0    AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          0    AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          0    AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          0    AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          0    AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          0    AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          0    AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          0    AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          0    AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE A
            LEFT JOIN t_correspondio tc
              ON a.formulario = tc.cod_formilario
           WHERE A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
        dbms_output.put_line('LISTA DE FORMULARIOS * termina el query..' ||
                             PFECHA_DESDE || ' - ' || PFECHA_HASTA);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
      
        begin
          OPEN PCURSOR FOR
            SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                            A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                            TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                            TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                            A.OFICINA CODIGO_OFICINA, --Listo 5
                            NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                            NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                                'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                            NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                            NVL(FN_DOMVALOR('cDomAccClaseAccidente',
                                            A.CLASE),
                                ' ') NOMBRE_CLASE, --Listo 9
                            NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                            NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                            NVL(DECODE(A.Objeto_Fijo,
                                       11,
                                       A.OTRO_OBJETO_FIJO,
                                       A.OBJETO_FIJO),
                                ' ') AS TIPO_COLISION, --Listo 12***
                            NVL(DECODE(A.Objeto_Fijo,
                                       11,
                                       FN_DOMVALOR('cDomAccObjetoFijoOtro',
                                                   A.OTRO_OBJETO_FIJO),
                                       FN_DOMVALOR('cDomAccObjetoFijo',
                                                   A.OBJETO_FIJO)),
                                ' ') AS NOMBRE_COLISION, --Listo 13***
                            NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                            NVL(FN_DOMVALOR('cDomAccChoqueOtro',
                                            A.OTRO_CLASE),
                                ' ') AS OTRA_CLASE, --Listo 15***
                            NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                            NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                            NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                            NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                            CASE
                              WHEN A.DIRNUMERO IS NULL THEN
                               TO_CHAR(SUBSTR(NVL(A.direccion, ' '),
                                              INSTR(A.direccion, 'AV', 1, 1) + 3,
                                              INSTR(A.direccion, '-', 1, 1) -
                                              INSTR(A.direccion, 'AV', 1, 1) - 3))
                              ELSE
                               A.DIRNUMERO
                            END NUMERO_VIA_1, --Listo 20
                            
                            --NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                            
                            NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                            NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                            NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                            NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                            NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                            NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                            NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                            NVL((SELECT MU.NOMBRE
                                  FROM SIGAT.MUNICIPIOS MU
                                 WHERE MU.CODIGO_MUNICIPIO =
                                       SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                   AND ROWNUM = 1),
                                ' ') NOMBRE_MUNICIPIO, --Listo 28
                            NVL((SELECT LA.NOMBRE
                                  FROM SIGAT.LOCALIDADES LA
                                 WHERE LA.CODIGO_LOCALIDAD =
                                       A.CODIGO_LOCALIDAD
                                   AND ROWNUM = 1),
                                ' ') NOMBRE_LOCALIDAD, --Listo 29
                            TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                            TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                            TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                            NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                            NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                            NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                            NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                            A.DISENO_LUGAR),
                                ' ') CODIGO_DISENO_LUGAR, --Listo 36
                            NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                                'VA'),
                                ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                            NVL((SELECT ZT.NOMBRE
                                  FROM SIGAT.ZONAS_TRANSITO ZT
                                 WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                   AND ROWNUM = 1),
                                ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                            NVL((SELECT AT.NOMBRE
                                  FROM SIGAT.AREAS_TRANSITO AT
                                 WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                   AND ROWNUM = 1),
                                ' ') CODIGO_AREA_TRANSITO, --Listo 39
                            NVL((SELECT CV.NOMBRE
                                  FROM SIGAT.CORREDORES_VIALES CV
                                 WHERE CV.CODIGO_CORREDOR =
                                       A.CORREDOR_TRANSITO
                                   AND ROWNUM = 1),
                                ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                            NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                            NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                            NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                      FROM SIGAT.T_AGENTES TG
                                     WHERE TG.PLACA = A.PLACA
                                       AND ROWNUM = 1),
                                    (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                       FROM SIGAT.AGENTE_ACCIDENTE TG
                                      WHERE TG.CODIGO_ACCIDENTE =
                                            A.CODIGO_ACCIDENTE
                                        AND TG.CODIGO_FORMULARIO =
                                            A.FORMULARIO
                                        AND ROWNUM = 1)),
                                DECODE(NVL(A.PLACA, 'X'),
                                       'X',
                                       '',
                                       A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                            NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                            NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                            A.CORRESPONDIO),
                                ' ') CORRESPONDIO, --Listo 45
                            (select d.nombre
                               from sigat.departamentos d
                              where d.codigo_departamento = '11'
                                AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                            'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                            NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                            TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                            NVL(tc.consecutivo, ' ') AS CONSECUTIVO, --Listo 50***
                            --ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('CE', 'CG')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS codigo_hipotesis_conductor_1,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('CE', 'CG')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS descri_hipotesis_conductor_1,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('CE', 'CG')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS codigo_hipotesis_conductor_2,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('CE', 'CG')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS descri_hipotesis_conductor_2,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PE')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS codigo_hipotesis_peaton_1,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PE')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS descri_hipotesis_peaton_1,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PE')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS codigo_hipotesis_peaton_2,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PE')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS descri_hipotesis_peaton_2,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VH')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS codigo_hipotesis_vehiculo_1,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VH')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS descri_hipotesis_vehiculo_1,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VH')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS codigo_hipotesis_vehiculo_2,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VH')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS descri_hipotesis_vehiculo_2,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PA')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS codigo_hipotesis_pasajero_1,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PA')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS descri_hipotesis_pasajero_1,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PA')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS codigo_hipotesis_pasajero_2,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('PA')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS descri_hipotesis_pasajero_2, --Listo 66***
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VI')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS CODIGO_HIPOTESIS_VIA_1,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VI')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 1),
                                ' ') AS DESCRI_HIPOTESIS_VIA_1,
                            NVL((SELECT TO_CHAR(C.CODIGO_CAUSA)
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VI')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS CODIGO_HIPOTESIS_VIA_2,
                            NVL((SELECT T.NOMBRE
                                  FROM CAUSAS C, TIPOS_CAUSAS T, DOMINIOS D
                                 WHERE TRIM(C.CODIGO_CAUSA) =
                                       TRIM(T.CODIGO_CAUSA)
                                   AND D.DOMINIO = 'cDomAccClaseCausa'
                                   AND D.CODIGO IN ('VI')
                                   AND T.TIPO = D.CODIGO
                                   AND C.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND C.CODIGO_VEHICULO = 2),
                                ' ') AS DESCRI_HIPOTESIS_VIA_2,
                            NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                       T.SEGUNDO_APELLIDO
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') NOMBRE_TESTIGO, --Listo 67
                            NVL((SELECT T.TIPO_IDENTIFICACION
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                            NVL((SELECT T.NUMERO_IDENTIFICACION
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                            NVL((SELECT T.DIRECCION
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') DIRECCION_TESTIGO, --listo 70
                            NVL((SELECT T.CODIGO_MUNICIPIO
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                            NVL((SELECT T.TELEFONO
                                  FROM SIGAT.TESTIGOS T
                                 WHERE T.CODIGO_ACCIDENTE =
                                       A.CODIGO_ACCIDENTE
                                   AND ROWNUM = 1),
                                ' ') TELEFONO_TESTIGO, --Listo 72
                            0 as coordenadax,
                            0 as coordenaday,
                            /*Victimas*/
                            0 VICTIMA_NUMERO, --Listo
                            ' ' AS VICTIMA_NOMBRE, --Listo
                            NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                            0 VICTIMA_EDAD, --Listo
                            ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                            ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                            ' ' VICTIMA_DIRECCION, -- Listo
                            ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                            ' ' VICTIMA_TELEFONO, --Listo
                            ' ' VICTIMA_LLEVA_CINTURON, --Listo
                            NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                            0 VICTIMA_CODIGO_CLINICA, --Listo
                            ' ' VICTIMA_LLEVA_CASCO, --Listo
                            ' ' VICTIMA_PEATON_PASAJERO, --Listo
                            0 VICTIMA_CODIGO_VEHICULO, --Listo
                            ' ' VICTIMA_SEXO, --Listo
                            ' ' VICTIMA_GRAVEDAD, --Listo
                            ' ' VICTIMA_VALORADA, --Listo
                            ' ' VICTIMA_FALLECE, --Listo
                            ' ' VICTIMA_FECHA_MUERTE, --Listo
                            ' ' VICTIMA_CLASE_OFICIAL, --Listo
                            ' ' VICTIMA_GRADO_OFICIAL, --Listo
                            ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                            ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                            ' ' AS VICTIMA_TRASLADADO, --Listo ***
                            ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                            
                            /*Conductor*/
                            0    AS VEHICULO_NUMERO,
                            NULL AS CONDUCTOR_NOMBRE,
                            NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                            0    AS CONDUCTOR_EDAD,
                            0    AS CONDUCTOR_COD_TIPO_ID,
                            NULL AS CONDUCTOR_NUMERO_ID,
                            NULL AS CONDUCTOR_DIRECCION,
                            NULL AS CONDUCTOR_MUNICIPIO,
                            NULL AS CONDUCTOR_TELEFONO,
                            NULL AS CONDUCTOR_LLEVA_CITURON,
                            NULL AS CONDUCTOR_LLEVA_CHALECO,
                            NULL AS CONDUCTOR_NOMBRE_CLINICA,
                            NULL AS CONDUCTOR_LLEVA_CASCO,
                            NULL AS CONDUCTOR_SEXO,
                            NULL AS CONDUCTOR_GRAVEDAD,
                            NULL AS CONDUCTOR_VALORADO,
                            NULL AS CONDUCTOR_TRASLADADO_EN,
                            NULL AS CONDUCTOR_FALLECE_POST,
                            NULL AS CONDUCTOR_FECHA_MUERTE,
                            NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                            NULL AS CONDUCTOR_GRADO_OFICIAL,
                            NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                            NULL AS CONDUCTOR_ESTABA_SERVICIO,
                            NULL AS CONDUCTOR_PORTA_LICENCIA,
                            NULL AS CONDUCTOR_NUMERO_LICENCIA,
                            0    AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                            NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                            NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                            NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                            NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                            0    AS CONDUCTOR_COD_TIPO_ID_PROP,
                            NULL AS CONDUCTOR_NUM_ID_PROP,
                            NULL AS VEHICULO_FUGA,
                            NULL AS VEHICULO_NUMERO_PLACA,
                            NULL AS VEHICULO_PLACA_REMOLQUE,
                            NULL AS VEHICULO_MARCA,
                            NULL AS VEHICULO_MODELO,
                            NULL AS VEHICULO_CAPACIDAD_CARGA,
                            NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                            NULL AS VEHICULO_COLOR,
                            NULL AS VEHICULO_NUMERO_REV_TECNO,
                            0    AS VEHICULO_CODIGO_EMPRESA_PERT,
                            NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                            NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                            NULL AS VEHICULO_FISCALIA_JUZGADO,
                            NULL AS VEHICULO_SOAT,
                            0    AS VEHICULO_COD_EMP_SOAT,
                            NULL AS VEHICULO_FECHA_VENC_SOAT,
                            NULL AS VEHICULO_NOMBRE_CLASE,
                            NULL AS VEHICULO_NOMBRE_SERVICIO,
                            NULL AS VEHICULO_MODALIDAD, --***
                            NULL AS VEHICULO_RADIO_ACCION, --***
                            0    AS VEHICULO_COD_NACIONALIDAD,
                            NULL AS VEHICULO_SEGURO_RESPONS,
                            NULL AS VEHICULO_NOMB_TIPO_FALLA,
                            NULL AS VEHICULO_INMOVILIZADO_EN,
                            NULL AS VEHICULO_A_DISPOSICION_DE,
                            
                            NULL AS VIA_NUMERO_VIA_FORM,
                            NULL AS VIA_NOMBRE_GEOMETRICA_A,
                            NULL AS VIA_NOMBRE_GEOMETRICA_B,
                            NULL AS VIA_NOMBRE_GEOMETRICA_C,
                            NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                            NULL AS VIA_NOMBRE_TIPO_CALZADA,
                            NULL AS VIA_NOMBRE_TIPO_CARRIL,
                            NULL AS VIA_NOMBRE_ESTADO,
                            NULL AS VIA_NOMBRE_TIPO_CONDICION,
                            NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                            NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                            NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                            NULL AS VIA_EXISTE_AGENTE,
                            NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                            NULL AS VIA_VISUAL_NORMAL, --***
                            NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                            
                            0    AS LESION_CODIGO_TIPO,
                            NULL AS LESION_NOMBRE_TIPO,
                            NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                            
                            NULL AS VICTIMA_EXAMEN,
                            NULL AS VICTIMA_FORMULARIO,
                            NULL AS VICTIMA_GRADO_EXAMEN,
                            NULL AS VICTIMA_RESULTADO_EXAMEN,
                            
                            0    AS SENIAL_CODIGO,
                            NULL AS SENIAL_NOMBRE,
                            0    AS SENIAL_CODIGO_DEMARCACION,
                            NULL AS SENIAL_NOMBRE_DEMARCACION,
                            0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                            NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                            0    AS SENIAL_CODIGO_DELINEADOR, --***
                            NULL AS SENIAL_NOMBRE_DELINEADOR --***
              FROM SIGAT.ACCIDENTE A
              LEFT JOIN t_correspondio tc
                ON a.formulario = tc.cod_formilario
             WHERE (TRUNC(A.FECHA) BETWEEN
                   NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                   NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
        
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Error en rangos de fecha..');
        end;
      
        dbms_output.put_line('RANGO DE FECHAS ** termina el query..' ||
                             PFECHA_DESDE || ' - ' || PFECHA_HASTA);
      
      END IF;
    
      --    dbms_output.put_line('terminando bien..');
    ELSIF (PTIPO_REPORTE = 'VICTIMAS') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
      
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          0 AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          0 AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          0    AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          0    AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          0    AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          0    AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          0    AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          0    AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          (sigat.fn_calcular_edad(A.FECHA,
                                                  C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                          NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                          NVL(C.CODIGO_MUNICIPIO, 0) VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                          NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                          NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo
                          NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                          NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                          FN_DOMVALOR('cDomAccCondicionVictima',
                                      C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                          NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS VICTIMA_SEXO, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') VICTIMA_GRAVEDAD, --Listo
                          sf_hospitalizado_valorado(c.codigo_accidentado,
                                                    c.estado) VICTIMA_VALORADA, --Listo
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') VICTIMA_FALLECE, --Listo
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                          NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo
                          NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                          NVL(ut.nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                          NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                          NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          0    AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          0    AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          0    AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          0    AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          0    AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          0    AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          0    AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          0    AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          0    AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          0    AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          0    AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE   A,
                 SIGAT.VICTIMAS    C,
                 grados_transito   gt,
                 unidades_transito ut
           WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND c.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
             AND C.CONDICION <> 0
             AND C.ESTADO IN ('1', '2')
             AND C.CODIGO_VICTIMA <> 0
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
      
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          0 AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          0 AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          0    AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          0    AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          0    AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          0    AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          0    AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          0    AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          (sigat.fn_calcular_edad(A.FECHA,
                                                  C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                          NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                          NVL(C.CODIGO_MUNICIPIO, 0) VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                          NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                          NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo
                          NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                          NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                          FN_DOMVALOR('cDomAccCondicionVictima',
                                      C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                          NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS VICTIMA_SEXO, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') VICTIMA_GRAVEDAD, --Listo
                          sf_hospitalizado_valorado(c.codigo_accidentado,
                                                    c.estado) VICTIMA_VALORADA, --Listo
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') VICTIMA_FALLECE, --Listo
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                          NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo
                          NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                          NVL(ut.Nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                          NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                          NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          0    AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          0    AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          0    AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          0    AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          0    AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          0    AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          0    AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          0    AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          0    AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          0    AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          0    AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE   A,
                 SIGAT.VICTIMAS    C,
                 grados_transito   gt,
                 unidades_transito ut
           WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND c.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
             AND C.CONDICION <> 0
             AND C.ESTADO IN ('1', '2')
             AND C.CODIGO_VICTIMA <> 0
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'CONDUCTORES_VEHICULOS') THEN
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        --        INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Conductores lista: '||PTIPO_REPORTE);
        OPEN PCURSOR FOR
SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                A.OFICINA CODIGO_OFICINA, --Listo 5
                NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                    'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                    ' ') NOMBRE_CLASE, --Listo 9
                NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                NVL(FN_DOMVALOR('cDomAccTipoColision',
                                A.TIPO_COLISION),
                    ' ') AS NOMBRE_COLISION, --Listo 13***
                NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                    ' ') AS OTRA_CLASE, --Listo 15***
                NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                NVL((SELECT MU.NOMBRE
                      FROM SIGAT.MUNICIPIOS MU
                     WHERE MU.CODIGO_MUNICIPIO =
                           SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                       AND ROWNUM = 1),
                    ' ') NOMBRE_MUNICIPIO, --Listo 28
                NVL((SELECT LA.NOMBRE
                      FROM SIGAT.LOCALIDADES LA
                     WHERE LA.CODIGO_LOCALIDAD =
                           A.CODIGO_LOCALIDAD
                       AND ROWNUM = 1),
                    ' ') NOMBRE_LOCALIDAD, --Listo 29
                TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                A.DISENO_LUGAR),
                    ' ') CODIGO_DISENO_LUGAR, --Listo 36
                NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                    'VA'),
                    ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                NVL((SELECT ZT.NOMBRE
                      FROM SIGAT.ZONAS_TRANSITO ZT
                     WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                       AND ROWNUM = 1),
                    ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                NVL((SELECT AT.NOMBRE
                      FROM SIGAT.AREAS_TRANSITO AT
                     WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                       AND ROWNUM = 1),
                    ' ') CODIGO_AREA_TRANSITO, --Listo 39
                NVL((SELECT CV.NOMBRE
                      FROM SIGAT.CORREDORES_VIALES CV
                     WHERE CV.CODIGO_CORREDOR =
                           A.CORREDOR_TRANSITO
                       AND ROWNUM = 1),
                    ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                          FROM SIGAT.T_AGENTES TG
                         WHERE TG.PLACA = A.PLACA
                           AND ROWNUM = 1),
                        (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                           FROM SIGAT.AGENTE_ACCIDENTE TG
                          WHERE TG.CODIGO_ACCIDENTE =
                                A.CODIGO_ACCIDENTE
                            AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                            AND ROWNUM = 1)),
                    DECODE(NVL(A.PLACA, 'X'),
                           'X',
                           '',
                           A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44

                NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                A.CORRESPONDIO),
                    ' ') CORRESPONDIO, --Listo 45
                (select d.nombre
                   from sigat.departamentos d
                  where d.codigo_departamento = '11'
                    AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                NULL AS codigo_hipotesis_conductor_1,
                NULL AS descri_hipotesis_conductor_1,
                NULL AS codigo_hipotesis_conductor_2,
                NULL AS descri_hipotesis_conductor_2,

                NULL AS codigo_hipotesis_peaton_1,
                NULL AS descri_hipotesis_peaton_1,
                NULL AS codigo_hipotesis_peaton_2,
                NULL AS descri_hipotesis_peaton_2,

                NULL AS codigo_hipotesis_vehiculo_1,
                NULL AS descri_hipotesis_vehiculo_1,
                NULL AS codigo_hipotesis_vehiculo_2,
                NULL AS descri_hipotesis_vehiculo_2,

                NULL AS codigo_hipotesis_pasajero_1,
                NULL AS descri_hipotesis_pasajero_1,
                NULL AS codigo_hipotesis_pasajero_2,
                NULL AS descri_hipotesis_pasajero_2, --Listo 66***

                0    AS codigo_hipotesis_via_1,
                NULL AS descri_hipotesis_via_1,
                0    AS codigo_hipotesis_via_2,
                NULL AS descri_hipotesis_via_2,

                NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                           T.SEGUNDO_APELLIDO
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    ' ') NOMBRE_TESTIGO, --Listo 67
                NVL((SELECT T.TIPO_IDENTIFICACION
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    0) CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                NVL((SELECT T.NUMERO_IDENTIFICACION
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    0) NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                NVL((SELECT T.DIRECCION
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    ' ') DIRECCION_TESTIGO, --listo 70
                NVL((SELECT T.CODIGO_MUNICIPIO
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    0) CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                NVL((SELECT T.TELEFONO
                      FROM SIGAT.TESTIGOS T
                     WHERE T.CODIGO_ACCIDENTE =
                           A.CODIGO_ACCIDENTE
                       AND ROWNUM = 1),
                    ' ') TELEFONO_TESTIGO, --Listo 72
                0 as coordenadax,
                0 as coordenaday,
                /*Victimas*/
                NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                (sigat.fn_calcular_edad(A.FECHA,
                                        C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                NVL(C.CODIGO_MUNICIPIO, ' ') VICTIMA_CODIGO_MUNICIPIO, --Listo

                NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo

                NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                FN_DOMVALOR('cDomAccCondicionVictima',
                            C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo

                DECODE(C.SEXO,
                       'FE',
                       'FEMENINO',
                       'MA',
                       'MASCULINO',
                       'NO APLICA') AS VICTIMA_SEXO, --Listo
                NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                C.ESTADO),
                    'Ilesa') VICTIMA_GRAVEDAD, --Listo
                NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                C.GRAVEDAD_LESION),
                    ' ') VICTIMA_VALORADA, --Listo
                DECODE(C.MUERTE_POSTERIOR,
                       'N', --'0',
                       'NO',
                       'S', --'1',
                       'SI',
                       'NO') VICTIMA_FALLECE, --Listo
                NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo

                NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                NVL(ut.nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***

                NULL AS VICTIMA_NACIONALIDAD, --Listo ***

                /*Conductor*/
                NVL(V.CODIGO_VEHICULO, 0) AS VEHICULO_NUMERO,
                (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                C.Segundo_Apellido) AS CONDUCTOR_NOMBRE,
                TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS CONDUCTOR_FECHA_NACIMIENTO,
                NVL(sigat.fn_calcular_edad(A.FECHA,
                                           C.FECHA_NACIMIENTO),
                    0) AS CONDUCTOR_EDAD,
                DECODE(C.TIPO_IDENTIFICACION,
                       'C',
                       'CC',
                       'T',
                       'TI',
                       'E',
                       'CE',
                       'N',
                       'NIT',
                       'P',
                       'PA',
                       'U',
                       'NI',
                       'IN') AS CONDUCTOR_COD_TIPO_ID,

                NVL(C.NUMERO_IDENTIFICACION, 0) AS CONDUCTOR_NUMERO_ID,
                NVL(C.DIRECCION, ' ') AS CONDUCTOR_DIRECCION,
                NVL((SELECT mu.nombre
                      FROM sigat.municipios mu
                     WHERE mu.codigo_municipio =
                           c.codigo_municipio
                       AND rownum = 1),
                    ' ') AS CONDUCTOR_MUNICIPIO,

                NVL(C.TELEFONO, ' ') AS CONDUCTOR_TELEFONO,
                NVL(C.CON_CINTURON, ' ') AS CONDUCTOR_LLEVA_CITURON,
                NVL(C.Chaleco, ' ') AS CONDUCTOR_LLEVA_CHALECO,
                NVL(C.Clinica_Atencion, 0) AS CONDUCTOR_NOMBRE_CLINICA,

                NVL(C.CON_CASCO, ' ') AS CONDUCTOR_LLEVA_CASCO,
                DECODE(C.SEXO,
                       'FE',
                       'FEMENINO',
                       'MA',
                       'MASCULINO',
                       'NO APLICA') AS CONDUCTOR_SEXO,
                NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                C.ESTADO),
                    'Ilesa') AS CONDUCTOR_GRAVEDAD,
                PAQ_ARCHIVOS_PLANOS_INTERNOS.sf_hospitalizado_valorado(c.codigo_accidentado,
                                          c.estado) AS CONDUCTOR_VALORADO,
                NVL(C.TRASLADADO, ' ') AS CONDUCTOR_TRASLADADO_EN,
                DECODE(C.MUERTE_POSTERIOR,
                       'N', --'0',
                       'NO',
                       'S', --'1',
                       'SI',
                       'NO') AS CONDUCTOR_FALLECE_POST,
                NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') AS CONDUCTOR_FECHA_MUERTE,
                NVL(C.CLASE_OFICIAL, 0) AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                NVL(gt.nombre, ' ') AS CONDUCTOR_GRADO_OFICIAL,
                NVL(ut.nombre, ' ') AS CONDUCTOR_UNIDAD_OFICIAL,
                NVL(C.ENSERVICIO, ' ') AS CONDUCTOR_ESTABA_SERVICIO,
                NVL(DECODE(CON.PORTA_LICENCIA,
                           '100',
                           ' ',
                           CON.PORTA_LICENCIA),
                    ' ') AS CONDUCTOR_PORTA_LICENCIA,
                NVL(TO_CHAR(CON.NUMERO_LICENCIA), ' ') AS CONDUCTOR_NUMERO_LICENCIA,
                NVL(CON.CATEGORIA_LICENCIA, ' ') AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                NVL(FN_DOMVALOR('cDomAccRestriccionPase',
                                CON.RESTRICCIONES),
                    ' ') AS CONDUCTOR_NOMBRE_RESTRICCION,
                FN_FECHA_VEN_EXP(TO_CHAR(TRUNC(CON.FECHA_LICENCIA)), 'VEN') AS CONDUCTOR_FECHA_VEN_LICENCIA, --Corregido con una función--Llevar la función
                NVL(CON.PROPIETARIO, ' ') AS CONDUCTOR_PROPIETARIO_VEHICULO,
                NVL(CON.NOMBRE_PROPIETARIO, ' ') || ' ' ||
                NVL(CON.PRIMERAPELLIDO_PROPIETARIO, ' ') || ' ' ||
                NVL(CON.SEGAPELLIDO_PROPIETARIO, ' ') AS CONDUCTOR_NOMBRE_PROPIETARIO,
                DECODE(CON.TIPOIDENT_PROPIETARIO,
                       'C',
                       'CC',
                       'T',
                       'TI',
                       'E',
                       'CE',
                       'N',
                       'NIT',
                       'P',
                       'PA',
                       'U',
                       'NI',
                       'IN') AS CONDUCTOR_COD_TIPO_ID_PROP,
                NVL(CON.NUMIDENT_PROPIETARIO, ' ') AS CONDUCTOR_NUM_ID_PROP,
                NVL(V.ENFUGA, 'N') AS VEHICULO_FUGA,
                NVL(V.PLACA, ' ') AS VEHICULO_NUMERO_PLACA,
                NVL(V.PLACA_REMOLQUE, ' ') AS VEHICULO_PLACA_REMOLQUE,
                NVL((SELECT MV.MARCA || ' ' || MV.LINEA
                      FROM SIGAT.MARCA_VEHICULOS MV
                     WHERE MV.CODIGO_MARCACARRO =
                           V.CODIGO_MARCACARRO
                       AND ROWNUM = 1),
                    ' ') AS VEHICULO_MARCA,
                NVL(V.MODELO, ' ') AS VEHICULO_MODELO,
                NVL(V.CARGA, 0) AS VEHICULO_CAPACIDAD_CARGA,
                NVL(V.PASAJERO, 0) AS VEHICULO_CANTIDAD_PASAJEROS,
                NVL(V.COLOR, ' ') AS VEHICULO_COLOR,
                NVL(V.REV_TECNICOMECANICA, ' ') AS VEHICULO_NUMERO_REV_TECNO,
                NVL(V.EMPRESA, ' ') AS VEHICULO_CODIGO_EMPRESA_PERT,
                (SELECT E.NOMBRE
                      FROM SIGAT.EMPRESAS E
                     WHERE E.CODIGO_EMPRESA = V.EMPRESA) AS VEHICULO_NOMBRE_EMPRESA_PERT, --Corregido
                NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                V.INMOVILIZADO),
                    ' ') AS VEHICULO_LUGAR_FUE_INMOVIL,
                NVL(FN_DOMVALOR('cDomAccTipoDisposicion',
                                V.DISPOSICION),
                    ' ') AS VEHICULO_FISCALIA_JUZGADO,
                NVL(V.NUMERO_SOAT, ' ') AS VEHICULO_SOAT,
                NVL(V.ASEGURADORA, ' ') AS VEHICULO_COD_EMP_SOAT,
                TRUNC(V.VENCIMIENTO_SOAT) AS VEHICULO_FECHA_VENC_SOAT,
                FN_DOMVALOR('cDomAccClaseVehiculo', V.CLASE) AS VEHICULO_NOMBRE_CLASE,
                FN_DOMVALOR('cDomAccTipoServicio', V.SERVICIO) AS VEHICULO_NOMBRE_SERVICIO,
                FN_DOMVALOR('cDomAccModalidadTranporteMasivo',
                            V.MODALIDAD) AS VEHICULO_MODALIDAD, --***
                FN_DOMVALOR('cDomAccRadioAccion', V.Radio_Accion) AS VEHICULO_RADIO_ACCION, --***
                NVL(V.NACIONALIDAD, ' ') AS VEHICULO_COD_NACIONALIDAD,
                NVL(V.PORTA_SEG_RESP_CON, 'N') AS VEHICULO_SEGURO_RESPONS, --Por defecto se le puso 'N'
                NVL(FN_DOMVALOR('cDomAccTipoFalla', V.FALLAS),
                    ' ') AS VEHICULO_NOMB_TIPO_FALLA,
                NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                V.INMOVILIZADO) || SIGAT.FN_GUION(V.OTRO_INMOVILIZADO) || V.OTRO_INMOVILIZADO,
                    ' ') AS VEHICULO_INMOVILIZADO_EN, --Corregido
                NVL(V.DETALLE_DISPOSICION, ' ') AS VEHICULO_A_DISPOSICION_DE,

                NULL AS VIA_NUMERO_VIA_FORM,
                NULL AS VIA_NOMBRE_GEOMETRICA_A,
                NULL AS VIA_NOMBRE_GEOMETRICA_B,
                NULL AS VIA_NOMBRE_GEOMETRICA_C,
                NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                NULL AS VIA_NOMBRE_TIPO_CALZADA,
                NULL AS VIA_NOMBRE_TIPO_CARRIL,
                NULL AS VIA_NOMBRE_ESTADO,
                NULL AS VIA_NOMBRE_TIPO_CONDICION,
                NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                NULL AS VIA_EXISTE_AGENTE,
                NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                NULL AS VIA_VISUAL_NORMAL, --***
                NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***

                NULL AS LESION_CODIGO_TIPO,
                NULL AS LESION_NOMBRE_TIPO,
                NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/

                NULL AS VICTIMA_EXAMEN,
                NULL AS VICTIMA_FORMULARIO,
                NULL AS VICTIMA_GRADO_EXAMEN,
                NULL AS VICTIMA_RESULTADO_EXAMEN,

                NULL AS SENIAL_CODIGO,
                NULL AS SENIAL_NOMBRE,
                NULL AS SENIAL_CODIGO_DEMARCACION,
                NULL AS SENIAL_NOMBRE_DEMARCACION,
                NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                NULL AS SENIAL_CODIGO_DELINEADOR, --***
                NULL AS SENIAL_NOMBRE_DELINEADOR --***
  FROM SIGAT.ACCIDENTE   A,
       SIGAT.VICTIMAS    C,
       SIGAT.CONDUCTORES CON,
       SIGAT.VEHICULOS   V,
       grados_transito   gt,
       unidades_transito ut
 WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
   AND CON.CODIGO_ACCIDENTADO(+) = C.CODIGO_ACCIDENTADO
   AND C.CODIGO_VICTIMA = 0
   AND V.CODIGO_ACCIDENTE = C.CODIGO_ACCIDENTE
   AND V.CODIGO_VEHICULO = C.CODIGO_VEHICULO
   AND C.grado_oficial = gt.codigo_grado(+)
   AND c.unidad = ut.codigo_unidad(+)
      --AND C.ESTADO IN ('0', '1', '2')
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
        --        INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Conductores fecha: '||PTIPO_REPORTE);
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              0) CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              0) NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              0) CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          (sigat.fn_calcular_edad(A.FECHA,
                                                  C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                          NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                          NVL(C.CODIGO_MUNICIPIO, ' ') VICTIMA_CODIGO_MUNICIPIO, --Listo
          
                          NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                          NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                          NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo
          
                          NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                          NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                          FN_DOMVALOR('cDomAccCondicionVictima',
                                      C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                          NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo
          
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS VICTIMA_SEXO, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') VICTIMA_GRAVEDAD, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                          C.GRAVEDAD_LESION),
                              ' ') VICTIMA_VALORADA, --Listo
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') VICTIMA_FALLECE, --Listo
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                          NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo
          
                          NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                          NVL(ut.nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                          NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                          NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***
          
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
          
                          /*Conductor*/
                          NVL(V.CODIGO_VEHICULO, 0) AS VEHICULO_NUMERO,
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS CONDUCTOR_NOMBRE,
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS CONDUCTOR_FECHA_NACIMIENTO,
                          NVL(sigat.fn_calcular_edad(A.FECHA,
                                                     C.FECHA_NACIMIENTO),
                              0) AS CONDUCTOR_EDAD,
                          DECODE(C.TIPO_IDENTIFICACION,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID,
          
                          NVL(C.NUMERO_IDENTIFICACION, 0) AS CONDUCTOR_NUMERO_ID,
                          NVL(C.DIRECCION, ' ') AS CONDUCTOR_DIRECCION,
                          NVL((SELECT mu.nombre
                                FROM sigat.municipios mu
                               WHERE mu.codigo_municipio =
                                     c.codigo_municipio
                                 AND rownum = 1),
                              ' ') AS CONDUCTOR_MUNICIPIO,
          
                          NVL(C.TELEFONO, ' ') AS CONDUCTOR_TELEFONO,
                          NVL(C.CON_CINTURON, ' ') AS CONDUCTOR_LLEVA_CITURON,
                          NVL(C.Chaleco, ' ') AS CONDUCTOR_LLEVA_CHALECO,
                          NVL(C.Clinica_Atencion, 0) AS CONDUCTOR_NOMBRE_CLINICA,
          
                          NVL(C.CON_CASCO, ' ') AS CONDUCTOR_LLEVA_CASCO,
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS CONDUCTOR_SEXO,
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') AS CONDUCTOR_GRAVEDAD,
                          PAQ_ARCHIVOS_PLANOS_INTERNOS.sf_hospitalizado_valorado(c.codigo_accidentado,
                                                    c.estado) AS CONDUCTOR_VALORADO,
                          NVL(C.TRASLADADO, ' ') AS CONDUCTOR_TRASLADADO_EN,
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') AS CONDUCTOR_FALLECE_POST,
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') AS CONDUCTOR_FECHA_MUERTE,
                          NVL(C.CLASE_OFICIAL, 0) AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NVL(gt.nombre, ' ') AS CONDUCTOR_GRADO_OFICIAL,
                          NVL(ut.nombre, ' ') AS CONDUCTOR_UNIDAD_OFICIAL,
                          NVL(C.ENSERVICIO, ' ') AS CONDUCTOR_ESTABA_SERVICIO,
                          NVL(DECODE(CON.PORTA_LICENCIA,
                                     '100',
                                     ' ',
                                     CON.PORTA_LICENCIA),
                              ' ') AS CONDUCTOR_PORTA_LICENCIA,
                          NVL(TO_CHAR(CON.NUMERO_LICENCIA), ' ') AS CONDUCTOR_NUMERO_LICENCIA,
                          NVL(CON.CATEGORIA_LICENCIA, ' ') AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NVL(FN_DOMVALOR('cDomAccRestriccionPase',
                                          CON.RESTRICCIONES),
                              ' ') AS CONDUCTOR_NOMBRE_RESTRICCION,
                          FN_FECHA_VEN_EXP(TO_CHAR(TRUNC(CON.FECHA_LICENCIA)), 'VEN') AS CONDUCTOR_FECHA_VEN_LICENCIA, --Corregido con una función--Llevar la función
                          NVL(CON.PROPIETARIO, ' ') AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NVL(CON.NOMBRE_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.PRIMERAPELLIDO_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.SEGAPELLIDO_PROPIETARIO, ' ') AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          DECODE(CON.TIPOIDENT_PROPIETARIO,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NVL(CON.NUMIDENT_PROPIETARIO, ' ') AS CONDUCTOR_NUM_ID_PROP,
                          NVL(V.ENFUGA, 'N') AS VEHICULO_FUGA,
                          NVL(V.PLACA, ' ') AS VEHICULO_NUMERO_PLACA,
                          NVL(V.PLACA_REMOLQUE, ' ') AS VEHICULO_PLACA_REMOLQUE,
                          NVL((SELECT MV.MARCA || ' ' || MV.LINEA
                                FROM SIGAT.MARCA_VEHICULOS MV
                               WHERE MV.CODIGO_MARCACARRO =
                                     V.CODIGO_MARCACARRO
                                 AND ROWNUM = 1),
                              ' ') AS VEHICULO_MARCA,
                          NVL(V.MODELO, ' ') AS VEHICULO_MODELO,
                          NVL(V.CARGA, 0) AS VEHICULO_CAPACIDAD_CARGA,
                          NVL(V.PASAJERO, 0) AS VEHICULO_CANTIDAD_PASAJEROS,
                          NVL(V.COLOR, ' ') AS VEHICULO_COLOR,
                          NVL(V.REV_TECNICOMECANICA, ' ') AS VEHICULO_NUMERO_REV_TECNO,
                          NVL(V.EMPRESA, ' ') AS VEHICULO_CODIGO_EMPRESA_PERT,
                          (SELECT E.NOMBRE
                                FROM SIGAT.EMPRESAS E
                               WHERE E.CODIGO_EMPRESA = V.EMPRESA) AS VEHICULO_NOMBRE_EMPRESA_PERT, --Corregido
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          V.INMOVILIZADO),
                              ' ') AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NVL(FN_DOMVALOR('cDomAccTipoDisposicion',
                                          V.DISPOSICION),
                              ' ') AS VEHICULO_FISCALIA_JUZGADO,
                          NVL(V.NUMERO_SOAT, ' ') AS VEHICULO_SOAT,
                          NVL(V.ASEGURADORA, ' ') AS VEHICULO_COD_EMP_SOAT,
                          TRUNC(V.VENCIMIENTO_SOAT) AS VEHICULO_FECHA_VENC_SOAT,
                          FN_DOMVALOR('cDomAccClaseVehiculo', V.CLASE) AS VEHICULO_NOMBRE_CLASE,
                          FN_DOMVALOR('cDomAccTipoServicio', V.SERVICIO) AS VEHICULO_NOMBRE_SERVICIO,
                          FN_DOMVALOR('cDomAccModalidadTranporteMasivo',
                                      V.MODALIDAD) AS VEHICULO_MODALIDAD, --***
                          FN_DOMVALOR('cDomAccRadioAccion', V.Radio_Accion) AS VEHICULO_RADIO_ACCION, --***
                          NVL(V.NACIONALIDAD, ' ') AS VEHICULO_COD_NACIONALIDAD,
                          NVL(V.PORTA_SEG_RESP_CON, 'N') AS VEHICULO_SEGURO_RESPONS, --Por defecto se le puso 'N'
                          NVL(FN_DOMVALOR('cDomAccTipoFalla', V.FALLAS),
                              ' ') AS VEHICULO_NOMB_TIPO_FALLA,
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          V.INMOVILIZADO) || SIGAT.FN_GUION(V.OTRO_INMOVILIZADO) || V.OTRO_INMOVILIZADO,
                              ' ') AS VEHICULO_INMOVILIZADO_EN, --Corregido
                          NVL(V.DETALLE_DISPOSICION, ' ') AS VEHICULO_A_DISPOSICION_DE,
          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE   A,
                 SIGAT.VICTIMAS    C,
                 SIGAT.CONDUCTORES CON,
                 SIGAT.VEHICULOS   V,
                 grados_transito   gt,
                 unidades_transito ut
           WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND CON.CODIGO_ACCIDENTADO(+) = C.CODIGO_ACCIDENTADO
             AND C.CODIGO_VICTIMA = 0
             AND V.CODIGO_ACCIDENTE = C.CODIGO_ACCIDENTE
             AND V.CODIGO_VEHICULO = C.CODIGO_VEHICULO
             AND C.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
                --AND C.ESTADO IN ('0', '1', '2')
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
      
        --        INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('Conductores fecha registros hallados: '||VCONTAR);
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'VIAS') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
      
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          0 VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          /*De la via*/
                          NVL(VI.CODIGO_VIA, 0) AS VIA_NUMERO_VIA_FORM,
                          NVL(FN_DOMVALOR('cDomAccAGeometrica',
                                          VI.GEOMETRICAA),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_A,
                          NVL(FN_DOMVALOR('cDomAccBGeometrica',
                                          VI.GEOMETRICAB),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_B,
                          NVL(FN_DOMVALOR('cDomAccCGeometrica',
                                          VI.GEOMETRICAC),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_C,
                          NVL(FN_DOMVALOR('cDomAccUtilizacion',
                                          VI.UTILIZACION),
                              ' ') AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NVL(FN_DOMVALOR('cDomAccCalzadas', VI.CALZADAS),
                              ' ') AS VIA_NOMBRE_TIPO_CALZADA,
                          NVL(FN_DOMVALOR('cDomAccCarriles', VI.CARRILES),
                              ' ') AS VIA_NOMBRE_TIPO_CARRIL,
                          NVL(FN_DOMVALOR('cDomAccEstadoVia', VI.ESTADO),
                              ' ') AS VIA_NOMBRE_ESTADO,
                          NVL(FN_DOMVALOR('cDomAccCondiciones',
                                          VI.CONDICIONES),
                              ' ') AS VIA_NOMBRE_TIPO_CONDICION,
                          NVL(FN_DOMVALOR('cDomAccMaterial', VI.MATERIAL),
                              ' ') AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NVL(FN_DOMVALOR('cDomAccAIluminacion',
                                          VI.ILUMINACIONA),
                              ' ') AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NVL(FN_DOMVALOR('cDomAccBIluminacion',
                                          VI.ILUMINACIONB),
                              ' ') AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          nvl(VI.AGENTE, 'N') AS VIA_EXISTE_AGENTE,
                          NVL(FN_DOMVALOR('cDomAccSemaforos', VI.SEMAFORO),
                              ' ') AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          DECODE(VI.VISUAL_NORMAL, 'S', 'SI', 'N', 'NO') AS VIA_VISUAL_NORMAL, --***
                          NVL(sigat.utilidades.GetVisualDism(A.CODIGO_ACCIDENTE,
                                                             VI.CODIGO_VIA,
                                                             'VA'),
                              ' ') AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VIAS VI
           WHERE VI.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
      
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          0 VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          /*De la via*/
                          NVL(VI.CODIGO_VIA, 0) AS VIA_NUMERO_VIA_FORM,
                          NVL(FN_DOMVALOR('cDomAccAGeometrica',
                                          VI.GEOMETRICAA),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_A,
                          NVL(FN_DOMVALOR('cDomAccBGeometrica',
                                          VI.GEOMETRICAB),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_B,
                          NVL(FN_DOMVALOR('cDomAccCGeometrica',
                                          VI.GEOMETRICAC),
                              ' ') AS VIA_NOMBRE_GEOMETRICA_C,
                          NVL(FN_DOMVALOR('cDomAccUtilizacion',
                                          VI.UTILIZACION),
                              ' ') AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NVL(FN_DOMVALOR('cDomAccCalzadas', VI.CALZADAS),
                              ' ') AS VIA_NOMBRE_TIPO_CALZADA,
                          NVL(FN_DOMVALOR('cDomAccCarriles', VI.CARRILES),
                              ' ') AS VIA_NOMBRE_TIPO_CARRIL,
                          NVL(FN_DOMVALOR('cDomAccEstadoVia', VI.ESTADO),
                              ' ') AS VIA_NOMBRE_ESTADO,
                          NVL(FN_DOMVALOR('cDomAccCondiciones',
                                          VI.CONDICIONES),
                              ' ') AS VIA_NOMBRE_TIPO_CONDICION,
                          NVL(FN_DOMVALOR('cDomAccMaterial', VI.MATERIAL),
                              ' ') AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NVL(FN_DOMVALOR('cDomAccAIluminacion',
                                          VI.ILUMINACIONA),
                              ' ') AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NVL(FN_DOMVALOR('cDomAccBIluminacion',
                                          VI.ILUMINACIONB),
                              ' ') AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          nvl(VI.AGENTE, 'N') AS VIA_EXISTE_AGENTE,
                          NVL(FN_DOMVALOR('cDomAccSemaforos', VI.SEMAFORO),
                              ' ') AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          DECODE(VI.VISUAL_NORMAL, 'S', 'SI', 'N', 'NO') AS VIA_VISUAL_NORMAL, --***
                          NVL(sigat.utilidades.GetVisualDism(A.CODIGO_ACCIDENTE,
                                                             VI.CODIGO_VIA,
                                                             'VA'),
                              ' ') AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VIAS VI
           WHERE VI.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'LESIONES') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          0 VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          /*Lesion*/
                          NVL(L.CODIGO_LESION, ' ') AS LESION_CODIGO_TIPO
                          /*NULL AS LESION_CODIGO_TIPO*/,
                          NVL((SELECT NOMBRE
                              FROM TIPOS_LESIONES TP
                           WHERE TP.CODIGO_LESION = L.CODIGO_LESION),
                          ' ') AS LESION_NOMBRE_TIPO,
                          NVL(FN_DOMVALOR('cDomAccCondicionVictima',
                                          V.CONDICION),
                              'CONDUCTOR') || ' - ' ||
                          (SELECT NVL(FN_DOMVALOR('cDomAccClaseVehiculo',
                                                  VH.CLASE),
                                      ' ')
                             FROM SIGAT.VEHICULOS VH
                            WHERE VH.CODIGO_ACCIDENTE = V.CODIGO_ACCIDENTE
                              AND VH.CODIGO_VEHICULO = V.CODIGO_VEHICULO) AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VICTIMAS V, SIGAT.LESIONES L
           WHERE V.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND L.CODIGO_ACCIDENTADO = V.CODIGO_ACCIDENTADO
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
        OPEN PCURSOR FOR
        
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          0 VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          /*Lesion*/
                          NVL(L.CODIGO_LESION, ' ') AS LESION_CODIGO_TIPO
                          /*NULL AS LESION_CODIGO_TIPO*/,
                          NVL((SELECT NOMBRE
                              FROM TIPOS_LESIONES TP
                           WHERE TP.CODIGO_LESION = L.CODIGO_LESION),
                          ' ') AS LESION_NOMBRE_TIPO,
                          NVL(FN_DOMVALOR('cDomAccCondicionVictima',
                                          V.CONDICION),
                              'CONDUCTOR') || ' - ' ||
                          (SELECT NVL(FN_DOMVALOR('cDomAccClaseVehiculo',
                                                  VH.CLASE),
                                      ' ')
                             FROM SIGAT.VEHICULOS VH
                            WHERE VH.CODIGO_ACCIDENTE = V.CODIGO_ACCIDENTE
                              AND VH.CODIGO_VEHICULO = V.CODIGO_VEHICULO) AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VICTIMAS V, SIGAT.LESIONES L
           WHERE V.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND L.CODIGO_ACCIDENTADO = V.CODIGO_ACCIDENTADO
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'EXAMENES') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          V.CODIGO_VICTIMA AS VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          V.CODIGO_VEHICULO AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          /*Examenes*/
                          NVL(V.CODIGO_ACCIDENTADO, 0) AS VICTIMA_EXAMEN,
                          NVL(FN_DOMVALOR('cDomAccExamenes', EX.EXAMEN),
                              ' ') AS VICTIMA_FORMULARIO,
                          NVL(FN_DOMVALOR('cDomAccGradoExamen',
                                          EX.GRADO_EXAMEN),
                              ' ') AS VICTIMA_GRADO_EXAMEN,
                          NVL(FN_DOMVALOR('cDomAccResultados',
                                          EX.RESULTADO_EXAMEN),
                              ' ') AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VICTIMAS V, SIGAT.EXAMENES EX
           WHERE V.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND EX.CODIGO_ACCIDENTADO = V.CODIGO_ACCIDENTADO
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf);
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
        OPEN PCURSOR FOR
           SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          NVL(A.OTRO_CLASE, ' ') AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          /*Victimas*/
                          V.CODIGO_VICTIMA AS VICTIMA_NUMERO, --Listo
                          ' ' AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0 VICTIMA_EDAD, --Listo
                          ' ' VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          ' ' VICTIMA_DIRECCION, -- Listo
                          ' ' VICTIMA_CODIGO_MUNICIPIO, --Listo
                          ' ' VICTIMA_TELEFONO, --Listo
                          ' ' VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0 VICTIMA_CODIGO_CLINICA, --Listo
                          ' ' VICTIMA_LLEVA_CASCO, --Listo
                          ' ' VICTIMA_PEATON_PASAJERO, --Listo
                          0 VICTIMA_CODIGO_VEHICULO, --Listo
                          ' ' VICTIMA_SEXO, --Listo
                          ' ' VICTIMA_GRAVEDAD, --Listo
                          ' ' VICTIMA_VALORADA, --Listo
                          ' ' VICTIMA_FALLECE, --Listo
                          ' ' VICTIMA_FECHA_MUERTE, --Listo
                          ' ' VICTIMA_CLASE_OFICIAL, --Listo
                          ' ' VICTIMA_GRADO_OFICIAL, --Listo
                          ' ' VICTIMA_UNIDAD_OFICIAL, --Listo
                          ' ' VICTIMA_ESTABA_SERVICIO, --Listo
                          ' ' AS VICTIMA_TRASLADADO, --Listo ***
                          ' ' AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          V.CODIGO_VEHICULO AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          NULL AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          /*Examenes*/
                          NVL(V.CODIGO_ACCIDENTADO, 0) AS VICTIMA_EXAMEN,
                          NVL(FN_DOMVALOR('cDomAccExamenes', EX.EXAMEN),
                              ' ') AS VICTIMA_FORMULARIO,
                          NVL(FN_DOMVALOR('cDomAccGradoExamen',
                                          EX.GRADO_EXAMEN),
                              ' ') AS VICTIMA_GRADO_EXAMEN,
                          NVL(FN_DOMVALOR('cDomAccResultados',
                                          EX.RESULTADO_EXAMEN),
                              ' ') AS VICTIMA_RESULTADO_EXAMEN,
                          
                          NULL AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          NULL AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          NULL AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          NULL AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
          
            FROM SIGAT.ACCIDENTE A, SIGAT.VICTIMAS V, SIGAT.EXAMENES EX
           WHERE V.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND EX.CODIGO_ACCIDENTADO = V.CODIGO_ACCIDENTADO
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)));
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'SENIALES_DEMARCACIONES') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          NULL CODIGO_OFICINA, --Listo 5
                          NULL CODIGO_GRAVEDAD, --Listo 6
                          NULL NOMBRE_GRAVEDAD, --Listo 7
                          NULL CODIGO_CLASE, --Listo 8
                          NULL NOMBRE_CLASE, --Listo 9
                          NULL CODIGO_CHOQUE, --Listo 10
                          NULL NOMBRE_CHOQUE, --Listo 11
                          NULL AS TIPO_COLISION, --Listo 12***
                          NULL AS NOMBRE_COLISION, --Listo 13***
                          
                          NULL AS COTRA_CLASE, --Listo 14***
                          NULL AS OTRA_CLASE, --Listo 15***
                          NULL AS LATITUD, -- Listo 16
                          NULL AS LONGITUD, --Listo 17
                          NULL AS DIRECCION, --Listo 18
                          NULL TIPO_VIA_1, --Listo 19
                          A.DIRNUMERO NUMERO_VIA_1, --Listo 20
                          NULL LETRA_VIA_1, --Listo 21
                          NULL CARDINAL_VIA_1, --Listo 22
                          NULL TIPO_VIA_2, --Listo 23
                          NULL NUMERO_VIA_2, --Listo 24
                          NULL LETRA_VIA_2, --Listo 25
                          NULL CARDINAL_VIA_2, --Listo 26
                          NULL COMPLEMENTO, --Listo 27
                          NULL NOMBRE_MUNICIPIO, --Listo 28
                          NULL NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          NULL HORA_OCURRENCIA, --Listo 31
                          NULL HORA_LEVANTAMIENTO, --Listo 32
                          NULL CODIGO_AREA_LUGAR, --Listo 33
                          NULL CODIGO_SECTOR_LUGAR, --Listo 34
                          NULL CODIGO_ZONA_LUGAR, --Listo 35
                          NULL CODIGO_DISENO_LUGAR, --Listo 36
                          NULL CODIGO_TIEMPO_LUGAR, --Listo 37
                          NULL CODIGO_ZONA_TRANSITO, --Listo 38
                          NULL AS CODIGO_AREA_TRANSITO, --Listo 39
                          NULL AS CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NULL AS TOTAL_MUERTOS, --Listo 41
                          NULL AS TOTAL_HERIDOS, --Listo 42
                          NULL CODIGO_AGENTE_1, --Listo 43
                          NULL AS CODIGO_AGENTE_2, --Listo 44
                          
                          NULL AS CORRESPONDIO, --Listo 45
                          NULL AS CODIGO_DEPARTAMETO, --Listo 46***
                          NULL AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          NULL AS ANO_CORRESPONDIO, --Listo 49***
                          NULL AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NULL NOMBRE_TESTIGO, --Listo 67
                          NULL CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NULL NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NULL DIRECCION_TESTIGO, --listo 70
                          NULL CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NULL TELEFONO_TESTIGO, --Listo 72
                          0    as coordenadax,
                          0    as coordenaday,
                          /*Victimas*/
                          0    VICTIMA_NUMERO, --Listo
                          NULL AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0    VICTIMA_EDAD, --Listo
                          NULL VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NULL VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NULL VICTIMA_DIRECCION, -- Listo
                          NULL VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NULL VICTIMA_TELEFONO, --Listo
                          NULL VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0    VICTIMA_CODIGO_CLINICA, --Listo
                          NULL VICTIMA_LLEVA_CASCO, --Listo
                          NULL VICTIMA_PEATON_PASAJERO, --Listo
                          0    VICTIMA_CODIGO_VEHICULO, --Listo
                          NULL VICTIMA_SEXO, --Listo
                          NULL VICTIMA_GRAVEDAD, --Listo
                          NULL VICTIMA_VALORADA, --Listo
                          NULL VICTIMA_FALLECE, --Listo
                          NULL VICTIMA_FECHA_MUERTE, --Listo
                          NULL VICTIMA_CLASE_OFICIAL, --Listo
                          NULL VICTIMA_GRADO_OFICIAL, --Listo
                          NULL VICTIMA_UNIDAD_OFICIAL, --Listo
                          NULL VICTIMA_ESTABA_SERVICIO, --Listo
                          NULL AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          VI.CODIGO_VIA AS VIA_NUMERO_VIA_FORM,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL          AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL          AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL          AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL          AS VIA_NOMBRE_ESTADO,
                          NULL          AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL          AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL          AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL          AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL          AS VIA_EXISTE_AGENTE,
                          NULL          AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL          AS VIA_VISUAL_NORMAL, --***
                          NULL          AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          TO_CHAR(NVL(sigat.utilidades.GetSenialVert(A.CODIGO_ACCIDENTE,
                                                                     VI.CODIGO_VIA,
                                                                     'ID'),
                                      ' ')) AS SENIAL_CODIGO,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialVert(A.CODIGO_ACCIDENTE,
                                                                     VI.CODIGO_VIA,
                                                                     'VA'),
                                      ' ')) AS SENIAL_NOMBRE,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialDemar(A.CODIGO_ACCIDENTE,
                                                                      VI.CODIGO_VIA,
                                                                      'ID'),
                                      ' ')) AS SENIAL_CODIGO_DEMARCACION,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialDemar(A.CODIGO_ACCIDENTE,
                                                                      VI.CODIGO_VIA,
                                                                      'VA'),
                                      ' ')) AS SENIAL_NOMBRE_DEMARCACION, --***
                          TO_CHAR(NVL(sigat.utilidades.GetReductorVelocidad(A.CODIGO_ACCIDENTE,
                                                                            VI.CODIGO_VIA,
                                                                            'ID'),
                                      ' ')) AS SENIAL_CODIGO_REDUCTOR_VEL,
                          TO_CHAR(NVL(sigat.utilidades.GetReductorVelocidad(A.CODIGO_ACCIDENTE,
                                                                            VI.CODIGO_VIA,
                                                                            'VA'),
                                      ' ')) AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          TO_CHAR(NVL(sigat.utilidades.GetDelimPiso(A.CODIGO_ACCIDENTE,
                                                                    VI.CODIGO_VIA,
                                                                    'ID'),
                                      ' ')) AS SENIAL_CODIGO_DELINEADOR, --***
                          TO_CHAR(NVL(sigat.utilidades.GetDelimPiso(A.CODIGO_ACCIDENTE,
                                                                    VI.CODIGO_VIA,
                                                                    'VA'),
                                      ' ')) AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE          A,
                 SIGAT.VIAS               VI,
                 SIGAT.SENIAL_HORIZONTAL  SD,
                 SIGAT.REDUCTOR_VELOCIDAD RV,
                 SIGAT.DELINEADORES_PISO  DP
           WHERE SD.CODIGO_FORMULARIO = to_char(A.CODIGO_ACCIDENTE)
             AND SD.CODIGO_VIA = VI.CODIGO_VIA
             AND RV.CODIGO_FORMULARIO = SD.CODIGO_FORMULARIO
             AND RV.CODIGO_VIA = VI.CODIGO_VIA
             AND DP.CODIGO_FORMULARIO = rv.codigo_formulario
             AND DP.CODIGO_VIA = VI.CODIGO_VIA
             AND VI.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND A.FORMULARIO IN
                 (SELECT lf.idformulario FROM sigat.lista_formularios lf)
           GROUP BY A.CODIGO_ACCIDENTE,
                    A.FORMULARIO,
                    A.FECHA,
                    SD.CODIGO_FORMULARIO,
                    A.DIRNUMERO,
                    SD.SENIAL,
                    VI.CODIGO_VIA;
      
        --log
        --        INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('entro a SENIALES / Lista ');
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
        OPEN PCURSOR FOR
        
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          NULL CODIGO_OFICINA, --Listo 5
                          NULL CODIGO_GRAVEDAD, --Listo 6
                          NULL NOMBRE_GRAVEDAD, --Listo 7
                          NULL CODIGO_CLASE, --Listo 8
                          NULL NOMBRE_CLASE, --Listo 9
                          NULL CODIGO_CHOQUE, --Listo 10
                          NULL NOMBRE_CHOQUE, --Listo 11
                          NULL AS TIPO_COLISION, --Listo 12***
                          NULL AS NOMBRE_COLISION, --Listo 13***
                          
                          NULL AS COTRA_CLASE, --Listo 14***
                          NULL AS OTRA_CLASE, --Listo 15***
                          NULL AS LATITUD, -- Listo 16
                          NULL AS LONGITUD, --Listo 17
                          NULL AS DIRECCION, --Listo 18
                          NULL TIPO_VIA_1, --Listo 19
                          A.DIRNUMERO NUMERO_VIA_1, --Listo 20
                          NULL LETRA_VIA_1, --Listo 21
                          NULL CARDINAL_VIA_1, --Listo 22
                          NULL TIPO_VIA_2, --Listo 23
                          NULL NUMERO_VIA_2, --Listo 24
                          NULL LETRA_VIA_2, --Listo 25
                          NULL CARDINAL_VIA_2, --Listo 26
                          NULL COMPLEMENTO, --Listo 27
                          NULL NOMBRE_MUNICIPIO, --Listo 28
                          NULL NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          NULL HORA_OCURRENCIA, --Listo 31
                          NULL HORA_LEVANTAMIENTO, --Listo 32
                          NULL CODIGO_AREA_LUGAR, --Listo 33
                          NULL CODIGO_SECTOR_LUGAR, --Listo 34
                          NULL CODIGO_ZONA_LUGAR, --Listo 35
                          NULL CODIGO_DISENO_LUGAR, --Listo 36
                          NULL CODIGO_TIEMPO_LUGAR, --Listo 37
                          NULL CODIGO_ZONA_TRANSITO, --Listo 38
                          NULL AS CODIGO_AREA_TRANSITO, --Listo 39
                          NULL AS CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NULL AS TOTAL_MUERTOS, --Listo 41
                          NULL AS TOTAL_HERIDOS, --Listo 42
                          NULL CODIGO_AGENTE_1, --Listo 43
                          NULL AS CODIGO_AGENTE_2, --Listo 44
                          
                          NULL AS CORRESPONDIO, --Listo 45
                          NULL AS CODIGO_DEPARTAMETO, --Listo 46***
                          NULL AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          NULL AS ANO_CORRESPONDIO, --Listo 49***
                          NULL AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NULL NOMBRE_TESTIGO, --Listo 67
                          NULL CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NULL NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NULL DIRECCION_TESTIGO, --listo 70
                          NULL CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NULL TELEFONO_TESTIGO, --Listo 72
                          0    as coordenadax,
                          0    as coordenaday,
                          /*Victimas*/
                          0    VICTIMA_NUMERO, --Listo
                          NULL AS VICTIMA_NOMBRE, --Listo
                          NULL AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          0    VICTIMA_EDAD, --Listo
                          NULL VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NULL VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NULL VICTIMA_DIRECCION, -- Listo
                          NULL VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NULL VICTIMA_TELEFONO, --Listo
                          NULL VICTIMA_LLEVA_CINTURON, --Listo
                          NULL AS VICTIMA_LLEVA_CHALECO, --Listo
                          0    VICTIMA_CODIGO_CLINICA, --Listo
                          NULL VICTIMA_LLEVA_CASCO, --Listo
                          NULL VICTIMA_PEATON_PASAJERO, --Listo
                          0    VICTIMA_CODIGO_VEHICULO, --Listo
                          NULL VICTIMA_SEXO, --Listo
                          NULL VICTIMA_GRAVEDAD, --Listo
                          NULL VICTIMA_VALORADA, --Listo
                          NULL VICTIMA_FALLECE, --Listo
                          NULL VICTIMA_FECHA_MUERTE, --Listo
                          NULL VICTIMA_CLASE_OFICIAL, --Listo
                          NULL VICTIMA_GRADO_OFICIAL, --Listo
                          NULL VICTIMA_UNIDAD_OFICIAL, --Listo
                          NULL VICTIMA_ESTABA_SERVICIO, --Listo
                          NULL AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          /*Conductor*/
                          NULL AS VEHICULO_NUMERO,
                          NULL AS CONDUCTOR_NOMBRE,
                          NULL AS CONDUCTOR_FECHA_NACIMIENTO,
                          NULL AS CONDUCTOR_EDAD,
                          NULL AS CONDUCTOR_COD_TIPO_ID,
                          NULL AS CONDUCTOR_NUMERO_ID,
                          NULL AS CONDUCTOR_DIRECCION,
                          NULL AS CONDUCTOR_MUNICIPIO,
                          NULL AS CONDUCTOR_TELEFONO,
                          NULL AS CONDUCTOR_LLEVA_CITURON,
                          NULL AS CONDUCTOR_LLEVA_CHALECO,
                          NULL AS CONDUCTOR_NOMBRE_CLINICA,
                          NULL AS CONDUCTOR_LLEVA_CASCO,
                          NULL AS CONDUCTOR_SEXO,
                          NULL AS CONDUCTOR_GRAVEDAD,
                          NULL AS CONDUCTOR_VALORADO,
                          NULL AS CONDUCTOR_TRASLADADO_EN,
                          NULL AS CONDUCTOR_FALLECE_POST,
                          NULL AS CONDUCTOR_FECHA_MUERTE,
                          NULL AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NULL AS CONDUCTOR_GRADO_OFICIAL,
                          NULL AS CONDUCTOR_UNIDAD_OFICIAL,
                          NULL AS CONDUCTOR_ESTABA_SERVICIO,
                          NULL AS CONDUCTOR_PORTA_LICENCIA,
                          NULL AS CONDUCTOR_NUMERO_LICENCIA,
                          NULL AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NULL AS CONDUCTOR_NOMBRE_RESTRICCION,
                          NULL AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NULL AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NULL AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          NULL AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NULL AS CONDUCTOR_NUM_ID_PROP,
                          NULL AS VEHICULO_FUGA,
                          NULL AS VEHICULO_NUMERO_PLACA,
                          NULL AS VEHICULO_PLACA_REMOLQUE,
                          NULL AS VEHICULO_MARCA,
                          NULL AS VEHICULO_MODELO,
                          NULL AS VEHICULO_CAPACIDAD_CARGA,
                          NULL AS VEHICULO_CANTIDAD_PASAJEROS,
                          NULL AS VEHICULO_COLOR,
                          NULL AS VEHICULO_NUMERO_REV_TECNO,
                          NULL AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NULL AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NULL AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NULL AS VEHICULO_FISCALIA_JUZGADO,
                          NULL AS VEHICULO_SOAT,
                          NULL AS VEHICULO_COD_EMP_SOAT,
                          NULL AS VEHICULO_FECHA_VENC_SOAT,
                          NULL AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          NULL AS VEHICULO_MODALIDAD, --***
                          NULL AS VEHICULO_RADIO_ACCION, --***
                          NULL AS VEHICULO_COD_NACIONALIDAD,
                          NULL AS VEHICULO_SEGURO_RESPONS,
                          NULL AS VEHICULO_NOMB_TIPO_FALLA,
                          NULL AS VEHICULO_INMOVILIZADO_EN,
                          NULL AS VEHICULO_A_DISPOSICION_DE,
                          
                          VI.CODIGO_VIA AS VIA_NUMERO_VIA_FORM,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL          AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL          AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL          AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL          AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL          AS VIA_NOMBRE_ESTADO,
                          NULL          AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL          AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL          AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL          AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL          AS VIA_EXISTE_AGENTE,
                          NULL          AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL          AS VIA_VISUAL_NORMAL, --***
                          NULL          AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          NULL AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          TO_CHAR(NVL(sigat.utilidades.GetSenialVert(A.CODIGO_ACCIDENTE,
                                                                     VI.CODIGO_VIA,
                                                                     'ID'),
                                      ' ')) AS SENIAL_CODIGO,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialVert(A.CODIGO_ACCIDENTE,
                                                                     VI.CODIGO_VIA,
                                                                     'VA'),
                                      ' ')) AS SENIAL_NOMBRE,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialDemar(A.CODIGO_ACCIDENTE,
                                                                      VI.CODIGO_VIA,
                                                                      'ID'),
                                      ' ')) AS SENIAL_CODIGO_DEMARCACION,
                          TO_CHAR(NVL(sigat.utilidades.GetSenialDemar(A.CODIGO_ACCIDENTE,
                                                                      VI.CODIGO_VIA,
                                                                      'VA'),
                                      ' ')) AS SENIAL_NOMBRE_DEMARCACION, --***
                          TO_CHAR(NVL(sigat.utilidades.GetReductorVelocidad(A.CODIGO_ACCIDENTE,
                                                                            VI.CODIGO_VIA,
                                                                            'ID'),
                                      ' ')) AS SENIAL_CODIGO_REDUCTOR_VEL,
                          TO_CHAR(NVL(sigat.utilidades.GetReductorVelocidad(A.CODIGO_ACCIDENTE,
                                                                            VI.CODIGO_VIA,
                                                                            'VA'),
                                      ' ')) AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          TO_CHAR(NVL(sigat.utilidades.GetDelimPiso(A.CODIGO_ACCIDENTE,
                                                                    VI.CODIGO_VIA,
                                                                    'ID'),
                                      ' ')) AS SENIAL_CODIGO_DELINEADOR, --***
                          TO_CHAR(NVL(sigat.utilidades.GetDelimPiso(A.CODIGO_ACCIDENTE,
                                                                    VI.CODIGO_VIA,
                                                                    'VA'),
                                      ' ')) AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE          A,
                 SIGAT.VIAS               VI,
                 SIGAT.SENIAL_HORIZONTAL  SD,
                 SIGAT.REDUCTOR_VELOCIDAD RV,
                 SIGAT.DELINEADORES_PISO  DP
           WHERE SD.CODIGO_FORMULARIO = to_char(A.CODIGO_ACCIDENTE)
             AND SD.CODIGO_VIA = VI.CODIGO_VIA
             AND RV.CODIGO_FORMULARIO = SD.CODIGO_FORMULARIO
             AND RV.CODIGO_VIA = VI.CODIGO_VIA
             AND DP.CODIGO_FORMULARIO = rv.codigo_formulario
             AND DP.CODIGO_VIA = VI.CODIGO_VIA
             AND VI.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)))
           GROUP BY A.CODIGO_ACCIDENTE,
                    A.FORMULARIO,
                    A.FECHA,
                    SD.CODIGO_FORMULARIO,
                    A.DIRNUMERO,
                    SD.SENIAL,
                    VI.CODIGO_VIA;
      
        --        INSERT INTO SIGAT.LOGPLANOSMRBORR(log)values('entro a SENIALES / fecha ');
      END IF;
    
    ELSIF (PTIPO_REPORTE = 'CONSOLIDADO') THEN
    
      IF PLISTA_FORMULARIOS IS NOT NULL AND PFECHA_DESDE IS NULL AND
         PFECHA_HASTA IS NULL THEN
        OPEN PCURSOR FOR
          SELECT DISTINCT (A.CODIGO_ACCIDENTE) AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          A.OTRO_CLASE AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          
                          /*Victimas*/
                          NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          (sigat.fn_calcular_edad(a.fecha,
                                                  C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                          NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                          NVL(C.CODIGO_MUNICIPIO, ' ') VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                          NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                          NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo
                          NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                          NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                          FN_DOMVALOR('cDomAccCondicionVictima',
                                      C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                          NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS VICTIMA_SEXO, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') VICTIMA_GRAVEDAD, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                          C.GRAVEDAD_LESION),
                              ' ') VICTIMA_VALORADA, --Listo
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') VICTIMA_FALLECE, --Listo
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                          NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo
                          NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                          NVL(ut.nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                          NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                          NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          
                          NVL(VH.CODIGO_VEHICULO, 0) AS VEHICULO_NUMERO,
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS CONDUCTOR_NOMBRE,
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS CONDUCTOR_FECHA_NACIMIENTO,
                          NVL(sigat.fn_calcular_edad(a.fecha,
                                                     C.FECHA_NACIMIENTO),
                              0) AS CONDUCTOR_EDAD,
                          DECODE(C.TIPO_IDENTIFICACION,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID,
                          
                          NVL(C.NUMERO_IDENTIFICACION, 0) AS CONDUCTOR_NUMERO_ID,
                          NVL(C.DIRECCION, ' ') AS CONDUCTOR_DIRECCION,
                          NVL((SELECT mu.nombre
                                FROM sigat.municipios mu
                               WHERE mu.codigo_municipio =
                                     c.codigo_municipio
                                 AND rownum = 1),
                              ' ') AS CONDUCTOR_MUNICIPIO,
                          
                          C.TELEFONO AS CONDUCTOR_TELEFONO,
                          NVL(C.CON_CINTURON, ' ') AS CONDUCTOR_LLEVA_CITURON,
                          NVL(C.Chaleco, ' ') AS CONDUCTOR_LLEVA_CHALECO,
                          NVL(C.Clinica_Atencion, 0) AS CONDUCTOR_NOMBRE_CLINICA,
                          
                          NVL(C.CON_CASCO, ' ') AS CONDUCTOR_LLEVA_CASCO,
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS CONDUCTOR_SEXO,
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') AS CONDUCTOR_GRAVEDAD,
                          NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                          C.GRAVEDAD_LESION),
                              ' ') AS CONDUCTOR_VALORADO,
                          NVL(C.TRASLADADO, ' ') AS CONDUCTOR_TRASLADADO_EN,
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') AS CONDUCTOR_FALLECE_POST,
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') AS CONDUCTOR_FECHA_MUERTE,
                          NVL(C.CLASE_OFICIAL, 0) AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NVL(gt.nombre, ' ') AS CONDUCTOR_GRADO_OFICIAL,
                          NVL(ut.nombre, ' ') AS CONDUCTOR_UNIDAD_OFICIAL,
                          NVL(C.ENSERVICIO, ' ') AS CONDUCTOR_ESTABA_SERVICIO,
                          NVL(DECODE(CON.PORTA_LICENCIA,
                                     '100',
                                     ' ',
                                     CON.PORTA_LICENCIA),
                              ' ') AS CONDUCTOR_PORTA_LICENCIA,
                          NVL(TO_CHAR(CON.NUMERO_LICENCIA), ' ') AS CONDUCTOR_NUMERO_LICENCIA,
                          NVL(CON.CATEGORIA_LICENCIA, ' ') AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NVL(FN_DOMVALOR('cDomAccRestriccionPase',
                                          CON.RESTRICCIONES),
                              ' ') AS CONDUCTOR_NOMBRE_RESTRICCION,
                          TRUNC(CON.FECHA_LICENCIA) AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NVL(CON.PROPIETARIO, ' ') AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NVL(CON.NOMBRE_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.PRIMERAPELLIDO_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.SEGAPELLIDO_PROPIETARIO, ' ') AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          DECODE(CON.TIPOIDENT_PROPIETARIO,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NVL(CON.NUMIDENT_PROPIETARIO, 0) AS CONDUCTOR_NUM_ID_PROP,
                          NVL(VH.ENFUGA, 'N') AS VEHICULO_FUGA,
                          NVL(VH.PLACA, ' ') AS VEHICULO_NUMERO_PLACA,
                          NVL(VH.PLACA_REMOLQUE, ' ') AS VEHICULO_PLACA_REMOLQUE,
                          NVL((SELECT MV.MARCA || ' ' || MV.LINEA
                                FROM SIGAT.MARCA_VEHICULOS MV
                               WHERE MV.CODIGO_MARCACARRO =
                                     VH.CODIGO_MARCACARRO
                                 AND ROWNUM = 1),
                              ' ') AS VEHICULO_MARCA,
                          NVL(VH.MODELO, ' ') AS VEHICULO_MODELO,
                          NVL(VH.CARGA, 0) AS VEHICULO_CAPACIDAD_CARGA,
                          NVL(VH.PASAJERO, 0) AS VEHICULO_CANTIDAD_PASAJEROS,
                          NVL(VH.COLOR, ' ') AS VEHICULO_COLOR,
                          NVL(VH.REV_TECNICOMECANICA, ' ') AS VEHICULO_NUMERO_REV_TECNO,
                          NVL(VH.EMPRESA, ' ') AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NVL((SELECT E.NOMBRE
                                FROM SIGAT.EMPRESAS E
                               WHERE E.CODIGO_EMPRESA = VH.EMPRESA),
                              'NO EXISTE') AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          VH.INMOVILIZADO),
                              ' ') AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NVL(FN_DOMVALOR('cDomAccTipoDisposicion',
                                          VH.DISPOSICION),
                              ' ') AS VEHICULO_FISCALIA_JUZGADO,
                          NVL(VH.NUMERO_SOAT, ' ') AS VEHICULO_SOAT,
                          NVL(VH.ASEGURADORA, ' ') AS VEHICULO_COD_EMP_SOAT,
                          TRUNC(VH.VENCIMIENTO_SOAT) AS VEHICULO_FECHA_VENC_SOAT,
                          FN_DOMVALOR('cDomAccClaseVehiculo', VH.CLASE) AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          FN_DOMVALOR('cDomAccModalidadTranporteMasivo',
                                      VH.MODALIDAD) AS VEHICULO_MODALIDAD, --***
                          FN_DOMVALOR('cDomAccTipoServicio', VH.SERVICIO) AS VEHICULO_RADIO_ACCION, --***
                          NVL(VH.NACIONALIDAD, ' ') AS VEHICULO_COD_NACIONALIDAD,
                          DECODE(VH.SEGURO, '100', ' ', VH.SEGURO) AS VEHICULO_SEGURO_RESPONS,
                          NVL(FN_DOMVALOR('cDomAccTipoFalla', VH.FALLAS),
                              ' ') AS VEHICULO_NOMB_TIPO_FALLA,
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          VH.INMOVILIZADO),
                              ' ') AS VEHICULO_INMOVILIZADO_EN,
                          NVL(VH.DETALLE_DISPOSICION, ' ') AS VEHICULO_A_DISPOSICION_DE,
                          
                          0    AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          0    AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          0    AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          0    AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          0    AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE   A,
                 SIGAT.VICTIMAS    C,
                 SIGAT.CONDUCTORES CON,
                 --         SIGAT.VIAS        VI,
                 --        SIGAT.LESIONES    L,
                 SIGAT.VEHICULOS   VH,
                 grados_transito   gt,
                 unidades_transito ut
           WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE(+)
             AND C.CODIGO_ACCIDENTADO = CON.CODIGO_ACCIDENTADO(+)
                --    AND A.CODIGO_ACCIDENTE = VI.CODIGO_ACCIDENTE(+)
                -- AND C.CODIGO_ACCIDENTADO = L.CODIGO_ACCIDENTADO(+)
             AND VH.CODIGO_ACCIDENTE(+) = A.CODIGO_ACCIDENTE
             AND C.CODIGO_VEHICULO = VH.CODIGO_VEHICULO
             AND c.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
             AND A.FORMULARIO IN
                 (SELECT LF.IDFORMULARIO FROM SIGAT.LISTA_FORMULARIOS LF)
           ORDER BY A.CODIGO_ACCIDENTE;
      
      ELSIF PLISTA_FORMULARIOS IS NULL AND PFECHA_DESDE IS NOT NULL AND
            PFECHA_HASTA IS NOT NULL THEN
        OPEN PCURSOR FOR
          SELECT DISTINCT A.CODIGO_ACCIDENTE AS CODIGO_ACCIDENTE, --Listo 1
                          A.FORMULARIO AS NUMERO_FORMULARIO, --Listo 2
                          TO_CHAR(TRUNC(A.FECHA), 'DAY') AS NOMBRE_DIA, --Listo 3
                          TRUNC(A.FECHA) FECHA_INFORME, --Listo 4
                          A.OFICINA CODIGO_OFICINA, --Listo 5
                          NVL(A.GRAVEDAD, ' ') CODIGO_GRAVEDAD, --Listo 6
                          NVL(FN_DOMVALOR('cDomAccGravedad', A.GRAVEDAD),
                              'Ilesa') NOMBRE_GRAVEDAD, --Listo 7
                          NVL(A.CLASE, ' ') CODIGO_CLASE, --Listo 8
                          NVL(FN_DOMVALOR('cDomAccClaseAccidente', A.CLASE),
                              ' ') NOMBRE_CLASE, --Listo 9
                          NVL(A.CHOQUE, ' ') CODIGO_CHOQUE, --Listo 10
                          NVL(FN_DOMVALOR('cDomAccChoque', A.CHOQUE), ' ') NOMBRE_CHOQUE, --Listo 11
                          NVL(A.TIPO_COLISION, ' ') AS TIPO_COLISION, --Listo 12***
                          NVL(FN_DOMVALOR('cDomAccTipoColision',
                                          A.TIPO_COLISION),
                              ' ') AS NOMBRE_COLISION, --Listo 13***
                          A.OTRO_CLASE AS COTRA_CLASE, --Listo 14***
                          NVL(FN_DOMVALOR('cDomAccChoqueOtro', A.OTRO_CLASE),
                              ' ') AS OTRA_CLASE, --Listo 15***
                          NVL(A.LATITUD, 0) LATITUD, -- Listo 16
                          NVL(A.LONGITUD, 0) LONGITUD, --Listo 17
                          NVL(A.DIRECCION, ' ') DIRECCION, --Listo 18
                          NVL(A.DIRTIPOVIA, ' ') TIPO_VIA_1, --Listo 19
                          NVL(A.DIRNUMERO, ' ') NUMERO_VIA_1, --Listo 20
                          NVL(A.DIRLETRA, ' ') LETRA_VIA_1, --Listo 21
                          NVL(NVL(A.DIRVIAESTE, A.DIRVIASUR), ' ') CARDINAL_VIA_1, --Listo 22
                          NVL(A.DIRTIPOVIA2, ' ') TIPO_VIA_2, --Listo 23
                          NVL(A.DIRNUMERO2, ' ') NUMERO_VIA_2, --Listo 24
                          NVL(A.DIRLETRA2, ' ') LETRA_VIA_2, --Listo 25
                          NVL(NVL(A.DIRVIAESTE2, A.DIRVIASUR2), ' ') CARDINAL_VIA_2, --Listo 26
                          NVL(A.DIRCOMPLEMENTO, ' ') COMPLEMENTO, --Listo 27
                          NVL((SELECT MU.NOMBRE
                                FROM SIGAT.MUNICIPIOS MU
                               WHERE MU.CODIGO_MUNICIPIO =
                                     SUBSTR(A.CODIGO_MUNICIPIO, 1, 5)
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_MUNICIPIO, --Listo 28
                          NVL((SELECT LA.NOMBRE
                                FROM SIGAT.LOCALIDADES LA
                               WHERE LA.CODIGO_LOCALIDAD =
                                     A.CODIGO_LOCALIDAD
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_LOCALIDAD, --Listo 29
                          TRUNC(A.FECHA) FECHA_OCURRENCIA, --Listo 30
                          TO_CHAR(A.FECHA, 'HH24:MI') HORA_OCURRENCIA, --Listo 31
                          TO_CHAR(A.HORA_LEVANTAMIENTO, 'HH24:MI') HORA_LEVANTAMIENTO, --Listo 32
                          NVL(A.AREA_LUGAR, ' ') CODIGO_AREA_LUGAR, --Listo 33
                          NVL(A.SECTOR_LUGAR, ' ') CODIGO_SECTOR_LUGAR, --Listo 34
                          NVL(A.ZONA_LUGAR, ' ') CODIGO_ZONA_LUGAR, --Listo 35
                          NVL(FN_DOMVALOR('cDomAccLugarDiseno',
                                          A.DISENO_LUGAR),
                              ' ') CODIGO_DISENO_LUGAR, --Listo 36
                          NVL(SIGAT.UTILIDADES.GETTIEMPOLUGAR(A.FORMULARIO,
                                                              'VA'),
                              ' ') AS CODIGO_TIEMPO_LUGAR, --Listo 37
                          NVL((SELECT ZT.NOMBRE
                                FROM SIGAT.ZONAS_TRANSITO ZT
                               WHERE ZT.CODIGO_ZONA = A.ZONA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_ZONA_TRANSITO, --Listo 38
                          NVL((SELECT AT.NOMBRE
                                FROM SIGAT.AREAS_TRANSITO AT
                               WHERE AT.CODIGO_AREA = A.AREA_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_AREA_TRANSITO, --Listo 39
                          NVL((SELECT CV.NOMBRE
                                FROM SIGAT.CORREDORES_VIALES CV
                               WHERE CV.CODIGO_CORREDOR =
                                     A.CORREDOR_TRANSITO
                                 AND ROWNUM = 1),
                              ' ') CODIGO_CORREDOR_TRANSITO, --Listo 40
                          NVL(A.TOTAL_MUERTOS, 0) TOTAL_MUERTOS, --Listo 41
                          NVL(A.TOTAL_HERIDOS, 0) TOTAL_HERIDOS, --Listo 42
                          NVL(NVL((SELECT TG.PLACA || ' - ' || TG.NOMBRE
                                    FROM SIGAT.T_AGENTES TG
                                   WHERE TG.PLACA = A.PLACA
                                     AND ROWNUM = 1),
                                  (SELECT TG.PLACA || ' - ' || TG.NOMBRES
                                     FROM SIGAT.AGENTE_ACCIDENTE TG
                                    WHERE TG.CODIGO_ACCIDENTE =
                                          A.CODIGO_ACCIDENTE
                                      AND TG.CODIGO_FORMULARIO = A.FORMULARIO
                                      AND ROWNUM = 1)),
                              DECODE(NVL(A.PLACA, 'X'),
                                     'X',
                                     '',
                                     A.PLACA || '-') || ' ') CODIGO_AGENTE_1, --Listo 43
                          NVL(NULL, '') AS CODIGO_AGENTE_2, --Listo 44
                          NVL(FN_DOMVALOR('cDomAccAtencionAccidente',
                                          A.CORRESPONDIO),
                              ' ') CORRESPONDIO, --Listo 45
                          (select d.nombre
                             from sigat.departamentos d
                            where d.codigo_departamento = '11'
                              AND ROWNUM = 1) AS CODIGO_DEPARTAMETO, --Listo 46***
                          'BOGOTA D.C.' AS CODIGO_MUNICIPIO, --Listo 47***
                          NULL AS UNIDAD_RECEPTORA, --Listo 48*** Ojo
                          TO_CHAR(a.fecha, 'yyyy') AS ANO_CORRESPONDIO, --Listo 49***
                          ltrim(a.formulario, 'A0') AS CONSECUTIVO, --Listo 50***
                          
                          NULL AS codigo_hipotesis_conductor_1,
                          NULL AS descri_hipotesis_conductor_1,
                          NULL AS codigo_hipotesis_conductor_2,
                          NULL AS descri_hipotesis_conductor_2,
                          
                          NULL AS codigo_hipotesis_peaton_1,
                          NULL AS descri_hipotesis_peaton_1,
                          NULL AS codigo_hipotesis_peaton_2,
                          NULL AS descri_hipotesis_peaton_2,
                          
                          NULL AS codigo_hipotesis_vehiculo_1,
                          NULL AS descri_hipotesis_vehiculo_1,
                          NULL AS codigo_hipotesis_vehiculo_2,
                          NULL AS descri_hipotesis_vehiculo_2,
                          
                          NULL AS codigo_hipotesis_pasajero_1,
                          NULL AS descri_hipotesis_pasajero_1,
                          NULL AS codigo_hipotesis_pasajero_2,
                          NULL AS descri_hipotesis_pasajero_2, --Listo 66***
                          
                          0    AS codigo_hipotesis_via_1,
                          NULL AS descri_hipotesis_via_1,
                          0    AS codigo_hipotesis_via_2,
                          NULL AS descri_hipotesis_via_2,
                          
                          NVL((SELECT T.NOMBRE || ' ' || T.PRIMER_APELLIDO || ' ' ||
                                     T.SEGUNDO_APELLIDO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NOMBRE_TESTIGO, --Listo 67
                          NVL((SELECT T.TIPO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_IDENTIFICACION_TESTIGO, --Listo 68
                          NVL((SELECT T.NUMERO_IDENTIFICACION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') NUMERO_IDENTIFICACION_TESTIGO, --Listo 69
                          NVL((SELECT T.DIRECCION
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') DIRECCION_TESTIGO, --listo 70
                          NVL((SELECT T.CODIGO_MUNICIPIO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') CODIGO_MUNICIPIO_TESTIGO, --Listo 71
                          NVL((SELECT T.TELEFONO
                                FROM SIGAT.TESTIGOS T
                               WHERE T.CODIGO_ACCIDENTE =
                                     A.CODIGO_ACCIDENTE
                                 AND ROWNUM = 1),
                              ' ') TELEFONO_TESTIGO, --Listo 72
                          0 as coordenadax,
                          0 as coordenaday,
                          
                          /*Victimas*/
                          NVL(C.CODIGO_VICTIMA, 0) VICTIMA_NUMERO, --Listo
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS VICTIMA_NOMBRE, --Listo
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS VICTIMA_FECHA_NACIMIENTO, --Listo
                          (sigat.fn_calcular_edad(a.fecha,
                                                  C.FECHA_NACIMIENTO)) VICTIMA_EDAD, --Listo
                          NVL(C.CODIGO_ACCIDENTADO, 0) VICTIMA_CODIGO_IDENTIFICACION, --Listo
                          NVL(C.NUMERO_IDENTIFICACION, 0) VICTIMA_NUMERO_IDENTIFICACION, --Listo
                          NVL(C.DIRECCION, ' ') VICTIMA_DIRECCION, -- Listo
                          NVL(C.CODIGO_MUNICIPIO, ' ') VICTIMA_CODIGO_MUNICIPIO, --Listo
                          NVL(C.TELEFONO, ' ') VICTIMA_TELEFONO, --Listo
                          NVL(C.CON_CINTURON, ' ') VICTIMA_LLEVA_CINTURON, --Listo
                          NVL(C.CHALECO, ' ') AS VICTIMA_LLEVA_CHALECO, --Listo
                          NVL(C.CLINICA_ATENCION, 0) VICTIMA_CODIGO_CLINICA, --Listo
                          NVL(C.CON_CASCO, ' ') VICTIMA_LLEVA_CASCO, --Listo
                          FN_DOMVALOR('cDomAccCondicionVictima',
                                      C.CONDICION) AS VICTIMA_PEATON_PASAJERO, --Listo
                          NVL(C.CODIGO_VEHICULO, 0) AS VICTIMA_CODIGO_VEHICULO, --Listo
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS VICTIMA_SEXO, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') VICTIMA_GRAVEDAD, --Listo
                          NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                          C.GRAVEDAD_LESION),
                              ' ') VICTIMA_VALORADA, --Listo
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') VICTIMA_FALLECE, --Listo
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') VICTIMA_FECHA_MUERTE, --Listo
                          NVL(C.CLASE_OFICIAL, ' ') AS VICTIMA_CLASE_OFICIAL, --Listo
                          NVL(gt.nombre, ' ') VICTIMA_GRADO_OFICIAL, --Listo
                          NVL(ut.nombre, ' ') VICTIMA_UNIDAD_OFICIAL, --Listo
                          NVL(C.ENSERVICIO, ' ') VICTIMA_ESTABA_SERVICIO, --Listo
                          NVL(C.TRASLADADO, ' ') AS VICTIMA_TRASLADADO, --Listo ***
                          NULL AS VICTIMA_NACIONALIDAD, --Listo ***
                          NVL(VH.CODIGO_VEHICULO, 0) AS VEHICULO_NUMERO,
                          (C.NOMBRE || ' ' || C.Primer_Apellido || ' ' ||
                          C.Segundo_Apellido) AS CONDUCTOR_NOMBRE,
                          TO_CHAR(TRUNC(C.Fecha_Nacimiento), 'dd/mm/yyyy') AS CONDUCTOR_FECHA_NACIMIENTO,
                          NVL(sigat.fn_calcular_edad(a.fecha,
                                                     C.FECHA_NACIMIENTO),
                              0) AS CONDUCTOR_EDAD,
                          DECODE(C.TIPO_IDENTIFICACION,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID,
                          
                          NVL(C.NUMERO_IDENTIFICACION, 0) AS CONDUCTOR_NUMERO_ID,
                          NVL(C.DIRECCION, ' ') AS CONDUCTOR_DIRECCION,
                          NVL((SELECT mu.nombre
                                FROM sigat.municipios mu
                               WHERE mu.codigo_municipio =
                                     c.codigo_municipio
                                 AND rownum = 1),
                              ' ') AS CONDUCTOR_MUNICIPIO,
                          
                          NVL(C.TELEFONO, ' ') AS CONDUCTOR_TELEFONO,
                          NVL(C.CON_CINTURON, ' ') AS CONDUCTOR_LLEVA_CITURON,
                          NVL(C.Chaleco, ' ') AS CONDUCTOR_LLEVA_CHALECO,
                          NVL(C.Clinica_Atencion, 0) AS CONDUCTOR_NOMBRE_CLINICA,
                          
                          NVL(C.CON_CASCO, ' ') AS CONDUCTOR_LLEVA_CASCO,
                          DECODE(C.SEXO,
                                 'FE',
                                 'FEMENINO',
                                 'MA',
                                 'MASCULINO',
                                 'NO APLICA') AS CONDUCTOR_SEXO,
                          NVL(FN_DOMVALOR('cDomAccGravedadVictima',
                                          C.ESTADO),
                              'Ilesa') AS CONDUCTOR_GRAVEDAD,
                          NVL(FN_DOMVALOR('cDomAccGravedadLesion',
                                          C.GRAVEDAD_LESION),
                              ' ') AS CONDUCTOR_VALORADO,
                          NVL(C.TRASLADADO, ' ') AS CONDUCTOR_TRASLADADO_EN,
                          DECODE(C.MUERTE_POSTERIOR,
                                 'N', --'0',
                                 'NO',
                                 'S', --'1',
                                 'SI',
                                 'NO') AS CONDUCTOR_FALLECE_POST,
                          NVL(TO_CHAR(TRUNC(C.FECHA_CAMBIOGRAVEDAD)), ' ') AS CONDUCTOR_FECHA_MUERTE,
                          NVL(C.CLASE_OFICIAL, 0) AS CONDUCTOR_CLASE_OFICIAL, /*Aplica cuando el conductor pertenece a las fuerzas armadas*/
                          NVL(gt.nombre, ' ') AS CONDUCTOR_GRADO_OFICIAL,
                          NVL(ut.nombre, ' ') AS CONDUCTOR_UNIDAD_OFICIAL,
                          NVL(C.ENSERVICIO, ' ') AS CONDUCTOR_ESTABA_SERVICIO,
                          NVL(DECODE(CON.PORTA_LICENCIA,
                                     '100',
                                     ' ',
                                     CON.PORTA_LICENCIA),
                              ' ') AS CONDUCTOR_PORTA_LICENCIA,
                          NVL(TO_CHAR(CON.NUMERO_LICENCIA), ' ') AS CONDUCTOR_NUMERO_LICENCIA,
                          NVL(CON.CATEGORIA_LICENCIA, ' ') AS CONDUCTOR_CODIGO_CATEGORIA_LIC,
                          NVL(FN_DOMVALOR('cDomAccRestriccionPase',
                                          CON.RESTRICCIONES),
                              ' ') AS CONDUCTOR_NOMBRE_RESTRICCION,
                          TRUNC(CON.FECHA_LICENCIA) AS CONDUCTOR_FECHA_VEN_LICENCIA,
                          NVL(CON.PROPIETARIO, ' ') AS CONDUCTOR_PROPIETARIO_VEHICULO,
                          NVL(CON.NOMBRE_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.PRIMERAPELLIDO_PROPIETARIO, ' ') || ' ' ||
                          NVL(CON.SEGAPELLIDO_PROPIETARIO, ' ') AS CONDUCTOR_NOMBRE_PROPIETARIO,
                          DECODE(CON.TIPOIDENT_PROPIETARIO,
                                 'C',
                                 'CC',
                                 'T',
                                 'TI',
                                 'E',
                                 'CE',
                                 'N',
                                 'NIT',
                                 'P',
                                 'PA',
                                 'U',
                                 'NI',
                                 'IN') AS CONDUCTOR_COD_TIPO_ID_PROP,
                          NVL(CON.NUMIDENT_PROPIETARIO, 0) AS CONDUCTOR_NUM_ID_PROP,
                          NVL(VH.ENFUGA, 'N') AS VEHICULO_FUGA,
                          NVL(VH.PLACA, ' ') AS VEHICULO_NUMERO_PLACA,
                          NVL(VH.PLACA_REMOLQUE, ' ') AS VEHICULO_PLACA_REMOLQUE,
                          NVL((SELECT MV.MARCA || ' ' || MV.LINEA
                                FROM SIGAT.MARCA_VEHICULOS MV
                               WHERE MV.CODIGO_MARCACARRO =
                                     VH.CODIGO_MARCACARRO
                                 AND ROWNUM = 1),
                              ' ') AS VEHICULO_MARCA,
                          NVL(VH.MODELO, ' ') AS VEHICULO_MODELO,
                          NVL(VH.CARGA, 0) AS VEHICULO_CAPACIDAD_CARGA,
                          NVL(VH.PASAJERO, 0) AS VEHICULO_CANTIDAD_PASAJEROS,
                          NVL(VH.COLOR, ' ') AS VEHICULO_COLOR,
                          NVL(VH.REV_TECNICOMECANICA, ' ') AS VEHICULO_NUMERO_REV_TECNO,
                          NVL(VH.EMPRESA, ' ') AS VEHICULO_CODIGO_EMPRESA_PERT,
                          NVL((SELECT E.NOMBRE
                                FROM SIGAT.EMPRESAS E
                               WHERE E.CODIGO_EMPRESA = VH.EMPRESA),
                              'NO EXISTE') AS VEHICULO_NOMBRE_EMPRESA_PERT,
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          VH.INMOVILIZADO),
                              ' ') AS VEHICULO_LUGAR_FUE_INMOVIL,
                          NVL(FN_DOMVALOR('cDomAccTipoDisposicion',
                                          VH.DISPOSICION),
                              ' ') AS VEHICULO_FISCALIA_JUZGADO,
                          NVL(VH.NUMERO_SOAT, ' ') AS VEHICULO_SOAT,
                          NVL(VH.ASEGURADORA, ' ') AS VEHICULO_COD_EMP_SOAT,
                          TRUNC(VH.VENCIMIENTO_SOAT) AS VEHICULO_FECHA_VENC_SOAT,
                          FN_DOMVALOR('cDomAccClaseVehiculo', VH.CLASE) AS VEHICULO_NOMBRE_CLASE,
                          NULL AS VEHICULO_NOMBRE_SERVICIO,
                          FN_DOMVALOR('cDomAccModalidadTranporteMasivo',
                                      VH.MODALIDAD) AS VEHICULO_MODALIDAD, --***
                          FN_DOMVALOR('cDomAccTipoServicio', VH.SERVICIO) AS VEHICULO_RADIO_ACCION, --***
                          NVL(VH.NACIONALIDAD, ' ') AS VEHICULO_COD_NACIONALIDAD,
                          DECODE(VH.SEGURO, '100', ' ', VH.SEGURO) AS VEHICULO_SEGURO_RESPONS,
                          NVL(FN_DOMVALOR('cDomAccTipoFalla', VH.FALLAS),
                              ' ') AS VEHICULO_NOMB_TIPO_FALLA,
                          NVL(FN_DOMVALOR('cDomAccTipoInmovilizadores',
                                          VH.INMOVILIZADO),
                              ' ') AS VEHICULO_INMOVILIZADO_EN,
                          NVL(VH.DETALLE_DISPOSICION, ' ') AS VEHICULO_A_DISPOSICION_DE,
                          
                          0    AS VIA_NUMERO_VIA_FORM,
                          NULL AS VIA_NOMBRE_GEOMETRICA_A,
                          NULL AS VIA_NOMBRE_GEOMETRICA_B,
                          NULL AS VIA_NOMBRE_GEOMETRICA_C,
                          NULL AS VIA_NOMBRE_TIPO_UTILIZACION,
                          NULL AS VIA_NOMBRE_TIPO_CALZADA,
                          NULL AS VIA_NOMBRE_TIPO_CARRIL,
                          NULL AS VIA_NOMBRE_ESTADO,
                          NULL AS VIA_NOMBRE_TIPO_CONDICION,
                          NULL AS VIA_NOMBRE_SUPERFICIE_RODADURA,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_A,
                          NULL AS VIA_NOMBRE_TIPO_ILUMINACION_B,
                          NULL AS VIA_EXISTE_AGENTE,
                          NULL AS VIA_NOMBRE_ESTADO_SEMAFORO,
                          NULL AS VIA_VISUAL_NORMAL, --***
                          NULL AS VIA_TIPO_ELEMENTO_DISM_VIS, --***
                          
                          0    AS LESION_CODIGO_TIPO,
                          NULL AS LESION_NOMBRE_TIPO,
                          NULL AS LESION_CONDICION_VICTIMA, /*nombre condicion - clase vehiculo*/
                          
                          NULL AS VICTIMA_EXAMEN,
                          NULL AS VICTIMA_FORMULARIO,
                          NULL AS VICTIMA_GRADO_EXAMEN,
                          NULL AS VICTIMA_RESULTADO_EXAMEN,
                          
                          0    AS SENIAL_CODIGO,
                          NULL AS SENIAL_NOMBRE,
                          0    AS SENIAL_CODIGO_DEMARCACION,
                          NULL AS SENIAL_NOMBRE_DEMARCACION,
                          0    AS SENIAL_CODIGO_REDUCTOR_VEL, --***
                          NULL AS SENIAL_NOMBRE_REDUCTOR_VEL, --***
                          0    AS SENIAL_CODIGO_DELINEADOR, --***
                          NULL AS SENIAL_NOMBRE_DELINEADOR --***
            FROM SIGAT.ACCIDENTE   A,
                 SIGAT.VICTIMAS    C,
                 SIGAT.CONDUCTORES CON,
                 --  SIGAT.VIAS        VI,
                 -- SIGAT.LESIONES    L,
                 SIGAT.VEHICULOS   VH,
                 grados_transito   gt,
                 unidades_transito ut
           WHERE C.CODIGO_ACCIDENTE = A.CODIGO_ACCIDENTE(+)
             AND C.CODIGO_ACCIDENTADO = CON.CODIGO_ACCIDENTADO(+)
                --    AND A.CODIGO_ACCIDENTE = VI.CODIGO_ACCIDENTE(+)
                -- AND C.CODIGO_ACCIDENTADO = L.CODIGO_ACCIDENTADO(+)
             AND VH.CODIGO_ACCIDENTE(+) = A.CODIGO_ACCIDENTE
             AND C.CODIGO_VEHICULO = VH.CODIGO_VEHICULO
             AND c.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
             AND (TRUNC(A.FECHA) BETWEEN NVL(PFECHA_DESDE, TRUNC(A.FECHA)) AND
                 NVL(PFECHA_HASTA, TRUNC(A.FECHA)))
           ORDER BY A.CODIGO_ACCIDENTE;
      END IF;
    
    END IF;
  
    DELETE FROM sigat.lista_formularios;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      vmensaje := substr(vmensaje || ' ' || sqlerrm, 1, 600);
      dbms_output.put_line(vmensaje);
      DELETE FROM sigat.lista_formularios;
      COMMIT;
  END SP_PLANO_INTERNO_ACCIDENTE;

  FUNCTION sf_hospitalizado_valorado(p_codigo_accidentado IN LESIONES.CODIGO_ACCIDENTADO%TYPE,
                                     p_gravedad           IN VICTIMAS.ESTADO%TYPE)
    RETURN VARCHAR2 IS
    ln_count  NUMBER;
    lv_result VARCHAR2(30) := ' ';
  BEGIN
  
    IF (p_gravedad = '1' OR p_gravedad = '2') THEN
      select COUNT(1)
        INTO ln_count
        from tipos_lesiones a
        JOIN lesiones b
          ON a.codigo_lesion = b.codigo_lesion
         AND a.tipo = 'H'
         AND b.codigo_accidentado = p_codigo_accidentado;
    
      IF ln_count > 0 THEN
        lv_result := 'HOSPITALIZADO';
      ELSE
        lv_result := 'VALORADO';
      END IF;
    END IF;
  
    return lv_result;
  END;

END PAQ_ARCHIVOS_PLANOS_INTERNOS;