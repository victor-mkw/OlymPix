--Requêtes Activité 1:

--1/
INSERT INTO t_profil_pfl VALUES(NULL,'Antoine', 'Le Blanc', 'leblc@gmail.com', 'O', 'A', CURDATE(), '925-05-30'); 
SELECT MAX(pfl_id) INTO @id FROM t_profil_pfl;
INSERT INTO t_compte_cpt VALUES(@id, 'lblc', SHA2('m0t2@S$€', 256));


--2/
SELECT MIN(pfl_date) INTO @annee FROM t_profil_pfl;
SELECT @annee;


--Requête Activité 2:


DROP VUE IF EXISTS LISTE_PROFIL;
CREATE VIEW LISTE_PROFIL 
AS SELECT pfl_nom AS Nom, pfl_prénom AS Prenom 
    FROM t_profil_pfl; 

SELECT * FROM LISTE_PROFIL;


--Requête Activité 3:

DROP FUNCTION IF EXISTS donner_age;
DELIMITER //
CREATE FUNCTION donner_age(ID INT) RETURNS INT
BEGIN
DECLARE AGE INT DEFAULT 0;
SET AGE := (SELECT TIMESTAMPDIFF(YEAR,date_n, CURDATE()));
RETURN AGE;
END;
//
DELIMITER ;

SELECT donner_age(1);


--Requêtes Activité 4:


--1/
DROP PROCEDURE IF EXISTS afficher_age;
DELIMITER //
CREATE PROCEDURE afficher_age(IN ID INT, OUT AGE INT)
BEGIN
SELECT pfl_date_naissance INTO @date_naissance FROM t_profil_pfl WHERE pfl_id = ID;
SET AGE := calculer_age2(@date_naissance);
END;
//
DELIMITER ;

CALL afficher_age(1);


--2/
DROP PROCEDURE IF EXISTS pfl_majeur;
DELIMITER //
CREATE PROCEDURE pfl_majeur(IN ID INT, OUT AGE INT, OUT MAJORITE TEXT)
BEGIN
SELECT pfl_date_naissance INTO @date_naissance FROM t_profil_pfl WHERE pfl_id = ID;
SET AGE := calculer_age2(@date_naissance);
IF AGE >= 18 THEN SET MAJORITE := 'Majeur';
ELSE SET MAJORITE := 'Mineur';
END IF;
END;
//
DELIMITER ;


--3/
DROP VIEW IF EXISTS INFO_PROFIL;
CREATE VIEW INFO_PROFIL 
AS 
    SELECT pfl_nom AS Nom, pfl_prenom AS Prénom, calculer_age(pfl_date_naissance) AS Age 
    FROM t_profil_pfl;


--4/
DROP PROCEDURE IF EXISTS pfl_age_moy;
DELIMITER //
CREATE PROCEDURE pfl_age_moy(OUT AGE_MOY INT)
BEGIN
SELECT AVG(Age) INTO AGE_MOY FROM INFO_PROFIL;
END;
//
DELIMITER ;


--Requêtes Activité 5

--1/
DROP TRIGGER IF EXISTS set_curdate;
DELIMITER //
CREATE TRIGGER set_curdate
BEFORE INSERT ON t_profil_pfl
FOR EACH ROW
BEGIN
SET NEW.pfl_date := CURDATE();
END;
//
DELIMITER ;


--2/
DROP TRIGGER IF EXISTS update_date_pfl;
DELIMITER //
CREATE TRIGGER update_date_profil
AFTER UPDATE ON t_compte_cpt
FOR EACH ROW
BEGIN
UPDATE t_profil_pfl SET pfl_date := CURDATE() WHERE t_profil_pfl.pfl_id = NEW.pfl_id;
END;
//
DELIMITER ;


--3/
DROP TRIGGER IF EXISTS salage_hashage;
DELIMITER //
CREATE TRIGGER salage_hashage
BEFORE INSERT ON t_compte_cpt
FOR EACH ROW
BEGIN
SET NEW.cpt_mot_de_passe := SHA2(CONCAT(NEW.cpt_mot_de_passe, 'OoL56T%'), 256);
END;
//
DELIMITER ;


--Pour aller plus loin: Activité 1

--1/
DROP FUNCTION IF EXISTS get_id_last_cnc;
DELIMITER //
CREATE FUNCTION get_id_last_cnc() RETURNS INT
BEGIN
SELECT cnc_id INTO @id FROM t_concours_cnc ORDER BY cnc_date_debut DESC LIMIT 1;
RETURN @id;
END;
//
DELIMITER ;


--2/
DROP PROCEDURE IF EXISTS insert_act_cnc;
DELIMITER //
CREATE PROCEDURE insert_act_cnc()
BEGIN
SET @id = get_id_last_cnc();
SELECT cnc_nom INTO @cnc_nom FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_description INTO @cnc_desc FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_date_debut INTO @date FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cpt_username INTO @cnc_orga FROM t_concours_cnc WHERE cnc_id = @id;
INSERT INTO t_actualite_act VALUES(NULL, 'Nouveau concours !', CONCAT_WS(', ',@cnc_nom,@cnc_desc, @date), CURDATE(), 'A', @cnc_orga);
END;
//
DELIMITER ;


--3/
DROP TRIGGER IF EXISTS trigger_act_cnc;
DELIMITER //
CREATE TRIGGER trigger_act_cnc
AFTER INSERT ON t_concours_cnc
FOR EACH ROW
BEGIN
CALL insert_act_cnc();
END;
//
DELIMITER ;


--Pour aller plus loin: Activité 2

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


--Pour aller plus loin: Activité 3


--1/ Après un update sur la table concours: Vérification de la correspondance des OLD et NEW et création d'une actualité en conséquence
DROP TRIGGER IF EXISTS actu_modif_concours;
DELIMITER //
CREATE TRIGGER actu_modif_concours
AFTER UPDATE ON t_concours_cnc
FOR EACH ROW
BEGIN

IF OLD.cnc_nom != NEW.cnc_nom AND (OLD.cnc_description != NEW.cnc_description OR OLD.cnc_date_debut != NEW.cnc_date_debut OR OLD.cnc_nb_jours_candidature != NEW.cnc_nb_jours_candidature OR OLD.cnc_nb_jours_pre_selection != NEW.cnc_nb_jours_pre_selection OR OLD.cnc_nb_jours_pre_selection != NEW.cnc_nb_jours_pre_selection) THEN
    INSERT INTO t_actualite_act VALUES (NULL, 'Modification du concours !', CONCAT_WS(' => ', 'MODIFICATION DU CONCOURS',NEW.cnc_nom,'Voir la liste des concours !'), CURDATE(), 'A','organisateur@gmail.com');

ELSEIF OLD.cnc_nom != NEW.cnc_nom THEN
    INSERT INTO t_actualite_act VALUES (NULL, 'Changement de nom !', CONCAT_WS(' => ', 'Attention, changement de nom du concours', OLD.cnc_nom, NEW.cnc_nom), CURDATE(), 'A', 'organisateur@gmail.com');

END IF;
END;
//
DELIMITER ;


--2/
DROP TRIGGER IF EXISTS trigg_supp_admin;
DELIMITER //
CREATE TRIGGER trigg_supp_admin
BEFORE DELETE ON t_compte_cpt
FOR EACH ROW
BEGIN
UPDATE t_concours_cnc SET cpt_username = 'organisateur@gmail.com' WHERE t_concours_cnc.cpt_username = OLD.cpt_username;
DELETE FROM t_actualite_act WHERE t_actualite_act.cpt_username = OLD.cpt_username;
DELETE FROM t_administrateur_adm WHERE t_administrateur_adm.cpt_username = OLD.cpt_username;
END;
//
DELIMITER ;


--Pour aller plus loin: Actvité 4

--1/
DROP FUNCTION IF EXISTS get_orga_cnc;
DELIMITER //
CREATE FUNCTION get_orga_cnc(ID INT) RETURNS TEXT
BEGIN
SELECT cpt_username INTO @orga FROM t_concours_cnc WHERE cnc_id = ID;
RETURN @orga;
END;
//
DELIMITER ;


--2/
DROP PROCEDURE IF EXISTS insert_act_cnc2;
DELIMITER //
CREATE PROCEDURE insert_act_cnc2(IN ID INT)
BEGIN

@orga = get_orga_cnc(ID);

SELECT cnc_nom, cnc_description, cnc_date_debut INTO @cnc_nom, @cnc_desc, @date FROM t_concours_cnc WHERE cnc_orga = @orga;

INSERT INTO t_actualite_act VALUES(NULL, 'Nouveau concours !', CONCAT_WS(' --> ',@cnc_nom, @date, @cnc_desc), CURDATE(), 'A', @orga);

END;
//
DELIMITER ;


--3/
DROP TRIGGER IF EXISTS trigger_act_cnc2;
DELIMITER //
CREATE TRIGGER trigger_act_cnc2
AFTER INSERT ON t_concours_cnc
CALL insert_act_cnc2(NEW.cnc_id);
END;
//
DELIMITER ;