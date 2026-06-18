{{ config(materialized='table') }}

WITH base AS (
    SELECT
        private_code,
        id_ligne_idfm,
        id_ligne_stif,
        libelle_ligne
    FROM {{ ref('int_lignes_total') }}
),

ref AS (
    SELECT
        id_ligne_idfm,
        privatecode,
        id_groupoflines,
        networkname
    FROM {{ ref('stg_lignes_referentiel') }}
),

arrets_lignes AS (
    SELECT
        id_ligne_idfm,
        type_transport AS type_transport_arrets,
        libelle_transporteur AS libelle_transporteur_arrets
    FROM {{ ref('stg_arrets_lignes') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id_ligne_idfm ORDER BY id_ligne_idfm) = 1
),

indicateurs AS (
    SELECT 
        id_ligne_idfm, 
        type_transport AS type_transport_indicateurs, 
        resultat AS indicateur_perception, 
        transporteur_name AS libelle_transporteur_indicateurs
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm IS NOT NULL
    AND id_ligne_idfm NOT LIKE '%;%'

    UNION ALL

    SELECT 
        'C01373' AS id_ligne_idfm, 
        type_transport AS type_transport_indicateurs, 
        resultat AS indicateur_perception, 
        transporteur_name AS libelle_transporteur_indicateurs
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm = 'C01373;C01386'

    UNION ALL

    SELECT 
        'C01386' AS id_ligne_idfm, 
        type_transport AS type_transport_indicateurs, 
        resultat AS indicateur_perception, 
        transporteur_name AS libelle_transporteur_indicateurs
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm = 'C01373;C01386'

    UNION ALL

    SELECT 
        'C01377' AS id_ligne_idfm, 
        type_transport AS type_transport_indicateurs, 
        resultat AS indicateur_perception, 
        transporteur_name AS libelle_transporteur_indicateurs
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm = 'C01377;C01387'

    UNION ALL

    SELECT 
        'C01387' AS id_ligne_idfm, 
        type_transport AS type_transport_indicateurs, 
        resultat AS indicateur_perception, 
        transporteur_name AS libelle_transporteur_indicateurs
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm = 'C01377;C01387'
),

indicateurs_dsp AS (
    SELECT
        dsp,
        AVG(resultat) AS indicateur_perception_dsp
    FROM {{ ref('stg_indicateurs_de_perception_qs') }}
    WHERE id_ligne_idfm IS NULL
    GROUP BY dsp
),

climatisation AS (
    SELECT
        id_ligne_idfm,
        climatisation
    FROM {{ ref('stg_climatisation') }}
),

clim_manuel AS (
    SELECT id_ligne_idfm, climatisation_manuel
    FROM {{ ref('air_conditionning_manuel') }}
),

transporteurs AS (
    SELECT
        transporteur_ref AS id_operateur,
        libelle_transporteur
    FROM {{ ref('stg_liste_transporteurs') }}
)

SELECT
    -- Nouvel ID technique
    ROW_NUMBER() OVER (ORDER BY COALESCE(base.id_ligne_idfm, base.private_code)) AS id_ligne,

    -- Identifiants
    base.id_ligne_idfm,
    base.id_ligne_stif,
    base.private_code,

    -- Libellé
    base.libelle_ligne,

    -- DSP
    CASE
        WHEN ref.networkname = 'Pays Briard'                   THEN '13'
        WHEN ref.networkname = 'Sénart'                        THEN '19'
        WHEN ref.networkname = 'Argenteuil - Boucles de Seine' THEN '33'
        WHEN ref.networkname = 'Bièvre'                        THEN '37 bus'
        WHEN ref.networkname = 'Lignes Île-de-France Ouest'    THEN '38'
        WHEN ref.networkname = "Haut Val d'Oise"               THEN '3'
        WHEN ref.networkname = "Terres d'Envol"                THEN '7'
        WHEN ref.networkname = 'Seine Grand Orly'              THEN '22 Bus'
        WHEN ref.networkname = 'Saint-Quentin-en-Yvelines'     THEN '29'
        WHEN ref.networkname = 'Centre et Sud Yvelines'        THEN '30'
        WHEN ref.networkname = 'Vexin'                         THEN '2'
        WHEN ref.networkname = 'Marne-la-Vallée'               THEN '10'
        WHEN ref.networkname = 'Evry Centre Essonne'           THEN '23'
        ELSE NULL
    END AS dsp,

    -- Type transport normalisé
    CASE
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) = 'Tramway'
             AND base.libelle_ligne IN ('T4', 'T11', 'T12', 'T14') THEN 'Tram-train'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('Tramway', 'Tram-train') THEN 'Tramway'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('Metro', 'Métro') THEN 'Metro'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('RapidTransit', 'RER') THEN 'RapidTransit'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('LocalTrain', 'Train') THEN 'LocalTrain'
        ELSE COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs)
    END AS type_transport,

    -- Surface or fer
    CASE
        -- 1. TYPE_TRANSPORT disponible (lignes IDFM)
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) = 'Tramway'
            AND base.libelle_ligne IN ('T4', 'T11', 'T12', 'T14') THEN 'fer'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('Tramway', 'Tram-train') THEN 'surface'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN (
            'RapidTransit', 'RER', 'regionalRail', 'LocalTrain', 'Train', 'RailShuttle', 'Metro', 'Métro'
        ) THEN 'fer'
        WHEN COALESCE(al.type_transport_arrets, ind.type_transport_indicateurs) IN ('Bus', 'Funicular') THEN 'surface'

        -- 2. FALLBACK PRIVATE_CODE (lignes STIF_ONLY)
        WHEN SUBSTR(base.private_code, 1, 6) = '100110' THEN 'fer'
        WHEN SUBSTR(base.private_code, 1, 3) IN ('800', '810') THEN 'fer'
        WHEN SUBSTR(base.private_code, 1, 3) IN (
            '100', '500', '501', '502', '503', '504', '505',
            '506', '507', '508', '510', '511', '512', '513',
            '514', '515', '516', '517', '518', '519', '520',
            '521', '522', '523', '524', '525', '526', '527',
            '528', '529', '530', '531', '532', '533', '534',
            '535', '538', '539'
        ) THEN 'surface'

        -- 3. FALLBACK LIBELLE_LIGNE
        WHEN UPPER(base.libelle_ligne) LIKE '%NOCTILIEN%' THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%RER%'       THEN 'fer'
        WHEN UPPER(base.libelle_ligne) LIKE '%METRO%'     THEN 'fer'
        WHEN UPPER(base.libelle_ligne) LIKE '%TRANSILIEN%' THEN 'fer'
        WHEN UPPER(base.libelle_ligne) LIKE '%TRAMWAY%'   THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%BUS%'       THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%CAR%'       THEN 'surface'

        -- Compléments libelle_ligne
        WHEN UPPER(base.libelle_ligne) LIKE '%TAD%'              THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%T%D%'              THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%REMPLACEMENT%'     THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%SOIR%'             THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%NAVETTE%'          THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%FILEO%'            THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%TITUS%'            THEN 'surface'
        WHEN UPPER(base.libelle_ligne) LIKE '%EXPRESS%'          THEN 'surface'
        WHEN base.libelle_ligne = 'LIGNE NON DEFINIE'            THEN 'non classifié'

        -- Préfixes supplémentaires
        WHEN SUBSTR(base.private_code, 1, 3) IN (
            '000', '003', '004', '005', '010', '011', '013',
            '014', '015', '018', '020', '024', '027', '030',
            '036', '039', '040', '044', '045', '046', '055',
            '056', '059', '062', '063', '064', '078', '084',
            '097', '101', '111', '116', '148', '191', '208',
            '210', '213', '227', '228', '230', '233', '291',
            '293', '314', '334', '400', '760', '762', '999'
        ) THEN 'surface'

        WHEN base.id_ligne_idfm LIKE 'C02%' AND base.libelle_ligne LIKE 'L%' THEN 'surface'
        WHEN base.id_ligne_idfm = 'C02833' THEN 'surface'  -- ligne 18
        WHEN base.id_ligne_idfm = 'C02855' THEN 'surface'  -- 1247
        WHEN base.id_ligne_idfm = 'C00354' THEN 'surface'  -- 4115
        WHEN base.libelle_ligne = 'LIGNE NON DEFINIE'       THEN 'non classifié'

        ELSE 'non classifié'
    END AS surface_or_fer,

    -- Climatisation
    COALESCE(clim.climatisation, clim_manuel.climatisation_manuel, 'unknown') AS climatisation,

    -- Indicateur de perception
    COALESCE(
        ind.indicateur_perception,
        ind_dsp.indicateur_perception_dsp
    ) AS indicateur_perception,

    ind.indicateur_perception         AS indicateur_perception_individuel,
    ind_dsp.indicateur_perception_dsp AS indicateur_perception_dsp,

    -- Transporteur
    al.libelle_transporteur_arrets,
    ind.libelle_transporteur_indicateurs,
    COALESCE(al.libelle_transporteur_arrets, ind.libelle_transporteur_indicateurs) AS libelle_transporteur,

    -- Opérateur
    tr.id_operateur

FROM base
LEFT JOIN ref              ON base.id_ligne_idfm = ref.id_ligne_idfm
LEFT JOIN arrets_lignes al ON base.id_ligne_idfm = al.id_ligne_idfm
LEFT JOIN indicateurs ind  ON base.id_ligne_idfm = ind.id_ligne_idfm
LEFT JOIN indicateurs_dsp ind_dsp
    ON CASE
        WHEN ref.networkname = 'Pays Briard'                   THEN '13'
        WHEN ref.networkname = 'Sénart'                        THEN '19'
        WHEN ref.networkname = 'Argenteuil - Boucles de Seine' THEN '33'
        WHEN ref.networkname = 'Bièvre'                        THEN '37 bus'
        WHEN ref.networkname = 'Lignes Île-de-France Ouest'    THEN '38'
        WHEN ref.networkname = "Haut Val d'Oise"               THEN '3'
        WHEN ref.networkname = "Terres d'Envol"                THEN '7'
        WHEN ref.networkname = 'Seine Grand Orly'              THEN '22 Bus'
        WHEN ref.networkname = 'Saint-Quentin-en-Yvelines'     THEN '29'
        WHEN ref.networkname = 'Centre et Sud Yvelines'        THEN '30'
        WHEN ref.networkname = 'Vexin'                         THEN '2'
        WHEN ref.networkname = 'Marne-la-Vallée'               THEN '10'
        WHEN ref.networkname = 'Evry Centre Essonne'           THEN '23'
        ELSE NULL
    END = ind_dsp.dsp
LEFT JOIN climatisation clim ON base.id_ligne_idfm = clim.id_ligne_idfm
LEFT JOIN clim_manuel ON base.id_ligne_idfm = clim_manuel.id_ligne_idfm
LEFT JOIN transporteurs tr   ON al.libelle_transporteur_arrets = tr.libelle_transporteur