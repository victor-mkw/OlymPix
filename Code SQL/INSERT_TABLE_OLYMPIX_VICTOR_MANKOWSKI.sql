INSERT INTO t_compte_cpt VALUES('organisateur@gmail.com', SHA2(CONCAT('OoL56T%','org24*PMYLO'), 512),'A');
INSERT INTO t_compte_cpt VALUES('rui.duarte@gmail.com', SHA2(CONCAT('OoL65T%', 'OrgN2#CnC29'), 512), 'A');
INSERT INTO t_compte_cpt VALUES('michel.blanc@gmail.com', SHA2(CONCAT('OoL65T%', 'OrgN3#CnC75'), 512), 'A');
INSERT INTO t_compte_cpt VALUES('anna.guillou@gmail.com', SHA2(CONCAT('OoL65T%', 'OrgN4#CnC92'), 512), 'A');
INSERT INTO t_compte_cpt VALUES('charles.carrefour@gmail.com', SHA2(CONCAT('OoL65T%', 'OrgN5#CnC45'), 512), 'A');
INSERT INTO t_compte_cpt VALUES('victor.mankowski@gmail.com', SHA2(CONCAT('OoL56T%','MdP2LoGin!'), 512),'A');
INSERT INTO t_compte_cpt VALUES('chleo.lamarre@gmail.com', SHA2(CONCAT('OoL56T%','COnExION95%'), 512),'A');
INSERT INTO t_compte_cpt VALUES('enzo.gp@gmail.com', SHA2(CONCAT('OoL56T%','LoGALaPplI@29'), 512), 'A');
INSERT INTO t_compte_cpt VALUES('legall.patrick@gmail.com', SHA2(CONCAT('OoL56T%','JuRy25#69PaT'), 512), 'D');
INSERT INTO t_compte_cpt VALUES('progamedev@gmail.com', SHA2(CONCAT('OoL56T%','JeSUiSlEBesTGD458@'), 512), 'A');

INSERT INTO t_administrateur_adm VALUES('organisateur@gmail.com', NULL, 'organisateur');
INSERT INTO t_administrateur_adm VALUES('rui.duarte@gmail.com', 'Rui', 'Duarte');
INSERT INTO t_administrateur_adm VALUES('michel.blanc@gmail.com', 'Michel', 'Blanc');
INSERT INTO t_administrateur_adm VALUES('anna.guillou@gmail.com', 'Anna', 'Guillou');
INSERT INTO t_administrateur_adm VALUES('charles.carrefour@gmail.com', 'Charles', 'Carrefour');

INSERT INTO t_jury_jry VALUES('victor.mankowski@gmail.com', 'Mankowski', 'Victor', 'Game Developer Senior', 'Je commence à apprendre le developpement de jeux vidéos en 2023...', NULL);
INSERT INTO t_jury_jry VALUES('chleo.lamarre@gmail.com', 'Lamarre', 'Chleo', 'Experte en psychologie', 'Diplomée d\'un Master en Psychologie Clinique...', NULL);
INSERT INTO t_jury_jry VALUES('enzo.gp@gmail.com', 'Pedra', 'Enzo', 'Pro gamer sur Mario Kart 8 Deluxe', 'Ayant de grande connaissance dans le domaine...', NULL);
INSERT INTO t_jury_jry VALUES('legall.patrick@gmail.com', 'Le Gall', 'Patrick', 'Expert en Game Design', 'Diplomé d\'un Master en Game Design...', NULL);
INSERT INTO t_jury_jry VALUES('progamedev@gmail.com', NULL, 'Pro Game Dev', 'Influenceur en Game Developpement', 'Je suis le pro du Game Developpement', NULL);

INSERT INTO t_concours_cnc VALUES(NULL, "Godot Jam #1", "Première JAM sur le moteur Godot; Le thème: Fragment", '2024-06-01', 45, 15, 2, 'organisateur@gmail.com');
INSERT INTO t_concours_cnc VALUES(NULL, "Godot Jam #2", "Seconde JAM sur le moteur Godot; Le thème: Nature", '2024-10-01', 7, 15, 7, 'organisateur@gmail.com');
INSERT INTO t_concours_cnc VALUES(NULL, "Unity Jam #1", "Première JAM sur le moteur Unity; Le thème: Grandeur", '2024-10-01', 15, 7, 7, 'rui.duarte@gmail.com');
INSERT INTO t_concours_cnc VALUES(NULL, "Unreal Jam #1", "Première JAM sur le moteur Unreal; Le thème: Populaire", '2024-10-01', 5, 5, 15, 'rui.duarte@gmail.com');
INSERT INTO t_concours_cnc VALUES(NULL, "Unity Jam #2", "Seconde JAM sur le moteur Unity; Le thème: Vitesse", '2024-11-01', 15, 7, 7, 'rui.duarte@gmail.com');

INSERT INTO t_categorie_cat VALUE(NULL,"Débutant");
INSERT INTO t_categorie_cat VALUE(NULL,"Junior");
INSERT INTO t_categorie_cat VALUE(NULL,"Senior");

INSERT INTO t_comprend_cmp VALUES(1,1);
INSERT INTO t_comprend_cmp VALUES(1,2);
INSERT INTO t_comprend_cmp VALUES(1,3);
INSERT INTO t_comprend_cmp VALUES(2,1);
INSERT INTO t_comprend_cmp VALUES(2,2);
INSERT INTO t_comprend_cmp VALUES(2,3);


--Note sur les états : S -> Sélectionné; P -> Pré-sélectionné; N -> Non pré-sélectionné
INSERT INTO t_candidature_cdt VALUES(NULL,'jbbrd@gmail.com', 'Broudin', 'Jean-Baptiste', 'Fan de jeux-vidéos', 'w3/nCd_Y5#z^ZG]v49U5', ';4t3[FxU', 'S', 1,1);
INSERT INTO t_candidature_cdt VALUES(NULL,'mker@gmail.com', 'Kerneis', 'Martin', 'Apprentis', 'sU9e2Y6~ff+!s=8V5{TU', ',NZ7p3a:', 'S', 1,1);
INSERT INTO t_candidature_cdt VALUES(NULL,'egou@gmail.com', 'Gouerec', 'Evan', 'Premier concours !', 'ke[@7P8(5LB}:fyJc7M3', '5aAb~2_T', 'S', 1,2);
INSERT INTO t_candidature_cdt VALUES(NULL,'flg@gmail.com', 'Le Guen', 'Frédérique', 'Je suis la pour gagner !', 'y2k-K~Q6$u85Es%DA6;c', 'c6%*5RYw', 'N', 1,2);
INSERT INTO t_candidature_cdt VALUES(NULL,'rcreff@gmail.com', 'Creff', 'Rose-Marie', 'Je découvre la programmation', '{F4y*L6=MDttH9.5+5jm', 'Pm8Y7m+-', 'S', 1,3);
INSERT INTO t_candidature_cdt VALUES(NULL,'obern@gmail.com', 'Berniere', 'Oskar', 'Je suis la pour apprendre', 'AY8),?h4!n}ApkLJ5w76', 'D3aL]@z2', 'N', 1,3);
INSERT INTO t_candidature_cdt VALUES(NULL,'jiva@gmail.com', 'Ivanoff', 'Jacques', 'Développeur confirmé', '.ze%:]9Zi6TZx#62LeE2', 'Pg4!6U=c', 'P', 2,2);
INSERT INTO t_candidature_cdt VALUES(NULL,'zmkw@gmail.com', 'Mankowski', 'Zelie', 'Découverte des concours !', 'n3m3^Q@R8PS?)pC3fw/2', '^3zdK{9V', 'N', 2,2);
INSERT INTO t_candidature_cdt VALUES(NULL,'lcas@gmail.com', 'Casemode', 'Lilou', 'La pour tout gagner', '5E(B2S82riR;aq_*Yj8[', 'D($h87qN', 'P', 2,3);
INSERT INTO t_candidature_cdt VALUES(NULL,'edam@gmail.com','Damota', 'Eva', 'Développeuse experte', '66URm$6,X-bk^R8tWc4(', 'r.bF58H)', 'P', 2,3);

INSERT INTO t_actualite_act VALUES (NULL,'Début du premier concours du Site !', 'Un max de lot à remporter dans toutes les catégories !', '2024-06-01', 'A', 'organisateur@gmail.com');
INSERT INTO t_actualite_act VALUES (NULL,'Fin du premier concours du Site !', 'Le palmarès est maintenant disponible dans la fiche du concours', '2024-06-25', 'A', 'organisateur@gmail.com');
INSERT INTO t_actualite_act VALUES (NULL,'Début du second concours du Site !', 'On espère vous voir nombreux à participer !', '2024-10-01', 'A', 'organisateur@gmail.com');

INSERT INTO t_juge_jge VALUES('victor.mankowski@gmail.com', 1);
INSERT INTO t_juge_jge VALUES('chleo.lamarre@gmail.com', 1);
INSERT INTO t_juge_jge VALUES('enzo.gp@gmail.com', 1);
INSERT INTO t_juge_jge VALUES('victor.mankowski@gmail.com', 2);
INSERT INTO t_juge_jge VALUES('legall.patrick@gmail.com', 2);
INSERT INTO t_juge_jge VALUES('progamedev@gmail.com', 2);

INSERT INTO t_fil_fil VALUES(NULL,'Délibération Concours 1', 1);
INSERT INTO t_fil_fil VALUES(NULL,'Délibération Concours 2', 2);

INSERT INTO t_message_msg VALUES(NULL,'J\'ai beaucoup aimé le travail de Jean-Baptiste', 1,'victor.mankowski@gmail.com');
INSERT INTO t_message_msg VALUES(NULL,'Le concept d\'Evan me parait plus poussé dans le thème', 1,'enzo.gp@gmail.com');
INSERT INTO t_message_msg VALUES(NULL,'J\'espère voir de beaux jeux sur ce concours', 2,'legall.patrick@gmail.com');
INSERT INTO t_message_msg VALUES(NULL,'Aucun jeu n\'égalera les miens', 2,'progamedev@gmail.com');

INSERT INTO t_notation_nte VALUES(4,'enzo.gp@gmail.com',3); 
INSERT INTO t_notation_nte VALUES(3,'enzo.gp@gmail.com',2);
INSERT INTO t_notation_nte VALUES(2,'enzo.gp@gmail.com',1);
INSERT INTO t_notation_nte VALUES(4,'victor.mankowski@gmail.com',2);
INSERT INTO t_notation_nte VALUES(3,'victor.mankowski@gmail.com',1);
INSERT INTO t_notation_nte VALUES(2,'victor.mankowski@gmail.com',3);
INSERT INTO t_notation_nte VALUES(4,'chleo.lamarre@gmail.com',1);
INSERT INTO t_notation_nte VALUES(3,'chleo.lamarre@gmail.com',3);
INSERT INTO t_notation_nte VALUES(2,'chleo.lamarre@gmail.com',2);

INSERT INTO t_document_doc VALUES(NULL,'Jeu de Martin', '/emplacement/2024-06-02jeu.exe', 'Executable Windows', 2);
INSERT INTO t_document_doc VALUES(NULL,'Jeu de Jean-Baptiste', '/emplacement/2024-06-06godotjamgame.exe', 'Executable Windows', 1);
INSERT INTO t_document_doc VALUES(NULL,'Jeu de Federique', '/emplacement/2024-06-03monjeu.exe', 'Executable Windows', 4);
