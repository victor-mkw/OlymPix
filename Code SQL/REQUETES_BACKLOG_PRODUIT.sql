--Requête qui récupère toutes les données des (5 dernières) actualités de la table des actualités, de l'actualité la plus récente à l'actualité la plus ancienne.
SELECT * FROM t_actualite_act ORDER BY act_id DESC LIMIT 5;


--Une requête de récupération de la date afin de vérifier dans quelle période du concours nous nous trouvons.
DROP FUNCTION IF EXISTS donner_phase_concours;
DELIMITER //
CREATE FUNCTION donner_phase_concours(ID INT) RETURNS TEXT
BEGIN

SELECT cnc_date_debut, cnc_nb_jours_candidature, cnc_nb_jours_pre_selection, cnc_nb_jours_selection INTO @date_debut, @nbj_candidature, @nbj_pre_sel, @nbj_sel
    FROM t_concours_cnc WHERE cnc_id = ID;

SET @date_candidature := ADDDATE(@date_debut, @nbj_candidature);
SET @date_pre_sel := ADDDATE(@date_candidature, @nbj_pre_sel);
SET @date_sel := ADDDATE(@date_pre_sel, @nbj_sel);

IF CURDATE() < @date_debut THEN RETURN 'à venir';
ELSEIF CURDATE() < @date_candidature THEN RETURN 'candidature';
ELSEIF CURDATE() < @date_pre_sel THEN RETURN 'pré-selection';
ELSEIF CURDATE() < @date_sel THEN RETURN 'sélection';
ELSE RETURN 'terminé';
END IF;

END;
//
DELIMITER ;


--Requête de récupération des candidatures par catégories, triées du plus grand nombre de points au plus petit.
SELECT cdt_nom_candidat, cdt_prenom_candidat, SUM(nte_note) as note_totale, cnc_id, cat_id FROM t_candidature_cdt 
    JOIN t_notation_nte ON t_candidature_cdt.cdt_id = t_notation_nte.cdt_id 
    WHERE cnc_id = 1 and cat_id = 1
    GROUP BY t_candidature_cdt.cdt_id
    ORDER BY DESC;


--Même requête mais avec la vue en plus (cf requêtes individuelles)
SELECT * FROM v_candidats_points
    ORDER BY cdt_note DESC;