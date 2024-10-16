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
SET NEW.cpt_mot_de_passe := SHA2(CONCAT(NEW.cpt_mot_de_passe, 'CeCiEsTMoNSEl'), 256);
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

SELECT cnc_date_debut INTO @date_debut FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_debut, cnc_nb_jours_candidature) INTO @date_candidature FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_candidature, cnc_nb_jours_pre_selection) INTO @date_pre_sel FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_pre_sel, cnc_nb_jours_selection) INTO @date_sel FROM t_concours_cnc WHERE cnc_id = ID;


IF CURDATE() < @date_debut THEN RETURN 'à venir';
ELSEIF CURDATE() < @date_candidature THEN RETURN 'candidature';
ELSEIF CURDATE() < @date_pre_sel THEN RETURN 'pré-selection';
ELSEIF CURDATE() < @date_sel THEN RETURN 'sélection';
ELSE RETURN 'terminé';
END IF;

END;
//
DELIMITER ;
