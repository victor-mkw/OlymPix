-- Faire travailler les fonctions, procédures et trigger ensemble

--1.
--Fonction de génération d'un code à 8 caractères
DROP FUNCTION IF EXISTS create_code_candidat;
DELIMITER //
CREATE FUNCTION create_code_candidat() RETURNS CHAR(8)
BEGIN
DECLARE CODE_8 CHAR 8 DEFAULT '';
CODE_8 := SELECT LEFT(MD5(RAND()), 8);
RETURN CODE_8;
END;
//
DELIMITER ;


--Fonction de génération d'un code à 20 caractères
DROP FUNCTION IF EXISTS create_code_dossier;
DELIMITER //
CREATE FUNCTION create_code_dossier() RETURNS CHAR(20)
BEGIN
DECLARE CODE_20 CHAR 20 DEFAULT '';
CODE_20 := SELECT LEFT(MD5(RAND()), 20);
RETURN CODE_20;
END;
//
DELIMITER ;


--Trigger sur INSERT de la table candidature pour la génération des codes
DROP TRIGGER IF EXISTS trigg_codes;
DELIMITER //
CREATE TRIGGER trigg_codes
BEFORE INSERT ON t_candidature_cdt
FOR EACH ROW
BEGIN
SET NEW.cdt_code_candidat := create_code_candidat;
SET NEW.cdt_code_dossier := create_code_dossier;
END;
//
DELIMITER ;


--2.
--Procédure INSERT de fil de conversation du dernier concours
DROP PROCEDURE IF EXISTS create_fil_cnc;
DELIMITER //
CREATE PROCEDURE create_fil_cnc()
BEGIN
SET @id = get_id_last_cnc();
SELECT cnc_nom INTO @cnc_nom FROM t_concours_cnc WHERE cnc_id = @id;

INSERT INTO t_fil_fil VALUES(NULL, CONCAT('Deliberation ', @cnc_nom), @id);
END;
//
DELIMITER ;


--Trigger d'appel de la procédure de création d'un fil à l'INSERT d'un concours
DROP TRIGGER IF EXISTS trigger_fil_cnc;
DELIMITER //
CREATE TRIGGER trigger_act_cnc
AFTER INSERT ON t_concours_cnc
FOR EACH ROW
BEGIN
CALL create_fil_cnc();
END;
//
DELIMITER ;