--En tant que visiteur sprint 1 ⇒ 
--Actualités :
--1. Requête listant toutes les actualités de la table des actualités et leur auteur (login)
SELECT * FROM t_actualite_act;

--2. Requête donnant les données d'une actualité dont on connaît l'identifiant (n°)
SELECT * from t_actualite_act WHERE act_id = 1;

--3. Requête listant les 5 dernières actualités dans l'ordre décroissant
SELECT * FROM t_actualite_act ORDER BY act_date_publication DESC LIMIT 5;

--4. Requête recherchant et donnant la (ou les) actualité(s) contenant un mot particulier
SELECT * FROM t_actualite_act WHERE act_titre LIKE '%nom%' OR act_texte LIKE '%nom%';

--5. Requête listant toutes les actualités postées à une date particulière + le login de l’auteur
SELECT * FROM t_actualite_act WHERE act_date_publication = '2024-10-17';

--sprint 3 ⇒ 
--6. Requête d'ajout d'une actualité
--7. Requête listant toutes les actualités postées par un auteur particulier (connaissant le login de l’administrateur connecté)
--8. Requête qui compte les actualités ajoutées avant une date précise
--9. Requête de modification d'une actualité
--10. Requête de suppression d'une actualité à partir de son ID (n°)


--En tant que visiteur sprint 1⇒
--Concours :
--1. Requête listant tous les concours de la plateforme (passés, en cours, à venir)
SELECT * FROM t_concours_cnc;

--2. Requête (+code SQL) listant tous les concours de la plateforme (passés, en cours, à venir) avec leurs principales caractéristiques (organisateur responsable,
--date de début, dates intermédiaires, catégories, nom, prénom et discipline des juges)
DELIMITER //
CREATE FUNCTION get_jry_cnc(ID INT) RETURNS TEXT
BEGIN
SELECT GROUP_CONCAT(CONCAT_WS(', ',jry_nom,jry_prenom,t_jury_jry.cpt_username) ORDER BY t_jury_jry.cpt_username ASC SEPARATOR ' / ') INTO @res FROM t_jury_jry
JOIN t_juge_jge ON t_jury_jry.cpt_username = t_juge_jge.cpt_username
WHERE cnc_id = ID;
RETURN @res;
END;
//
DELIMITER ;


DELIMITER //
CREATE FUNCTION get_cat_cnc(ID INT) RETURNS TEXT
BEGIN
SELECT GROUP_CONCAT(cat_nom ORDER BY cat_nom ASC SEPARATOR ', ') INTO @res FROM t_categorie_cat;
JOIN t_comprend_cmp ON t_categorie_cat.cat_id = t_comprend_cmp.cat_id;
WHERE cnc_id = ID;
RETURN @res;
END;
//
DELIMITER ;


DELIMITER //
CREATE FUNCTION get_date_intermediaire(ID INT) RETURNS TEXT
BEGIN
SELECT cnc_date_debut, cnc_nb_jours_candidature, cnc_nb_jours_pre_selection, cnc_nb_jours_selection INTO @date_debut, @nbj_candidature, @nbj_pre_sel, @nbj_sel
    FROM t_concours_cnc WHERE cnc_id = ID;

SET @date_candidature := ADDDATE(@date_debut, @nbj_candidature);
SET @date_pre_sel := ADDDATE(@date_candidature, @nbj_pre_sel);
SET @date_sel := ADDDATE(@date_pre_sel, @nbj_sel);

SELECT CONCAT_WS(' => ', @date_debut, @date_candidature, @date_pre_sel, @date_sel) INTO @res;
RETURN @res;
END;
//
DELIMITER ;


SELECT cnc_nom, cnc_description, cpt_username, get_date_intermediaire(cnc_id), get_cat_cnc(cnc_id), get_jry_cnc(cnc_id) FROM t_concours_cnc;


--3. Requête listant les concours qui ont débuté et leur phase actuelle (ex : finale)
SELECT cnc_nom, cnc_description, donner_phase_concours(cnc_id) FROM t_concours_cnc WHERE cnc_date_debut <= CURDATE();

--4. Requête listant les concours à venir avec leur date de début
SELECT cnc_nom, cnc_description, cnc_date_debut FROM t_concours_cnc WHERE cnc_date_debut > CURDATE();

--5. Requête donnant toutes les caractéristiques d’un concours particulier (ID connu)
SELECT * FROM t_concours_cnc WHERE cnc_id = 1;

--6. Requête donnant les informations des membres du jury d’un concours particulier (ID connu)
SELECT jry_nom, jry_prenom, jry_discipline, jry_biographie, jry_url, t_concours_cnc.cnc_id FROM t_jury_jry 
JOIN t_juge_jge ON t_jury_jry.cpt_username = t_juge_jge.cpt_username
JOIN t_concours_cnc ON t_juge_jge.cnc_id = t_concours_cnc.cnc_id
WHERE t_concours_cnc.cnc_id = 1;

--7. Requête listant tous les membres de jury, classés par discipline, pour tous les concours de la plateforme
SELECT * FROM t_jury_jry ORDER BY jry_discipline;

--8. Requête donnant la liste des catégories d’un concours particulier (ID connu)
SELECT cat_nom FROM t_categorie_cat 
JOIN t_comprend_cmp ON t_categorie_cat.cat_id = t_comprend_cmp.cat_id
WHERE cnc_id = 1;

--9. Requête listant tous les administrateurs de la plateforme et les concours dont il est (/a été) responsable, s’il y en a
SELECT * FROM t_administrateur_adm
LEFT JOIN t_concours_cnc USING (cpt_username);


--sprint 2⇒
--10. Requête(s) listant tous les candidats pré-sélectionnés pour un concours particulier (ID connu) avec leurs principales données (nom, prénom, catégorie,
--date d’inscription, nombre de documents ressources téléversés)
DELIMITER //
CREATE FUNCTION get_nb_docs(ID INT) RETURNS INT
BEGIN
SELECT COUNT(doc_nom) INTO @res FROM t_document_doc WHERE cdt_id = ID;
RETURN @res;
END;
//
DELIMITER ;

SELECT cdt_nom_candidat, cdt_prenom_candidat, cat_nom, cdt_date_inscription, get_nb_docs(cdt_id) FROM t_candidature_cdt
JOIN t_categorie_cat USING (cat_id)
WHERE cdt_etat = 'P' AND cnc_id = 1;

--11. Requête(s) listant tous les candidats pré-sélectionnés classés par catégorie pour un concours particulier (ID connu)
SELECT cdt_nom_candidat, cdt_prenom_candidat, cat_nom FROM t_candidature_cdt
JOIN t_categorie_cat USING (cat_id)
WHERE cnc_id = 1 AND cdt_etat = 'P'
ORDER BY cat_nom ASC;

--12. Requête donnant tous les noms des documents ressources d’un candidat (ID connu) pour un concours particulier (ID connu)
SELECT cdt_nom_candidat, cdt_prenom_candidat, doc_nom FROM t_document_doc 
JOIN t_candidature_cdt USING (cdt_id)
WHERE cdt_id = 2 AND cnc_id = 1;

--13. Requête donnant le palmarès d’un concours particulier (ID connu) pour lequel la phase finale est terminée
SELECT cdt_nom_candidat, cdt_prenom_candidat, cnc_id FROM t_candidature_cdt
WHERE cnc_id = 1 AND donner_phase_concours(1) = 'terminé' AND cdt_etat = 'S';

--14. Requête donnant les palmarès ( nom / prénom / rang des 3 vainqueurs) des concours terminés (sans tenir compte des notes des juges au profil désactivé)
SELECT cdt_nom_candidat, cdt_prenom_candidat, cnc_id, cat_id, SUM(nte_note) as note FROM t_candidature_cdt
JOIN t_notation_nte ON t_candidature_cdt.cdt_id = t_notation_nte.cdt_id
JOIN t_jury_jry ON t_notation_nte.cpt_username = t_jury_jry.cpt_username
JOIN t_compte_cpt ON t_jury_jry.cpt_username = t_compte_cpt.cpt_username
WHERE donner_phase_concours(cnc_id) = 'terminé' AND cpt_etat = 'A'
GROUP BY t_candidature_cdt.cdt_id
ORDER BY note DESC;


--En tant que candidat sprint 1⇒
--Inscription (ou candidature) :
--1. Requête vérifiant l’existence du couple de codes (identification / inscription)
DELIMITER //
CREATE FUNCTION candidat_existe(code_c CHAR(8), code_d CHAR(20)) RETURNS INT
BEGIN
SELECT cdt_id INTO @cdt FROM t_candidature_cdt WHERE cdt_code_candidat = code_c AND cdt_code_dossier = code_d; 
RETURN @cdt;
END;
//
DELIMITER ;

--2. Requête d’affichage, si autorisé, de toutes les informations associées à une inscription connaissant le couple de code d’identification / code d’inscription
SET @code_c := ';4t3[FxU';
SET @code_d := 'w3/nCd_Y5#z^ZG]v49U5';
SELECT * FROM t_candidature_cdt 
WHERE candidat_existe(@code_c, @code_d) = cdt_id;


--sprint 2⇒
--3. Requête(s) d’insertion de toutes les données d’un candidat et de sa candidature, y compris ses documents ressources et sa catégorie
SET @id_cnc := 2;
SET @id_cat := 3;
INSERT INTO t_candidature_cdt 
VALUES(NULL,'mail@gmail.com','Nom', 'Prénom', 'Description', 'code dossier', 'code candidat', '0000-00-00', 'N', @id_cnc, @id_cat);

INSERT INTO t_document_doc VALUES(NULL,'2024-10-27Nomdudocument.exe', './documents/2024-10-27Nomdudocument.exe', 'Executable Windows', 2);

--4. Requête(s) de suppression d’une candidature connaissant le couple de code d’identification / code d’inscription
DELIMITER //
CREATE TRIGGER trigger_delete_candidature
BEFORE DELETE ON t_candidature_cdt
FOR EACH ROW
BEGIN
DELETE FROM t_document_doc WHERE t_candidature_cdt.cdt_id = OLD.cdt_id;
DELETE FROM t_notation_nte WHERE t_notation_nte.cdt_id = OLD.cdt_id;
END;
//
DELIMITER ;

SET @code_c := ';4t3[FxU';
SET @code_d := 'w3/nCd_Y5#z^ZG]v49U5';
DELETE FROM t_candidature_cdt WHERE cdt_code_candidat = @code_c AND cdt_code_dossier = @code_d


-- En tant qu’administrateur / En tant que membre du jury sprint 1⇒
-- Profils (administrateurs / membres du jury) :
-- 1. Requête listant toutes les données de tous les profils classés par statut
SELECT t_compte_cpt.cpt_username, cpt_etat, adm_nom, adm_prenom, jry_nom, jry_prenom FROM t_compte_cpt
LEFT JOIN t_administrateur_adm ON t_compte_cpt.cpt_username = t_administrateur_adm.cpt_username
LEFT JOIN t_jury_jry ON t_compte_cpt.cpt_username = t_jury_jry.cpt_username
ORDER BY cpt_etat

-- 2. Requête de vérification des données de connexion (login et mot de passe)
DELIMITER //
CREATE FUNCTION compte_connexion(username TEXT, mdp TEXT) RETURNS TEXT
BEGIN
SELECT cpt_username INTO @cpt FROM t_compte_cpt WHERE cpt_username = username AND cpt_mot_de_passe = SHA2(CONCAT('OoL56T%', mdp), 512); 
IF @cpt IS NULL THEN RETURN NULL;
ELSE RETURN @cpt;
END IF;
END;
//
DELIMITER ;

-- 3. Requête récupérant les données d'un profil particulier (utilisateur connecté)
SET @usr = 'michel.blanc@gmail.com';
SET @mdp = 'OrgN3#CnC75';

SELECT * FROM t_compte_cpt
LEFT JOIN t_administrateur_adm ON t_compte_cpt.cpt_username = t_administrateur_adm.cpt_username
WHERE compte_connexion(@usr, @mdp) = t_compte_cpt.cpt_username;

-- 4. Requête de mise à jour du mot de passe d'un profil
@mdp = 'Nouveau mot de passe';
UPDATE t_compte_cpt SET cpt_password = SHA2(CONCAT('OoL56T%', @mdp), 512) WHERE cpt_username = 'victor.mankowski@gmail.com';

-- 5. Requête d'ajout des données d'un profil administrateur
INSERT INTO t_administrateur_adm VALUES('charles.carrefour@gmail.com', 'Charles', 'Carrefour');

--d'un profil jury
INSERT INTO t_jury_jry VALUES('enzo.gp@gmail.com', 'Pedra', 'Enzo', 'Pro gamer', 'Ayant de grande connaissance dans le domaine...', NULL);

-- sprint 2⇒
-- 6. Requête de désactivation d'un profil
UPDATE t_compte_cpt SET cpt_etat = 'D' WHERE cpt_username = 'victor.mankowski@gmail.com';

-- 7. Requête(s) de suppression d’un profil administrateur / membre de jury et des 
-- données associées à ce profil (sans supprimer les données d’un concours démarré !)

--Pour admin
UPDATE t_concours_cnc SET cpt_username = 'organisateur@gmail.com' WHERE cpt_username = 'charles.carrefour@gmail.com';
DELETE FROM t_actualite_act WHERE cpt_username = 'charles.carrefour@gmail.com';
DELETE FROM t_administrateur_adm WHERE cpt_username = 'charles.carrefour@gmail.com';

DELETE FROM t_administrateur_adm WHERE cpt_username = 'charles.carrefour@gmail.com'

--Pour jury
DELETE FROM t_message_msg WHERE cpt_username = 'victor.mankowski@gmail.com';
UPDATE t_juge_jge SET cpt_username = 'jury.temporaire@gmail.com';
UPDATE t_notation_nte SET cpt_username = 'jury.temporaire@gmail.com';

DELETE FROM t_jury_jry WHERE cpt_username = 'victor.mankowski@gmail.com';


-- En tant qu’administrateur sprint 2⇒
-- Concours / catégories / membres du jury / [+ disciplines] :
-- 1. Requête listant tous les concours ordonnés par leur date de début
SELECT * FROM t_concours_cnc ORDER BY cnc_date_debut ASC;

-- 2. Requête listant tous les concours et leur(s) catégorie(s) et juges, s’il y en a
SELECT cnc_nom, cat_nom, t_juge_jge.cpt_username FROM t_concours_cnc
JOIN t_juge_jge ON t_concours_cnc.cnc_id = t_juge_jge.cnc_id
JOIN t_comprend_cmp ON t_concours_cnc.cnc_id = t_comprend_cmp.cnc_id
JOIN t_categorie_cat ON t_comprend_cmp.cat_id = t_categorie_cat.cat_id

-- 3. Requête permettant à l’administrateur connecté l’insertion d’un concours et de ses données générales
DROP PROCEDURE IF EXISTS creer_concours;
DELIMITER //
CREATE PROCEDURE creer_concours(IN NOM TEXT, IN TEXTE TEXT, IN D_DEBUT DATE, IN NBJ_C INT, IN NBJ_PS INT, IN NBJ_S INT, IN USR TEXT, IN MDP TEXT)
BEGIN
IF compte_connexion(USR, MDP) = USR THEN 
    INSERT INTO t_concours_cnc VALUES(NULL, NOM, TEXTE, D_DEBUT, NBJ_C, NBJ_PS, NBJ_S, USR);
END IF;
END;
//
DELIMITER ;

-- sprint 3⇒
-- 4. Requête permettant à l’administrateur connecté de modifier les données générales d’un concours (ex : son petit texte introductif)
-- 5. Requête(s) permettant à l’administrateur connecté de supprimer l’un de ses concours non démarré et les données associées
-- 6. Requête listant les concours qui ne sont plus liés à un administrateur OU requête listant les concours liés à un profil administrateur désactivé
-- 7. Requêtes de gestion CRUD d’une discipline par un administrateur connecté
-- 8. Requête listant toutes les catégories qui existent
-- 9. Requête d’ajout des données d’une catégorie
-- 10. Requête de modification d’une catégorie
-- 11. Requête(s) de suppression d’une catégorie
-- 12. Requête permettant d’associer une catégorie (/ un membre du jury / [[ une discipline ]]) à un concours qui n’a pas encore débuté
-- 13. Requête permettant de retirer (!!) une catégorie (/ un membre du jury / [[ une discipline ]]) associée à un concours qui n’a pas encore débuté


-- En tant que membre du jury sprint 3⇒
-- Sujets / messages :
-- 1. Requête listant tous les sujets d’un concours (ID connu) + messages éventuels
-- 2. Requête listant tous les sujets classés par concours connaissant l’ID du juge connecté
-- 3. Requête permettant au membre du jury connecté d’ajouter un sujet
-- 4. Requête permettant au membre du jury connecté de modifier un sujet
-- 5. Requête(s) permettant au membre du jury connecté de supprimer un sujet
-- 6. Requête permettant au juge connecté d’ajouter un message à un sujet particulier
-- 7. Requête permettant au membre du jury connecté de lister tous ses messages classés par sujet
-- 8. Requête permettant au juge connecté de modifier un de ses messages
-- 9. Requête permettant au juge connecté de supprimer un de ses messages

-- En tant qu’administrateur
-- 10. Requête (ou code SQL) permettant à l’administrateur connecté de modérer un message



-- En tant qu’administrateur sprint 2⇒
-- Pré-sélection des candidats et sélection des finalistes :
-- 1. Requête donnant la liste des concours démarrés qui n’ont pas encore enregistré
-- d’inscription

--Fonction qui prend l'id du concours et qui retourne le nombre de candidatures liées à celui-ci
DELIMITER //
CREATE FUNCTION get_nb_candidatures(ID INT) RETURNS INT
BEGIN
SELECT COUNT(cdt_id) INTO @res FROM t_candidature_cdt WHERE cnc_id = ID;
RETURN @res;
END;
//
DELIMITER ;

SELECT cnc_nom FROM t_concours_cnc WHERE CURDATE() > cnc_date_debut AND get_nb_candidatures(cnc_id) = 0;

-- 2. Requête listant toutes les candidatures classées par concours
SELECT cdt_nom_candidat, cdt_prenom_candidat, cnc_id FROM t_candidature_cdt ORDER BY cnc_id;

-- 3. Requête listant toutes les candidatures pour un concours particulier
SELECT cdt_nom_candidat, cdt_prenom_candidat, cnc_id FROM t_candidature_cdt WHERE cnc_id = 1;

-- 4. Requête listant toutes les candidatures par catégorie pour un concours particulier
SELECT cdt_nom_candidat, cdt_prenom_candidat, cat_id FROM t_candidature_cdt WHERE cnc_id = 1 ORDER BY cat_id;

-- 5. Requête listant les candidatures d’un concours particulier selon leur état
SELECT cdt_nom_candidat, cdt_prenom_candidat, cdt_etat FROM t_candidature_cdt WHERE cnc_id = 1 ORDER BY cdt_etat;

-- 6. Requête donnant la liste des candidatures faites non pré-sélectionnées pour un concours particulier en phase de pré-sélection
SELECT cdt_nom_candidat, cdt_prenom_candidat, cdt_etat, donner_phase_concours(cnc_id) as cnc_phase FROM t_candidature_cdt 
WHERE donner_phase_concours(cnc_id) = 'pré-sélection' AND cnc_id = 2 AND cdt_etat = 'N';

-- 7. Requête (ou code SQL) modifiant l’état d’une candidature (ID connu)
DELIMITER //
CREATE PROCEDURE update_etat_cdt(IN ID INT)
BEGIN
SELECT cdt_etat INTO @etat FROM t_candidature_cdt WHERE cdt_id = ID;
IF @etat = 'N' THEN SET @nvetat = 'P';
ELSEIF @etat = 'P' THEN SET @nvetat = 'S';
END IF;
UPDATE t_candidature_cdt SET cdt_etat = @nvetat WHERE cdt_id = ID;
END;
//
DELIMITER ;

-- 8. Requête donnant toutes les informations d’un candidat à partir de son ID (/ou de son code d’inscription au concours)
SELECT * FROM t_candidature_cdt WHERE cdt_id = 1 

-- 9. Requête listant toutes les candidatures pré-sélectionnées classées par concours que le membre du jury connecté doit évaluer
SET @usr := 'adresse mail du jury connecté';
SELECT cdt_nom_candidat, cdt_prenom_candidat FROM t_candidature_cdt 
WHERE donner_phase_concours(cnc_id) = 'pré-sélection' AND cnc_id = (SELECT cnc_id FROM t_juge_jge WHERE cpt_username = @usr) AND cdt_etat = 'P'
ORDER BY cnc_id;

-- En tant que membre du jury
-- 10. Requête pour vérifier si le juge connecté a déjà mis ses 4 points (/ 3 ou 2 points)
DELIMITER //
CREATE FUNCTION get_points_attribues(PNT INT, USR TEXT) RETURNS INT
BEGIN
SELECT SUM(nte_note) INTO @res FROM t_notation_nte WHERE nte_note = PNT AND cpt_username = USR;
RETURN @res;
END;
//
DELIMITER ;

SELECT get_points_attribues(4, 'victor.mankowski@gmail.com');

-- 11. Requête permettant au juge connecté d’attribuer une note à une candidature
DELIMITER //
CREATE PROCEDURE attribuer_point(IN PNT INT, IN ID INT, IN USR TEXT)
BEGIN
IF PNT = 0 OR PNT = 1 THEN INSERT INTO t_notation_nte VALUES(PNT, USR, ID);
ELSEIF PNT >= 2 AND PNT <= 4 AND get_points_attribues(PNT, USR) IS NULL THEN INSERT INTO t_notation_nte VALUES(PNT, USR, ID);
END IF;
END;
//
DELIMITER ;

-- 12. Requête permettant au juge connecté de modifier sa note pour une candidature
DELIMITER //
CREATE PROCEDURE modifier_point(IN PNT INT, IN ID INT, IN USR TEXT)
BEGIN
IF PNT = 0 OR PNT = 1 THEN UPDATE t_notation_nte SET nte_note = PNT WHERE cdt_id = ID AND cpt_username = USR;
ELSEIF (PNT >= 2 OR PNT <= 4) AND get_points_attribues(PNT, USR) IS NULL THEN UPDATE t_notation_nte SET nte_note = PNT WHERE cdt_id = ID AND cpt_username = USR;
END IF;
END;
//
DELIMITER ;

-- 13. Requête listant tous les candidats finalistes d’un concours (connaissant l’identifiant du membre de jury connecté)
-- et leur(s) points, s’ils en ont, en les classant dans l’ordre décroissant de leurs points (et en ne tenant compte que des
-- notes des juges dont le profil est activé)
SET @usr = 'chleo.lamarre@gmail.com';

SELECT cdt_nom_candidat, cdt_prenom_candidat, SUM(nte_note) as cdt_note, cnc_id, cat_id 
FROM t_candidature_cdt 
JOIN t_notation_nte ON t_notation_nte.cdt_id = t_candidature_cdt.cdt_id
JOIN t_jury_jry ON t_notation_nte.cpt_username = t_jury_jry.cpt_username
JOIN t_compte_cpt ON t_jury_jry.cpt_username = t_compte_cpt.cpt_username
WHERE cnc_id = (SELECT cnc_id FROM t_juge_jge WHERE cpt_username = @usr) AND cdt_etat = 'S' AND cpt_etat = 'A'
GROUP BY t_candidature_cdt.cdt_id
ORDER BY cdt_note DESC;