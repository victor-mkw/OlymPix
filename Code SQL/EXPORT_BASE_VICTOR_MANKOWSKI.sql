-- phpMyAdmin SQL Dump
-- version 5.2.1deb1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : mer. 16 oct. 2024 à 16:53
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
CREATE DEFINER=`e22007619sql`@`%` PROCEDURE `insert_act` ()   BEGIN
SET @id = get_id_last_cnc();
SELECT cnc_nom INTO @cnc_nom FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_description INTO @cnc_desc FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cnc_date_debut INTO @date FROM t_concours_cnc WHERE cnc_id = @id;
SELECT cpt_username INTO @cnc_orga FROM t_concours_cnc WHERE cnc_id = @id;
INSERT INTO t_actualite_act VALUES(NULL, 'Nouveau concours !', CONCAT_WS(', ',@cnc_nom,@cnc_desc, @date), CURDATE(), 'A', @cnc_orga);
END$$

--
-- Fonctions
--
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

CREATE DEFINER=`e22007619sql`@`%` FUNCTION `get_id_last_cnc` () RETURNS INT(11)  BEGIN
SELECT cnc_id INTO @id FROM t_concours_cnc ORDER BY cnc_date_debut DESC LIMIT 1;
RETURN @id;
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
(1, 'Début du premier concours du Site !', 'Un max de lot à remporter dans toutes les catégories !', '2024-06-01', 'A', 'organisateur'),
(2, 'Fin du premier concours du Site !', 'Le palmarès est maintenant disponible dans la fiche du concours', '2024-06-25', 'A', 'organisateur'),
(3, 'Début du second concours du Site !', NULL, '2024-10-01', 'A', 'organisateur'),
(4, 'Nouveau concours !', 'Godot Jam #2, Seconde JAM sur le moteur Godot; Le thème: Nature, 2024-10-01', '2024-10-14', 'A', 'organisateur'),
(5, 'Nouveau concours !', 'Unity Jam #1, Première JAM sur le moteur Unity; Le thème: Grandeur, 2024-10-01', '2024-10-15', 'A', 'rui.duarte@gmail.com'),
(6, 'Nouveau concours !', 'Unreal Jam #1, Première JAM sur le moteur Unreal; Le thème: Populaire, 2024-10-01', '2024-10-15', 'A', 'rui.duarte@gmail.com'),
(7, 'Nouveau concours !', 'Unity Jam #2, Seconde JAM sur le moteur Unity; Le thème: Vitesse, 2024-11-01', '2024-10-15', 'A', 'rui.duarte@gmail.com');

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
('organisateur', NULL, 'organisateur'),
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
  `cdt_actif` char(1) NOT NULL,
  `cnc_id` int(11) NOT NULL,
  `cat_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_candidature_cdt`
--

INSERT INTO `t_candidature_cdt` (`cdt_id`, `cdt_mail`, `cdt_nom_candidat`, `cdt_prenom_candidat`, `cdt_presentation_candidat`, `cdt_code_dossier`, `cdt_code_candidat`, `cdt_actif`, `cnc_id`, `cat_id`) VALUES
(1, 'jbbrd@gmail.com', 'Broudin', 'Jean-Baptiste', 'Fan de jeux-vidéos', 'w3/nCd_Y5#z^ZG]v49U5', ';4t3[FxU', 'A', 1, 1),
(2, 'mker@gmail.com', 'Kerneis', 'Martin', 'Apprentis', 'sU9e2Y6~ff+!s=8V5{TU', ',NZ7p3a:', 'A', 1, 1),
(3, 'egou@gmail.com', 'Gouerec', 'Evan', 'Premier concours !', 'ke[@7P8(5LB}:fyJc7M3', '5aAb~2_T', 'A', 1, 2),
(4, 'flg@gmail.com', 'Le Guen', 'Frédérique', 'Je suis la pour gagner !', 'y2k-K~Q6$u85Es%DA6;c', 'c6%*5RYw', 'A', 1, 2),
(5, 'rcreff@gmail.com', 'Creff', 'Rose-Marie', 'Je découvre la programmation', '{F4y*L6=MDttH9.5+5jm', 'Pm8Y7m+-', 'A', 1, 3),
(6, 'obern@gmail.com', 'Berniere', 'Oskar', 'Je suis la pour apprendre', 'AY8),?h4!n}ApkLJ5w76', 'D3aL]@z2', 'A', 1, 3),
(7, 'jiva@gmail.com', 'Ivanoff', 'Jacques', 'Développeur confirmé', '.ze%:]9Zi6TZx#62LeE2', 'Pg4!6U=c', 'A', 2, 2),
(8, 'zmkw@gmail.com', 'Mankowski', 'Zelie', 'Découverte des concours !', 'n3m3^Q@R8PS?)pC3fw/2', '^3zdK{9V', 'A', 2, 2),
(9, 'lcas@gmail.com', 'Casemode', 'Lilou', 'La pour tout gagner', '5E(B2S82riR;aq_*Yj8[', 'D($h87qN', 'A', 2, 3),
(10, 'edam@gmail.com', 'Damota', 'Eva', 'Développeuse experte', '66URm$6,X-bk^R8tWc4(', 'r.bF58H)', 'A', 2, 3);

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
(2, 1),
(2, 2),
(2, 3);

-- --------------------------------------------------------

--
-- Structure de la table `t_compte_cpt`
--

CREATE TABLE `t_compte_cpt` (
  `cpt_username` varchar(120) NOT NULL,
  `cpt_password` char(128) NOT NULL,
  `cpt_actif` char(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_compte_cpt`
--

INSERT INTO `t_compte_cpt` (`cpt_username`, `cpt_password`, `cpt_actif`) VALUES
('anna.guillou@gmail.com', 'e9b5606c6a93e24dbea206c240ed48417bbc447805dd3cbf33879969cd9816458aeed94ffd4484d9c22350c049e19443b0a4726e9371159ca8b693fa51276f38', 'A'),
('charles.carrefour@gmail.com', 'ae608f384efda0d4c579cada81aa8d4543c13fab4d034f47e5d6ba46037697b2803d157e1a91df8d8161232ef79e74a7382a5a82f2c0becd25345b331b236cfe', 'A'),
('chleo.lamarre@gmail.com', 'dd345716fb166806cd6c72c69ef085bb88e98de4b850539a4ff89aec352ab87b53181dfdec89f68f5fc92b8456e74b9331521bd29e593ca3658f1310a46b8012', 'A'),
('enzo.gp@gmail.com', '3e84a4fc43c085ca792d18bebb3b61c44806d6f50c7ea932c37cbded7a22d7dda76c1f4ae072703e8cf362a120e7c41347ac19e55b0986f3402d0f434f883818', 'A'),
('legall.patrick@gmail.com', 'e8b41658f9dc32cb51783e27b03946df81ad094b75165870f19db1a640873e9dde5c33cc17c83230c454e4a952b05b3dfee7cb4115867abdf38367ced561c0bb', 'D'),
('michel.blanc@gmail.com', '14509779d2f2d4f065c383b78be4eb1050f7a9655a94c95c6761ee76cb8aed531935b08ec19acbf894d65a985e1a6328fcb2cad07d157b1c0ccb8ce1abff36d5', 'A'),
('organisateur', 'b254b8be6cb18b28a16869aeb134eec6711361b01a098f6c292fd4811927aae72bfc94961856f668ed83dae95f83dafcbdb1e9d2df02b78bc54d3db84032e30b', 'A'),
('progamedev@gmail.com', '79248ef7371dc7f18520bbf4826aaeaf7e919c4c78e8e377501893f88ceb21d68047b5be4ac79edb20e0f019f0922cdf524e3680a58691eb07eea6da568ccb82', 'A'),
('rui.duarte@gmail.com', 'eefa06f5997c3aac761dbaf77b07c768ec9d9528a8fb47b83e2e22206e59592ad0a7e580ba119413f3b09c900211cb2974ac032e2d810190587ffbac13b9d9c8', 'A'),
('victor.mankowski@gmail.com', 'b4836e4e72d5e379078abf8cc34bbd5e6d5ad1f6b0ea77338e6ec46ce89b9d45f9e28092e04b1879fc52232990eb768066b29e3cdea01dc1646b2ae87d6a529c', 'A');

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
(1, 'Godot Jam #1', 'Première JAM sur le moteur Godot; Le thème: Fragment', '2024-06-01', 7, 15, 2, 'organisateur'),
(2, 'Godot Jam #2', 'Seconde JAM sur le moteur Godot; Le thème: Nature', '2024-10-01', 7, 15, 7, 'organisateur'),
(4, 'Unity Jam #1', 'Première JAM sur le moteur Unity; Le thème: Grandeur', '2024-10-01', 15, 7, 7, 'rui.duarte@gmail.com'),
(5, 'Unreal Jam #1', 'Première JAM sur le moteur Unreal; Le thème: Populaire', '2024-10-01', 5, 5, 15, 'rui.duarte@gmail.com'),
(6, 'Unity Jam #2', 'Seconde JAM sur le moteur Unity; Le thème: Vitesse', '2024-11-01', 15, 7, 7, 'rui.duarte@gmail.com');

--
-- Déclencheurs `t_concours_cnc`
--
DELIMITER $$
CREATE TRIGGER `trigger_act_cnc` AFTER INSERT ON `t_concours_cnc` FOR EACH ROW BEGIN
CALL insert_act();
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
(1, 'Jeu de Martin', '/emplacement/2024-06-02jeu.exe', 'Executable Windows', 2),
(2, 'Jeu de Federique', '/emplacement/2024-06-03monjeu.exe', 'Executable Windows', 4),
(3, 'Jeu de Jean-Baptiste', '/emplacement/2024-06-06godotjamgame.exe', 'Executable Windows', 1);

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
  `jry_description` varchar(200) NOT NULL,
  `jry_biographie` varchar(2000) NOT NULL,
  `jry_url` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_jury_jry`
--

INSERT INTO `t_jury_jry` (`cpt_username`, `jry_nom`, `jry_prenom`, `jry_description`, `jry_biographie`, `jry_url`) VALUES
('chleo.lamarre@gmail.com', 'Lamarre', 'Chleo', 'Experte en psychologie', 'Diplomée d\'un Master en Psychologie Clinique...', NULL),
('enzo.gp@gmail.com', 'Pedra', 'Enzo', 'Pro gamer sur Mario Kart 8 Deluxe', 'Ayant de grande connaissance dans le domaine...', NULL),
('legall.patrick@gmail.com', 'Le Gall', 'Patrick', 'Expert en Game Design', 'Diplomé d\'un Master en Game Design...', NULL),
('progamedev@gmail.com', NULL, 'Pro Game Dev', 'Influenceur en Game Developpement', 'Je suis le pro du Game Developpement', NULL),
('victor.mankowski@gmail.com', 'Mankowski', 'Victor', 'Game Developer Senior', 'Je commence à apprendre le developpement de jeux vidéos en 2023...', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `t_message_msg`
--

CREATE TABLE `t_message_msg` (
  `msg_id` int(11) NOT NULL,
  `msg_message` varchar(45) NOT NULL,
  `fil_id` int(11) NOT NULL,
  `cpt_username` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `t_message_msg`
--

INSERT INTO `t_message_msg` (`msg_id`, `msg_message`, `fil_id`, `cpt_username`) VALUES
(1, 'J\'ai beaucoup aimé le travail de Jean-Baptist', 1, 'victor.mankowski@gmail.com'),
(2, 'Le concept d\'Evan me parait plus poussé dans ', 1, 'enzo.gp@gmail.com'),
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
(4, 'chleo.lamarre@gmail.com', 1),
(2, 'chleo.lamarre@gmail.com', 2),
(3, 'chleo.lamarre@gmail.com', 3),
(2, 'enzo.gp@gmail.com', 1),
(3, 'enzo.gp@gmail.com', 2),
(4, 'enzo.gp@gmail.com', 3),
(3, 'victor.mankowski@gmail.com', 1),
(4, 'victor.mankowski@gmail.com', 2),
(2, 'victor.mankowski@gmail.com', 3);

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
  MODIFY `act_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `t_candidature_cdt`
--
ALTER TABLE `t_candidature_cdt`
  MODIFY `cdt_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `t_categorie_cat`
--
ALTER TABLE `t_categorie_cat`
  MODIFY `cat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `t_concours_cnc`
--
ALTER TABLE `t_concours_cnc`
  MODIFY `cnc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
