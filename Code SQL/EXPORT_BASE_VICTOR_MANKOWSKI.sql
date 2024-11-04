-- phpMyAdmin SQL Dump
-- version 5.2.1deb1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : lun. 04 nov. 2024 à 09:26
-- Version du serveur : 10.11.6-MariaDB-0+deb12u1-log
-- Version de PHP : 8.2.20

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `e22007619_db2`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `attribuer_point` (IN `PNT` INT, IN `ID` INT, IN `USR` TEXT)   BEGIN
IF PNT = 0 OR PNT = 1 THEN INSERT INTO t_notation_nte VALUES(PNT, USR, ID);
ELSEIF PNT >= 2 AND PNT <= 4 AND get_points_attribues(PNT, USR) IS NULL THEN INSERT INTO t_notation_nte VALUES(PNT, USR, ID);
END IF;
END$$

CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `creer_concours` (IN `NOM` TEXT, IN `TEXTE` TEXT, IN `D_DEBUT` DATE, IN `NBJ_C` INT, IN `NBJ_PS` INT, IN `NBJ_S` INT, IN `USR` TEXT, IN `MDP` TEXT)   BEGIN
IF compte_connexion(USR, MDP) = USR THEN 
    INSERT INTO t_concours_cnc VALUES(NULL, NOM, TEXTE, D_DEBUT, NBJ_C, NBJ_PS, NBJ_S, USR);
END IF;
END$$

CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `insert_act` ()   BEGIN
SET @id = get_id_last_cnc();
SELECT cnc_nom INTO @cnc_nom FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_description INTO @cnc_desc FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_date_debut INTO @date FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cpt_username INTO @cnc_orga FROM t_concours_cnc WHERE cnc_id = @id;
INSERT INTO t_actualite_act VALUES(NULL, 'Nouveau concours !', CONCAT_WS(', ',@cnc_nom,@cnc_desc, @date), CURDATE(), 'A', @cnc_orga);
END$$

CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `modifier_point` (IN `PNT` INT, IN `ID` INT, IN `USR` TEXT)   BEGIN
IF PNT = 0 OR PNT = 1 THEN UPDATE t_notation_nte SET nte_note = PNT WHERE cdt_id = ID AND cpt_username = USR;
ELSEIF PNT >= 2 OR PNT <= 4 AND get_points_attribues(PNT, USR) IS NULL THEN UPDATE t_notation_nte SET nte_note = PNT WHERE cdt_id = ID AND cpt_username = USR;
END IF;
END$$

CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `update_etat_cdt` (IN `ID` INT)   BEGIN
SELECT cdt_etat INTO @etat FROM t_candidature_cdt WHERE cdt_id = ID;
IF @etat = 'N' THEN SET @nvetat = 'P';
ELSEIF @etat = 'P' THEN SET @nvetat = 'S';
END IF;
UPDATE t_candidature_cdt SET cdt_etat = @nvetat WHERE cdt_id = ID;
END$$

--
-- Fonctions
--
CREATE DEFINER=`e22007619sql`@`%` FUNCTION `candidat_existe` (`code_c` CHAR(8), `code_d` CHAR(20)) RETURNS INT(11)  BEGIN
SELECT cdt_id INTO @cdt FROM t_candidature_cdt WHERE cdt_code_candidat = code_c AND cdt_code_dossier = code_d; 
RETURN @cdt;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `compte_connexion` (`username` TEXT, `mdp` TEXT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SELECT cpt_username INTO @cpt FROM t_compte_cpt WHERE cpt_username = username AND cpt_password = SHA2(CONCAT('OoL56T%', mdp), 512); 
IF @cpt IS NULL THEN RETURN NULL;
ELSE RETURN @cpt;
END IF;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `donner_phase_concours` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN

SELECT cnc_date_debut INTO @date_debut FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_debut, cnc_nb_jours_candidature) INTO @date_candidature FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_candidature, cnc_nb_jours_pre_selection) INTO @date_pre_sel FROM t_concours_cnc WHERE cnc_id = ID;
SELECT ADDDATE(@date_pre_sel, cnc_nb_jours_selection) INTO @date_sel FROM t_concours_cnc WHERE cnc_id = ID;


IF CURDATE() < @date_debut THEN RETURN 'à venir';
ELSEIF CURDATE() > @date_debut AND CURDATE() < @date_candidature THEN RETURN 'candidature';
ELSEIF CURDATE() > @date_candidature AND CURDATE() < @date_pre_sel THEN RETURN 'pré-selection';
ELSEIF CURDATE() > @date_pre_sel AND CURDATE() < @date_sel THEN RETURN 'sélection';
ELSE RETURN 'terminé';
END IF;

END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_cat_cnc` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SELECT GROUP_CONCAT(cat_nom ORDER BY cat_nom ASC SEPARATOR ', ') INTO @res FROM t_categorie_cat
JOIN t_comprend_cmp ON t_categorie_cat.cat_id = t_comprend_cmp.cat_id
WHERE cnc_id = ID;
RETURN @res;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_date_intermediaire` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SELECT cnc_date_debut, cnc_nb_jours_candidature, cnc_nb_jours_pre_selection, cnc_nb_jours_selection INTO @date_debut, @nbj_candidature, @nbj_pre_sel, @nbj_sel
    FROM t_concours_cnc WHERE cnc_id = ID;

SET @date_candidature := ADDDATE(@date_debut, @nbj_candidature);
SET @date_pre_sel := ADDDATE(@date_candidature, @nbj_pre_sel);
SET @date_sel := ADDDATE(@date_pre_sel, @nbj_sel);

SELECT CONCAT_WS(', ', @date_debut, @date_candidature, @date_pre_sel, @date_sel) INTO @res;
RETURN @res;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_id_last_cnc` () RETURNS INT(11)  BEGIN
SELECT cnc_id INTO @id FROM t_concours_cnc ORDER BY cnc_date_debut DESC LIMIT 1;
RETURN @id;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_jry_cnc` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SELECT GROUP_CONCAT(CONCAT_WS(', ',jry_nom,jry_prenom,t_jury_jry.cpt_username) ORDER BY t_jury_jry.cpt_username ASC SEPARATOR ' / ') INTO @res FROM t_jury_jry
JOIN t_juge_jge ON t_jury_jry.cpt_username = t_juge_jge.cpt_username
WHERE cnc_id = ID;
RETURN @res;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_nb_candidatures` (`ID` INT) RETURNS INT(11)  BEGIN
SELECT COUNT(cdt_id) INTO @res FROM t_candidature_cdt WHERE cnc_id = ID;
RETURN @res;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_nb_docs` (`ID` INT) RETURNS INT(11)  BEGIN
SELECT COUNT(doc_nom) INTO @res FROM t_document_doc WHERE cdt_id = ID;
RETURN @res;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_orga_cnc` (`ID` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
SELECT cpt_username INTO @orga FROM t_concours_cnc WHERE cnc_id = ID;
RETURN @orga;
END$$

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_points_attribues` (`PNT` INT, `USR` TEXT) RETURNS INT(11)  BEGIN
SELECT SUM(nte_note) INTO @res FROM t_notation_nte WHERE nte_note = PNT AND cpt_username = USR;
RETURN @res;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_actualite_act`
--

CREATE TABLE `t_actualite_act` (
  `act_id` int(11) NOT NULL,
  `act_titre` varchar(60) NOT NULL,
  `act_texte` varchar(200) DEFAULT NULL,
  `act_date_publication` date NOT NULL,
  `act_actif` char(1) NOT NULL,
  `cpt_username` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_actualite_act`
--

INSERT INTO `t_actualite_act` (`act_id`, `act_titre`, `act_texte`, `act_date_publication`, `act_actif`, `cpt_username`) VALUES
(1, 'VMVM 2024*', 'Un max de lot à remporter dans toutes les catégories !', '2024-06-01', 'A', 'organisateur@gmail.com'),
(2, 'Fin du premier concours du Site !', 'Le palmarès est maintenant disponible dans la fiche du concours', '2024-06-25', 'A', 'organisateur@gmail.com'),
(3, 'Début du second concours du Site !', 'On espère vous voir nombreux à participer !', '2024-10-01', 'A', 'organisateur@gmail.com'),
(6, 'Changement de nom !', 'Attention, changement de nom du concours => Unity Jam #2 => Nouveau nom', '2024-10-17', 'A', 'organisateur@gmail.com'),
(9, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Unity Jam #2 => Voir la liste des concours !', '2024-10-17', 'A', 'organisateur@gmail.com'),
(23, 'Changement de nom !', 'Attention, changement de nom du concours => Godot Jam #1 => VMVM 2024*', '2024-10-24', 'A', 'organisateur@gmail.com'),
(25, 'Modification du concours !', 'MODIFICATION DU CONCOURS => VMVM 2024* => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(27, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #2 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(29, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Unity Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(31, 'Changement de nom !', 'Attention, changement de nom du concours => Godot Jam #2 => Godot Jam #1', '2024-10-30', 'A', 'organisateur@gmail.com'),
(32, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(33, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #2 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(34, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(35, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #2 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(36, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(37, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(38, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #2 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(39, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Godot Jam #2 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com'),
(40, 'Modification du concours !', 'MODIFICATION DU CONCOURS => Unreal Jam #1 => Voir la liste des concours !', '2024-10-30', 'A', 'organisateur@gmail.com');

-- --------------------------------------------------------

--
-- Structure de la table `t_administrateur_adm`
--

CREATE TABLE `t_administrateur_adm` (
  `cpt_username` varchar(120) NOT NULL,
  `adm_nom` varchar(60) DEFAULT NULL,
  `adm_prenom` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_administrateur_adm`
--

INSERT INTO `t_administrateur_adm` (`cpt_username`, `adm_nom`, `adm_prenom`) VALUES
('anna.guillou@gmail.com', 'Anna', 'Guillou'),
('charles.carrefour@gmail.com', 'Charles', 'Carrefour'),
('michel.blanc@gmail.com', 'Michel', 'Blanc'),
('organisateur@gmail.com', NULL, 'organisateur'),
('rui.duarte@gmail.com', 'Rui', 'Duarte');

-- --------------------------------------------------------

--
-- Structure de la table `t_candidature_cdt`
--

CREATE TABLE `t_candidature_cdt` (
  `cdt_id` int(11) NOT NULL,
  `cdt_mail` varchar(120) NOT NULL,
  `cdt_nom_candidat` varchar(60) NOT NULL,
  `cdt_prenom_candidat` varchar(60) NOT NULL,
  `cdt_presentation_candidat` varchar(200) NOT NULL,
  `cdt_code_dossier` char(20) NOT NULL,
  `cdt_code_candidat` char(8) NOT NULL,
  `cdt_date_inscription` date NOT NULL,
  `cdt_etat` char(1) NOT NULL,
  `cnc_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_candidature_cdt`
--

INSERT INTO `t_candidature_cdt` (`cdt_id`, `cdt_mail`, `cdt_nom_candidat`, `cdt_prenom_candidat`, `cdt_presentation_candidat`, `cdt_code_dossier`, `cdt_code_candidat`, `cdt_date_inscription`, `cdt_etat`, `cnc_id`, `cat_id`) VALUES
(2, 'mker@gmail.com', 'Kerneis', 'Martin', 'Apprentis', 'sU9e2Y6~ff+!s=8V5{TU', ',NZ7p3a:', '2024-06-01', 'S', 1, 1),
(3, 'egou@gmail.com', 'Gouerec', 'Evan', 'Premier concours !', 'ke[@7P8(5LB}:fyJc7M3', '5aAb~2_T', '2024-06-01', 'S', 1, 2),
(7, 'flg@gmail.com', 'Le Guen', 'Frédérique', 'Je suis la pour gagner !', 'y2k-K~Q6$u85Es%DA6;c', 'c6%*5RYw', '2024-06-06', 'P', 1, 2),
(8, 'rcreff@gmail.com', 'Creff', 'Rose-Marie', 'Je découvre la programmation', '{F4y*L6=MDttH9.5+5jm', 'Pm8Y7m+-', '2024-06-04', 'P', 1, 3),
(9, 'obern@gmail.com', 'Berniere', 'Oskar', 'Je suis la pour apprendre', 'AY8),?h4!n}ApkLJ5w76', 'D3aL]@z2', '2024-10-02', 'N', 1, 3),
(10, 'jiva@gmail.com', 'Ivanoff', 'Jacques', 'Développeur confirmé', '.ze%:]9Zi6TZx#62LeE2', 'Pg4!6U=c', '2024-10-01', 'P', 2, 2),
(11, 'zmkw@gmail.com', 'Mankowski', 'Zelie', 'Découverte des concours !', 'n3m3^Q@R8PS?)pC3fw/2', '^3zdK{9V', '2024-10-05', 'N', 2, 2),
(12, 'lcas@gmail.com', 'Casemode', 'Lilou', 'La pour tout gagner', '5E(B2S82riR;aq_*Yj8[', 'D($h87qN', '2024-10-02', 'N', 2, 3),
(13, 'edam@gmail.com', 'Damota', 'Eva', 'Développeuse experte', '66URm$6,X-bk^R8tWc4(', 'r.bF58H)', '2024-10-04', 'P', 2, 3),
(14, 'jbbrd@gmail.com', 'Broudin', 'Jean-Baptiste', 'Fan de jeux-vidéos', 'w3/nCd_Y5#z^ZG]v49U5', ';4t3[FxU', '2024-10-31', 'S', 1, 1);

--
-- Déclencheurs `t_candidature_cdt`
--
DELIMITER $$
CREATE TRIGGER `set_curdate_cdt` BEFORE INSERT ON `t_candidature_cdt` FOR EACH ROW BEGIN
SET NEW.cdt_date_inscription := CURDATE();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trigger_delete_candidature` BEFORE DELETE ON `t_candidature_cdt` FOR EACH ROW BEGIN
DELETE FROM t_document_doc WHERE t_document_doc.cdt_id = OLD.cdt_id;
DELETE FROM t_notation_nte WHERE t_notation_nte.cdt_id = OLD.cdt_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_categorie_cat`
--

CREATE TABLE `t_categorie_cat` (
  `cat_id` int(11) NOT NULL,
  `cat_nom` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_categorie_cat`
--

INSERT INTO `t_categorie_cat` (`cat_id`, `cat_nom`) VALUES
(1, 'Débutant'),
(2, 'Junior'),
(3, 'Senior');

-- --------------------------------------------------------

--
-- Structure de la table `t_comprend_cmp`
--

CREATE TABLE `t_comprend_cmp` (
  `cnc_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_comprend_cmp`
--

INSERT INTO `t_comprend_cmp` (`cnc_id`, `cat_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 2),
(2, 3);

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_cpt`
--

CREATE TABLE `t_compte_cpt` (
  `cpt_username` varchar(120) NOT NULL,
  `cpt_password` char(128) NOT NULL,
  `cpt_etat` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_compte_cpt`
--

INSERT INTO `t_compte_cpt` (`cpt_username`, `cpt_password`, `cpt_etat`) VALUES
('anna.guillou@gmail.com', 'f16265dfb9ed829a73d4091fad2560dc38d71af0e5a6334785db60000a5808e283657af681f899bdc4e1d99660bf8e09567ccd96d1b6b3c5d0c3f92221af3bea', 'A'),
('charles.carrefour@gmail.com', '6cd765201ec49f0bb39faaa1df054a119df5fc3f44989e4b5d4b805e6de3cc4b7885b216102d20879d1154144b25ce78ffda3cfaaaf06aa5199158bb74873d9b', 'A'),
('chleo.lamarre@gmail.com', 'dd345716fb166806cd6c72c69ef085bb88e98de4b850539a4ff89aec352ab87b53181dfdec89f68f5fc92b8456e74b9331521bd29e593ca3658f1310a46b8012', 'A'),
('enzo.gp@gmail.com', '3e84a4fc43c085ca792d18bebb3b61c44806d6f50c7ea932c37cbded7a22d7dda76c1f4ae072703e8cf362a120e7c41347ac19e55b0986f3402d0f434f883818', 'D'),
('legall.patrick@gmail.com', 'e8b41658f9dc32cb51783e27b03946df81ad094b75165870f19db1a640873e9dde5c33cc17c83230c454e4a952b05b3dfee7cb4115867abdf38367ced561c0bb', 'D'),
('michel.blanc@gmail.com', 'ede1970b3b87d8939ca331b8204ce6f0c49613d40b3a10752843b1dcdd01242262aab3a387f20cac51afbc54f9ccbdcefb9edffcb40842f90f5507f753749f87', 'A'),
('organisateur@gmail.com', 'b254b8be6cb18b28a16869aeb134eec6711361b01a098f6c292fd4811927aae72bfc94961856f668ed83dae95f83dafcbdb1e9d2df02b78bc54d3db84032e30b', 'A'),
('progamedev@gmail.com', '79248ef7371dc7f18520bbf4826aaeaf7e919c4c78e8e377501893f88ceb21d68047b5be4ac79edb20e0f019f0922cdf524e3680a58691eb07eea6da568ccb82', 'A'),
('rui.duarte@gmail.com', 'b0f3516e98381bbbbb58a585b2cb38851dd8ee2a478405af86c98802c1507f6e38ec42fe99d2556dcebb43b6ed97bee53083dd6483acfbe2288749bf212f38e4', 'A'),
('victor.mankowski@gmail.com', 'b4836e4e72d5e379078abf8cc34bbd5e6d5ad1f6b0ea77338e6ec46ce89b9d45f9e28092e04b1879fc52232990eb768066b29e3cdea01dc1646b2ae87d6a529c', 'A');

--
-- Déclencheurs `t_compte_cpt`
--
DELIMITER $$
CREATE TRIGGER `trigg_supp_admin` BEFORE DELETE ON `t_compte_cpt` FOR EACH ROW BEGIN
UPDATE t_concours_cnc SET cpt_username = 'organisateur@gmail.com' WHERE t_concours_cnc.cpt_username = OLD.cpt_username;
DELETE FROM t_actualite_act WHERE t_actualite_act.cpt_username = OLD.cpt_username;
DELETE FROM t_administrateur_adm WHERE t_administrateur_adm.cpt_username = OLD.cpt_username;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_concours_cnc`
--

CREATE TABLE `t_concours_cnc` (
  `cnc_id` int(11) NOT NULL,
  `cnc_nom` varchar(60) NOT NULL,
  `cnc_description` varchar(200) NOT NULL,
  `cnc_date_debut` date NOT NULL,
  `cnc_nb_jours_candidature` int(11) NOT NULL,
  `cnc_nb_jours_pre_selection` int(11) NOT NULL,
  `cnc_nb_jours_selection` int(11) NOT NULL,
  `cpt_username` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_concours_cnc`
--

INSERT INTO `t_concours_cnc` (`cnc_id`, `cnc_nom`, `cnc_description`, `cnc_date_debut`, `cnc_nb_jours_candidature`, `cnc_nb_jours_pre_selection`, `cnc_nb_jours_selection`, `cpt_username`) VALUES
(1, 'Godot Jam #1', 'Première JAM sur le moteur Godot; Le thème: Fragment', '2024-06-01', 7, 15, 7, 'organisateur@gmail.com'),
(2, 'Godot Jam #2', 'Seconde JAM sur le moteur Godot; Le thème: Nature', '2024-10-01', 1, 60, 7, 'organisateur@gmail.com'),
(3, 'Unity Jam #1', 'Première JAM sur le moteur Unity; Le thème: Grandeur', '2024-10-01', 1, 1, 60, 'rui.duarte@gmail.com'),
(4, 'Unreal Jam #1', 'Première JAM sur le moteur Unreal; Le thème: Populaire', '2024-10-01', 60, 5, 15, 'rui.duarte@gmail.com'),
(5, 'Unity Jam #2', 'Seconde JAM sur le moteur Unity; Le thème: Vitesse', '2025-01-01', 15, 7, 7, 'rui.duarte@gmail.com'),
(8, 'Concours Test', 'Ceci est un test', '2024-12-01', 14, 14, 14, 'anna.guillou@gmail.com');

--
-- Déclencheurs `t_concours_cnc`
--
DELIMITER $$
CREATE TRIGGER `actu_modif_concours` AFTER UPDATE ON `t_concours_cnc` FOR EACH ROW BEGIN

IF OLD.cnc_nom != NEW.cnc_nom AND (OLD.cnc_description = NEW.cnc_description OR OLD.cnc_date_debut = NEW.cnc_date_debut OR OLD.cnc_nb_jours_candidature = NEW.cnc_nb_jours_candidature OR OLD.cnc_nb_jours_pre_selection = NEW.cnc_nb_jours_pre_selection OR OLD.cnc_nb_jours_pre_selection = NEW.cnc_nb_jours_pre_selection) THEN
    INSERT INTO t_actualite_act VALUES (NULL, 'Changement de nom !', CONCAT_WS(' => ', 'Attention, changement de nom du concours', OLD.cnc_nom, NEW.cnc_nom), CURDATE(), 'A', 'organisateur@gmail.com');

ELSEIF OLD.cnc_nom != NEW.cnc_nom OR OLD.cnc_description != NEW.cnc_description OR OLD.cnc_date_debut != NEW.cnc_date_debut OR OLD.cnc_nb_jours_candidature != NEW.cnc_nb_jours_candidature OR OLD.cnc_nb_jours_pre_selection != NEW.cnc_nb_jours_pre_selection OR OLD.cnc_nb_jours_pre_selection != NEW.cnc_nb_jours_pre_selection THEN
    INSERT INTO t_actualite_act VALUES (NULL, 'Modification du concours !', CONCAT_WS(' => ', 'MODIFICATION DU CONCOURS',NEW.cnc_nom,'Voir la liste des concours !'), CURDATE(), 'A','organisateur@gmail.com');

END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `t_document_doc`
--

CREATE TABLE `t_document_doc` (
  `doc_id` int(11) NOT NULL,
  `doc_nom` varchar(60) NOT NULL,
  `doc_emplacement` varchar(300) NOT NULL,
  `doc_type` varchar(60) NOT NULL,
  `cdt_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_document_doc`
--

INSERT INTO `t_document_doc` (`doc_id`, `doc_nom`, `doc_emplacement`, `doc_type`, `cdt_id`) VALUES
(1, 'Jeu de Martin', '/emplacement/2024-06-02jeu.exe', 'Executable Windows', 2);

-- --------------------------------------------------------

--
-- Structure de la table `t_fil_fil`
--

CREATE TABLE `t_fil_fil` (
  `fil_id` int(11) NOT NULL,
  `fil_sujet` varchar(60) NOT NULL,
  `cnc_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_fil_fil`
--

INSERT INTO `t_fil_fil` (`fil_id`, `fil_sujet`, `cnc_id`) VALUES
(1, 'Délibération Concours 1', 1),
(2, 'Délibération Concours 2', 2);

-- --------------------------------------------------------

--
-- Structure de la table `t_juge_jge`
--

CREATE TABLE `t_juge_jge` (
  `cpt_username` varchar(120) NOT NULL,
  `cnc_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_juge_jge`
--

INSERT INTO `t_juge_jge` (`cpt_username`, `cnc_id`) VALUES
('chleo.lamarre@gmail.com', 1),
('enzo.gp@gmail.com', 1),
('legall.patrick@gmail.com', 2),
('progamedev@gmail.com', 2),
('victor.mankowski@gmail.com', 1),
('victor.mankowski@gmail.com', 2);

-- --------------------------------------------------------

--
-- Structure de la table `t_jury_jry`
--

CREATE TABLE `t_jury_jry` (
  `cpt_username` varchar(120) NOT NULL,
  `jry_nom` varchar(60) DEFAULT NULL,
  `jry_prenom` varchar(60) NOT NULL,
  `jry_discipline` varchar(200) NOT NULL,
  `jry_biographie` varchar(2000) NOT NULL,
  `jry_url` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_jury_jry`
--

INSERT INTO `t_jury_jry` (`cpt_username`, `jry_nom`, `jry_prenom`, `jry_discipline`, `jry_biographie`, `jry_url`) VALUES
('chleo.lamarre@gmail.com', 'Lamarre', 'Chleo', 'Psychologue', 'Diplomée d\'un Master en Psychologie Clinique...', NULL),
('enzo.gp@gmail.com', 'Pedra', 'Enzo', 'Joueur Pro', 'Ayant de grande connaissance dans le domaine...', NULL),
('legall.patrick@gmail.com', 'Le Gall', 'Patrick', 'Game Designer', 'Diplomé d\'un Master en Game Design...', NULL),
('progamedev@gmail.com', NULL, 'Pro Game Dev', 'Game Developer', 'Je suis le pro du Game Developpement', NULL),
('victor.mankowski@gmail.com', 'Mankowski', 'Victor', 'Game Developer', 'Je commence à apprendre le developpement de jeux vidéos en 2023...', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `t_message_msg`
--

CREATE TABLE `t_message_msg` (
  `msg_id` int(11) NOT NULL,
  `msg_message` varchar(500) NOT NULL,
  `fil_id` int(11) NOT NULL,
  `cpt_username` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_message_msg`
--

INSERT INTO `t_message_msg` (`msg_id`, `msg_message`, `fil_id`, `cpt_username`) VALUES
(1, 'J\'ai beaucoup aimé le travail de Jean-Baptiste', 1, 'victor.mankowski@gmail.com'),
(2, 'Le concept d\'Evan me parait plus poussé dans le thème', 1, 'enzo.gp@gmail.com'),
(3, 'J\'espère voir de beaux jeux sur ce concours', 2, 'legall.patrick@gmail.com'),
(4, 'Aucun jeu n\'égalera les miens', 2, 'progamedev@gmail.com');

-- --------------------------------------------------------

--
-- Structure de la table `t_notation_nte`
--

CREATE TABLE `t_notation_nte` (
  `nte_note` tinyint(4) NOT NULL,
  `cpt_username` varchar(120) NOT NULL,
  `cdt_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_notation_nte`
--

INSERT INTO `t_notation_nte` (`nte_note`, `cpt_username`, `cdt_id`) VALUES
(1, 'chleo.lamarre@gmail.com', 2),
(4, 'chleo.lamarre@gmail.com', 3),
(3, 'chleo.lamarre@gmail.com', 14),
(3, 'enzo.gp@gmail.com', 2),
(4, 'enzo.gp@gmail.com', 3),
(1, 'victor.mankowski@gmail.com', 2),
(2, 'victor.mankowski@gmail.com', 3);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_candidats_points`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_candidats_points` (
`cdt_nom_candidat` varchar(60)
,`cdt_prenom_candidat` varchar(60)
,`cdt_note` decimal(25,0)
,`cnc_id` int(11)
,`cat_id` int(11)
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_candidats_points`
--
DROP TABLE IF EXISTS `v_candidats_points`;

CREATE ALGORITHM=UNDEFINED DEFINER=`e22007619sql`@`%` SQL SECURITY DEFINER VIEW `v_candidats_points`  AS SELECT `t_candidature_cdt`.`cdt_nom_candidat` AS `cdt_nom_candidat`, `t_candidature_cdt`.`cdt_prenom_candidat` AS `cdt_prenom_candidat`, sum(`t_notation_nte`.`nte_note`) AS `cdt_note`, `t_candidature_cdt`.`cnc_id` AS `cnc_id`, `t_candidature_cdt`.`cat_id` AS `cat_id` FROM (`t_candidature_cdt` join `t_notation_nte` on(`t_notation_nte`.`cdt_id` = `t_candidature_cdt`.`cdt_id`)) GROUP BY `t_candidature_cdt`.`cdt_id` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  ADD PRIMARY KEY (`act_id`),
  ADD KEY `fk_t_actualite_act_t_administrateur_adm2_idx` (`cpt_username`);

--
-- Index pour la table `t_administrateur_adm`
--
ALTER TABLE `t_administrateur_adm`
  ADD PRIMARY KEY (`cpt_username`),
  ADD KEY `fk_t_administrateur_adm_t_compte_cpt1_idx` (`cpt_username`);

--
-- Index pour la table `t_candidature_cdt`
--
ALTER TABLE `t_candidature_cdt`
  ADD PRIMARY KEY (`cdt_id`),
  ADD KEY `fk_t_candidature_cdt_t_categorie_cat1_idx` (`cat_id`),
  ADD KEY `fk_t_candidature_cdt_t_concours_cnc1_idx` (`cnc_id`);

--
-- Index pour la table `t_categorie_cat`
--
ALTER TABLE `t_categorie_cat`
  ADD PRIMARY KEY (`cat_id`);

--
-- Index pour la table `t_comprend_cmp`
--
ALTER TABLE `t_comprend_cmp`
  ADD PRIMARY KEY (`cnc_id`,`cat_id`),
  ADD KEY `fk_t_partition_prt_t_concours_cnc1_idx` (`cnc_id`),
  ADD KEY `fk_t_partition_prt_t_categorie_cat1_idx` (`cat_id`);

--
-- Index pour la table `t_compte_cpt`
--
ALTER TABLE `t_compte_cpt`
  ADD PRIMARY KEY (`cpt_username`);

--
-- Index pour la table `t_concours_cnc`
--
ALTER TABLE `t_concours_cnc`
  ADD PRIMARY KEY (`cnc_id`),
  ADD KEY `fk_t_concours_cnc_t_administrateur_adm1_idx` (`cpt_username`);

--
-- Index pour la table `t_document_doc`
--
ALTER TABLE `t_document_doc`
  ADD PRIMARY KEY (`doc_id`),
  ADD KEY `fk_t_document_doc_t_candidature_cdt1_idx` (`cdt_id`);

--
-- Index pour la table `t_fil_fil`
--
ALTER TABLE `t_fil_fil`
  ADD PRIMARY KEY (`fil_id`),
  ADD KEY `fk_t_fil_fil_t_concours_cnc1_idx` (`cnc_id`);

--
-- Index pour la table `t_juge_jge`
--
ALTER TABLE `t_juge_jge`
  ADD PRIMARY KEY (`cpt_username`,`cnc_id`),
  ADD KEY `fk_t_juge_jge_t_concours_cnc1_idx` (`cnc_id`),
  ADD KEY `fk_t_juge_jge_t_jury_jry1_idx` (`cpt_username`);

--
-- Index pour la table `t_jury_jry`
--
ALTER TABLE `t_jury_jry`
  ADD PRIMARY KEY (`cpt_username`),
  ADD KEY `fk_t_jury_jry_t_compte_cpt1_idx` (`cpt_username`);

--
-- Index pour la table `t_message_msg`
--
ALTER TABLE `t_message_msg`
  ADD PRIMARY KEY (`msg_id`),
  ADD KEY `fk_t_message_msg_t_fil_fil1_idx` (`fil_id`),
  ADD KEY `fk_t_message_msg_t_jury_jry1_idx` (`cpt_username`);

--
-- Index pour la table `t_notation_nte`
--
ALTER TABLE `t_notation_nte`
  ADD PRIMARY KEY (`cpt_username`,`cdt_id`),
  ADD KEY `fk_t_notation_nte_t_jury_jry1_idx` (`cpt_username`),
  ADD KEY `fk_t_notation_nte_t_candidature_cdt1_idx` (`cdt_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  MODIFY `act_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT pour la table `t_candidature_cdt`
--
ALTER TABLE `t_candidature_cdt`
  MODIFY `cdt_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `t_categorie_cat`
--
ALTER TABLE `t_categorie_cat`
  MODIFY `cat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `t_concours_cnc`
--
ALTER TABLE `t_concours_cnc`
  MODIFY `cnc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `t_document_doc`
--
ALTER TABLE `t_document_doc`
  MODIFY `doc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `t_fil_fil`
--
ALTER TABLE `t_fil_fil`
  MODIFY `fil_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `t_message_msg`
--
ALTER TABLE `t_message_msg`
  MODIFY `msg_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `t_actualite_act`
--
ALTER TABLE `t_actualite_act`
  ADD CONSTRAINT `fk_t_actualite_act_t_administrateur_adm2` FOREIGN KEY (`cpt_username`) REFERENCES `t_administrateur_adm` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_administrateur_adm`
--
ALTER TABLE `t_administrateur_adm`
  ADD CONSTRAINT `fk_t_administrateur_adm_t_compte_cpt1` FOREIGN KEY (`cpt_username`) REFERENCES `t_compte_cpt` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_candidature_cdt`
--
ALTER TABLE `t_candidature_cdt`
  ADD CONSTRAINT `fk_t_candidature_cdt_t_categorie_cat1` FOREIGN KEY (`cat_id`) REFERENCES `t_categorie_cat` (`cat_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_candidature_cdt_t_concours_cnc1` FOREIGN KEY (`cnc_id`) REFERENCES `t_concours_cnc` (`cnc_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_comprend_cmp`
--
ALTER TABLE `t_comprend_cmp`
  ADD CONSTRAINT `fk_t_partition_prt_t_categorie_cat1` FOREIGN KEY (`cat_id`) REFERENCES `t_categorie_cat` (`cat_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_partition_prt_t_concours_cnc1` FOREIGN KEY (`cnc_id`) REFERENCES `t_concours_cnc` (`cnc_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_concours_cnc`
--
ALTER TABLE `t_concours_cnc`
  ADD CONSTRAINT `fk_t_concours_cnc_t_administrateur_adm1` FOREIGN KEY (`cpt_username`) REFERENCES `t_administrateur_adm` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_document_doc`
--
ALTER TABLE `t_document_doc`
  ADD CONSTRAINT `fk_t_document_doc_t_candidature_cdt1` FOREIGN KEY (`cdt_id`) REFERENCES `t_candidature_cdt` (`cdt_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_fil_fil`
--
ALTER TABLE `t_fil_fil`
  ADD CONSTRAINT `fk_t_fil_fil_t_concours_cnc1` FOREIGN KEY (`cnc_id`) REFERENCES `t_concours_cnc` (`cnc_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_juge_jge`
--
ALTER TABLE `t_juge_jge`
  ADD CONSTRAINT `fk_t_juge_jge_t_concours_cnc1` FOREIGN KEY (`cnc_id`) REFERENCES `t_concours_cnc` (`cnc_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_juge_jge_t_jury_jry1` FOREIGN KEY (`cpt_username`) REFERENCES `t_jury_jry` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_jury_jry`
--
ALTER TABLE `t_jury_jry`
  ADD CONSTRAINT `fk_t_jury_jry_t_compte_cpt1` FOREIGN KEY (`cpt_username`) REFERENCES `t_compte_cpt` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_message_msg`
--
ALTER TABLE `t_message_msg`
  ADD CONSTRAINT `fk_t_message_msg_t_fil_fil1` FOREIGN KEY (`fil_id`) REFERENCES `t_fil_fil` (`fil_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_message_msg_t_jury_jry1` FOREIGN KEY (`cpt_username`) REFERENCES `t_jury_jry` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `t_notation_nte`
--
ALTER TABLE `t_notation_nte`
  ADD CONSTRAINT `fk_t_notation_nte_t_candidature_cdt1` FOREIGN KEY (`cdt_id`) REFERENCES `t_candidature_cdt` (`cdt_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_t_notation_nte_t_jury_jry1` FOREIGN KEY (`cpt_username`) REFERENCES `t_jury_jry` (`cpt_username`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
