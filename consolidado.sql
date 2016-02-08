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
             --AND C.CODIGO_VEHICULO = VH.CODIGO_VEHICULO
             AND c.grado_oficial = gt.codigo_grado(+)
             AND c.unidad = ut.codigo_unidad(+)
             AND (TRUNC(A.FECHA) BETWEEN NVL('01/09/2014', TRUNC(A.FECHA)) AND
                 NVL('15/09/2014', TRUNC(A.FECHA)))
           ORDER BY A.FORMULARIO;