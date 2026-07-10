WITH REGRAS_EVENTOS
     AS (SELECT CODEVENTO,
                'DIVISOR_30' AS GRUPO_REGRA
         FROM   (VALUES ('0001'),
                        ('0027'),
                        ('0028'),
                        ('0093'),
                        ('0094'),
                        ('0445'),
                        ('0167'),
                        ('0168'),
                        ('0169'),
                        ('0537'),
                        ('0538'),
                        ('0863'),
                        ('0555'),
                        ('0862'),
                        ('0856'),
                        ('0055'),
                        ('1116') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_DIURNA_50'
         FROM   (VALUES ('0021'),
                        ('0019'),
                        ('0623'),
                        ('0859') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_NOTURNA_50'
         FROM   (VALUES ('0221') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_DIURNA_70'
         FROM   (VALUES ('0022'),
                        ('0025'),
                        ('0860') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_NOTURNA_70'
         FROM   (VALUES ('0222') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_DIURNA_100'
         FROM   (VALUES ('0023'),
                        ('0024' ),
                        ('0624'),
                        ('0861')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_NOTURNA_100'
         FROM   (VALUES ('0223') ) V(CODEVENTO)
         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_DIURNA_BRASILIA_100'
         FROM   (VALUES ('1023')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'HORA_EXTRA_NOTURNA_BRASILIA_100'
         FROM   (VALUES ('1223')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'ADICIONAL_NOTURNO'
         FROM   (VALUES ('0017'),
                        ('0032')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'PERICULOSIDADE'
         FROM   (VALUES ('0101')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'ATRASO_HORAS'
         FROM   (VALUES ('0536'),
                        ('0059'),
                        ('0858'),
                        ('1117'),
                        ('1421'),
                        ('1415'),
                        ('1417')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORAS'
         FROM   (VALUES ('0029'),
                        ('0039'),
                        ('0630')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_DIURNA_50'
         FROM   (VALUES ('1325')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_NOTURNA_50'
         FROM   (VALUES ('1322')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_DIURNA_70'
         FROM   (VALUES ('1326')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_NOTURNA_70'
         FROM   (VALUES ('1323')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_DIURNA_100'
         FROM   (VALUES ('1327')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'SOBREAVISO_HORA_EXTRA_NOTURNA_100'
         FROM   (VALUES ('1324')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'VALE_TRANSPORTE'
         FROM   (VALUES ('0523')) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'ANUENIO_PERCENTUAL'
         FROM   (VALUES ('0006') ) V(CODEVENTO)

         UNION ALL
         SELECT CODEVENTO,
                'ANUENIO_FIXO'
         FROM   (VALUES ('0003') ) V(CODEVENTO)),
     MOVIMENTOS
     AS (SELECT PFFINANC.CODCOLIGADA,
                PSINDIC.CODIGO       AS COD_SINDICATO,
                PSINDIC.NOME         AS NOME_SINDICATO,
                PFUNC.CODFILIAL,
                GFILIAL.NOMEFANTASIA AS FILIAL,
                PFUNC.CODSECAO,
                PFFINANC.CHAPA,
                PFUNC.NOME,
                PPESSOA.CPF,
                PFFINANC.ANOCOMP,
                PFFINANC.MESCOMP,
                PFFINANC.NROPERIODO,
                PFFINANC.DTPAGTO,
                PFUNC.DATAADMISSAO,
                PFUNC.DATADEMISSAO,
                PFUNC.CODSITUACAO,
                PFFINANC.CODEVENTO,
                PEVENTO.DESCRICAO,
                PEVENTO.PROVDESCBASE,
                PFFINANC.REF,
                PFFINANC.VALOR,
                R.GRUPO_REGRA
         FROM   PFFINANC WITH (NOLOCK)
                INNER JOIN PFUNC WITH (NOLOCK)
                        ON PFFINANC.CODCOLIGADA = PFUNC.CODCOLIGADA
                           AND PFFINANC.CHAPA = PFUNC.CHAPA
                INNER JOIN GFILIAL WITH (NOLOCK)
                        ON GFILIAL.CODCOLIGADA = PFUNC.CODCOLIGADA
                           AND GFILIAL.CODFILIAL = PFUNC.CODFILIAL
                INNER JOIN PPESSOA WITH (NOLOCK)
                        ON PFUNC.CODPESSOA = PPESSOA.CODIGO
                INNER JOIN PEVENTO WITH (NOLOCK)
                        ON PFFINANC.CODCOLIGADA = PEVENTO.CODCOLIGADA
                           AND PFFINANC.CODEVENTO = PEVENTO.CODIGO
                INNER JOIN REGRAS_EVENTOS R
                        ON PFFINANC.CODEVENTO = R.CODEVENTO
                LEFT JOIN PSINDIC WITH (NOLOCK) -- Join adicionado
                       ON PFUNC.CODSINDICATO = PSINDIC.CODIGO
         WHERE  PFFINANC.ANOCOMP = :ANOCOMP
                AND PFFINANC.MESCOMP = :MESCOMP
                AND PFUNC.DATADEMISSAO IS NULL),
     BASE_PERICULOSIDADE
     AS (SELECT F.CODCOLIGADA,
                F.CHAPA,
                F.ANOCOMP,
                F.MESCOMP,
                F.NROPERIODO,
                Sum(Abs(ISNULL(F.VALOR, 0))) AS VALOR_BASE_PERICULOSIDADE
         FROM   PFFINANC F WITH (NOLOCK)
         WHERE  F.CODEVENTO IN ( '0055', '0031', '0041', '0215' )
         GROUP  BY F.CODCOLIGADA,
                   F.CHAPA,
                   F.ANOCOMP,
                   F.MESCOMP,
                   F.NROPERIODO),
     BASE_CALCULO
     AS (SELECT M.*,
                S.SAL_SALARIO,
                S.SAL_JORNADA,
                S.DTMUDANCA                                                                           AS DT_VIGENCIA_SALARIAL,
                Cast(Round(ISNULL(S.SAL_SALARIO, 0) / 30.0, 2) AS DECIMAL(18, 2))                     AS VALOR_DIA,
                Cast(Round(ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0), 2) AS DECIMAL(18, 2)) AS VALOR_HORA,
                CASE
                  WHEN M.GRUPO_REGRA = 'DIVISOR_30' THEN '((SALARIO_BASE / 30) * REF)'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_50' THEN '((SALARIO_BASE / JORNADA) * 1.5) * REF'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_50' THEN '((SALARIO_BASE / JORNADA) * 1.5) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_70' THEN '((SALARIO_BASE / JORNADA) * 1.7) * REF'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_70' THEN '((SALARIO_BASE / JORNADA) * 1.7) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * REF'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_BRASILIA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * REF'
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_BRASILIA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'ADICIONAL_NOTURNO' THEN '((SALARIO_BASE / JORNADA) * 0,2 ) * REF'
                  WHEN M.GRUPO_REGRA = 'PERICULOSIDADE' THEN '((((SALARIO_BASE / 30) * REF) + BASE_EVENTOS_PERICULOSIDADE) * 0,30)'
                  WHEN M.GRUPO_REGRA = 'ATRASO_HORAS' THEN '(SALARIO_BASE / JORNADA) * REF'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORAS' THEN '((SALARIO_BASE / JORNADA) * 1/3) * REF'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_50' THEN '((SALARIO_BASE / JORNADA) * 1.5) * REF'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_50' THEN '((SALARIO_BASE / JORNADA) * 1.5) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_70' THEN '((SALARIO_BASE / JORNADA) * 1.7) * REF'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_70' THEN '((SALARIO_BASE / JORNADA) * 1.7) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * REF'
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_100' THEN '((SALARIO_BASE / JORNADA) * 2) * ((REF * 60) / 52,50)'
                  WHEN M.GRUPO_REGRA = 'VALE_TRANSPORTE' THEN 'SALARIO_BASE * PERCENTUAL CCT'
                  WHEN M.GRUPO_REGRA = 'ANUENIO_PERCENTUAL' THEN 'SALARIO_BASE * (PERCENTUAL CCT * REF)'
                  WHEN M.GRUPO_REGRA = 'ANUENIO_FIXO' THEN 'VALOR CCT * REF'
                  ELSE 'SEM FORMULA'
                END                                                                                   AS MEMORIA_CALCULO,
                CASE
                  WHEN M.GRUPO_REGRA = 'DIVISOR_30' THEN Round(( ISNULL(S.SAL_SALARIO, 0) / 30.00 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_50' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.50 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_50' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.50 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_70' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.70 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_70' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.70 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_100' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_100' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_DIURNA_BRASILIA_100' THEN Round(( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'HORA_EXTRA_NOTURNA_BRASILIA_100' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'ADICIONAL_NOTURNO' THEN Round(( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 0.20 * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'PERICULOSIDADE' THEN Round(( ( ( ISNULL(S.SAL_SALARIO, 0) / 30.00 ) * ISNULL(M.REF, 0) ) + ISNULL(BP.VALOR_BASE_PERICULOSIDADE, 0) ) * 0.30, 2)
                  WHEN M.GRUPO_REGRA = 'ATRASO_HORAS' THEN Round(( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORAS' THEN ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * ( 1.0 / 3.0 ) * ISNULL(M.REF, 0)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_50' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.50 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_50' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.50 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_70' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.70 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_70' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 1.70 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_DIURNA_100' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'SOBREAVISO_HORA_EXTRA_NOTURNA_100' THEN Round(( ( ISNULL(S.SAL_SALARIO, 0) / NULLIF(S.SAL_JORNADA, 0) ) * 2.00 ) * ( Round(ISNULL(M.REF, 0) * 60.00, 0) / 52.50 ), 2)
                  WHEN M.GRUPO_REGRA = 'VALE_TRANSPORTE' THEN Round(CASE
                                                                      WHEN M.CODFILIAL = '3' THEN S.SAL_SALARIO * 0.00
                                                                      WHEN M.CODFILIAL IN ( '4', '16' ) THEN S.SAL_SALARIO * 0.01
                                                                      ELSE S.SAL_SALARIO * 0.06
                                                                    END, 2)
                  WHEN M.GRUPO_REGRA = 'ANUENIO_PERCENTUAL' THEN Round(( ISNULL(S.SAL_SALARIO, 0) * 0.01 ) * ISNULL(M.REF, 0), 2)
                  WHEN M.GRUPO_REGRA = 'ANUENIO_FIXO' THEN Round(CASE
                                                                   WHEN M.CODFILIAL = '33' THEN 42.73 * ISNULL(M.REF, 0)
                                                                   WHEN M.CODFILIAL = '37' THEN 42.73 * ISNULL(M.REF, 0)
                                                                   /*WHEN M.CODCOLIGADA = '2' AND M.CODFILIAL IN ( '1', '2','22','27' ) THEN S.SAL_SALARIO * 0.01*/
                                                                   WHEN M.CODCOLIGADA = '3'
                                                                        AND M.CODFILIAL = '1' THEN 38.79 * ISNULL(M.REF, 0)
                                                                   ELSE 0.00
                                                                 END, 2)
                  ELSE NULL
                END                                                                                   AS VALOR_RECALCULADO_BRUTO
         FROM   MOVIMENTOS M
                LEFT JOIN BASE_PERICULOSIDADE BP
                       ON BP.CODCOLIGADA = M.CODCOLIGADA
                          AND BP.CHAPA = M.CHAPA
                          AND BP.ANOCOMP = M.ANOCOMP
                          AND BP.MESCOMP = M.MESCOMP
                          AND BP.NROPERIODO = M.NROPERIODO
                OUTER APPLY (SELECT TOP 1 PFHSTSAL.SALARIO AS SAL_SALARIO,
                                          CASE
                                            WHEN PFHSTSAL.JORNADA > 1000 THEN PFHSTSAL.JORNADA / 60.0
                                            ELSE PFHSTSAL.JORNADA
                                          END              AS SAL_JORNADA,
                                          PFHSTSAL.DTMUDANCA
                             FROM   PFHSTSAL WITH (NOLOCK)
                             WHERE  PFHSTSAL.CODCOLIGADA = M.CODCOLIGADA
                                    AND PFHSTSAL.CHAPA = M.CHAPA
                                    AND PFHSTSAL.DTMUDANCA <= EOMONTH(DATEFROMPARTS(M.ANOCOMP, M.MESCOMP, 1))
                             ORDER  BY PFHSTSAL.DTMUDANCA DESC) S)
SELECT COD_SINDICATO,
       NOME_SINDICATO,
       CODCOLIGADA,
       CODFILIAL,
       FILIAL,
       CHAPA,
       NOME,
       CPF,
       ANOCOMP,
       MESCOMP,
       NROPERIODO,
       DTPAGTO,
       DATAADMISSAO,
       DATADEMISSAO,
       CODSITUACAO,
       CODEVENTO,
       DESCRICAO,
       PROVDESCBASE,
       GRUPO_REGRA,
       Cast(SAL_SALARIO AS DECIMAL(18, 2))             AS SALARIO_BASE,
       Cast(SAL_JORNADA AS DECIMAL(18, 0))             AS JORNADA,
       DT_VIGENCIA_SALARIAL,
       Cast(VALOR_DIA AS DECIMAL(18, 2))               AS VALOR_DIA,
       Cast(VALOR_HORA AS DECIMAL(18, 2))              AS VALOR_HORA,
       Cast(ISNULL(REF, 0) AS DECIMAL(18, 2))          AS REF,
       MEMORIA_CALCULO,
       Cast(VALOR_RECALCULADO_BRUTO AS DECIMAL(18, 2)) AS VALOR_RECALCULADO,
       Cast(Abs(ISNULL(VALOR, 0)) AS DECIMAL(18, 2))   AS VALOR_PAGO,
       Cast(CASE
              WHEN VALOR_RECALCULADO_BRUTO IS NULL THEN NULL
              ELSE Round(Abs(ISNULL(VALOR, 0)) - VALOR_RECALCULADO_BRUTO, 2)
            END AS DECIMAL(18, 2))                     AS DIFERENCA,
       CASE
         WHEN SAL_SALARIO IS NULL THEN 'SEM SALARIO VIGENTE'
         WHEN GRUPO_REGRA IN ( 'HORA_EXTRA_DIURNA_50', 'HORA_EXTRA_NOTURNA_50', 'HORA_EXTRA_DIURNA_70', 'HORA_EXTRA_NOTURNA_70',
                               'HORA_EXTRA_DIURNA_100', 'HORA_EXTRA_NOTURNA_100', 'HORA_EXTRA_DIURNA_BRASILIA_100', 'HORA_EXTRA_NOTURNA_BRASILIA_100',
                               'ADICIONAL_NOTURNO', 'SOBREAVISO_HORAS', 'SOBREAVISO_HORAS', 'SOBREAVISO_HORA_EXTRA_DIURNA_50',
                               'SOBREAVISO_HORA_EXTRA_NOTURNA_50', 'SOBREAVISO_HORA_EXTRA_DIURNA_70', 'SOBREAVISO_HORA_EXTRA_NOTURNA_70', 'SOBREAVISO_HORA_EXTRA_DIURNA_100', 'SOBREAVISO_HORA_EXTRA_NOTURNA_100' )
              AND ISNULL(SAL_JORNADA, 0) = 0 THEN 'SEM JORNADA'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL = '3'
              AND Abs(ISNULL(VALOR, 0)) <= Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'OK - DENTRO DO LIMITE 0%'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL IN ( '4', '16' )
              AND Abs(ISNULL(VALOR, 0)) <= Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'OK - DENTRO DO LIMITE 1%'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL NOT IN ( '3', '4', '16' )
              AND Abs(ISNULL(VALOR, 0)) <= Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'OK - DENTRO DO LIMITE 6%'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL = '3'
              AND Abs(ISNULL(VALOR, 0)) > Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'DIVERGENTE - ACIMA DO LIMITE 0%'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL IN ( '4', '16' )
              AND Abs(ISNULL(VALOR, 0)) > Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'DIVERGENTE - ACIMA DO LIMITE 1%'
         WHEN GRUPO_REGRA = 'VALE_TRANSPORTE'
              AND CODFILIAL NOT IN ( '3', '4', '16' )
              AND Abs(ISNULL(VALOR, 0)) > Round(VALOR_RECALCULADO_BRUTO, 2) THEN 'DIVERGENTE - ACIMA DO LIMITE 6%'
         WHEN GRUPO_REGRA = 'SEM_REGRA' THEN 'SEM REGRA DE AUDITORIA'
         WHEN Abs(Round(Abs(ISNULL(VALOR, 0)) - VALOR_RECALCULADO_BRUTO, 2)) = 0.00 THEN 'OK'
         WHEN Abs(Round(Abs(ISNULL(VALOR, 0)) - VALOR_RECALCULADO_BRUTO, 2)) BETWEEN 0.01 AND 0.99 THEN 'OK - ARREDONDAMENTO'
         ELSE 'DIVERGENTE'
       END                                             AS STATUS_AUDITORIA,
       Cast(CASE
              WHEN VALOR_RECALCULADO_BRUTO IS NULL
                    OR VALOR_RECALCULADO_BRUTO = 0 THEN NULL
              ELSE Round(( ( Abs(ISNULL(VALOR, 0)) - VALOR_RECALCULADO_BRUTO ) / Abs(VALOR_RECALCULADO_BRUTO) ) * 100, 2)
            END AS DECIMAL(18, 2))                     AS PERCENTUAL_DIFERENCA
FROM   BASE_CALCULO
ORDER  BY CODCOLIGADA,
          CODFILIAL,
          CHAPA,
          CODEVENTO;
