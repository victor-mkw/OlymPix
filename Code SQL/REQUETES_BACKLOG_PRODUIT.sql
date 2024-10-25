--En tant que visiteur sprint 1 ⇒ 
--Actualités :
--1. Requête listant toutes les actualités de la table des actualités et leur auteur (login)
SELECT act_titre, act_texte, cpt_username FROM t_actualite_act;

--2. Requête donnant les données d'une actualité dont on connaît l'identifiant (n°)
SELECT * from t_actualite_act WHERE act_id = ID;

--3. Requête listant les 5 dernières actualités dans l'ordre décroissant
SELECT * FROM t_actualite_act ORDER BY act_date_publication DESC LIMIT 5;

--4. Requête recherchant et donnant la (ou les) actualité(s) contenant un mot particulier
A FAIRE

--5. Requête listant toutes les actualités postées à une date particulière + le login de l’auteur
SELECT act_titre, act_texte, cpt_username FROM t_actualite_act WHERE act_date_publication = '2024-10-17';

--sprint 3 ⇒ 
--6. Requête d'ajout d'une actualité
--7. Requête listant toutes les actualités postées par un auteur particulier (connaissant le login de l’administrateur connecté)
--8. Requête qui compte les actualités ajoutées avant une date précise
--9. Requête de modification d'une actualité
--10. Requête de suppression d'une actualité à partir de son ID (n°)


--En tant que visiteur sprint 1⇒
--Concours :
--1. Requête listant tous les concours de la plateforme (passés, en cours, à venir)
SELECT cnc_nom, cnc_description FROM t_concours_cnc;

--2. Requête (+code SQL) listant tous les concours de la plateforme (passés, en cours, à venir) avec leurs principales caractéristiques (organisateur responsable,
--date de début, dates intermédiaires, catégories, nom, prénom et discipline des juges)
SELECT t_concours_cnc.cpt_username, cnc_nom, cnc_description, cnc_date_debut, ADDDATE(cnc_date_debut, cnc_nb_jours_candidature) AS cnc_date_candidature, 
ADDDATE(cnc_date_debut, cnc_nb_jours_candidature + cnc_nb_jours_pre_selection) AS cnc_date_pre_selection, 
ADDDATE(cnc_date_debut, cnc_nb_jours_candidature + cnc_nb_jours_pre_selection + cnc_nb_jours_selection) AS cnc_date_selection,
cat_nom, jry_nom, jry_prenom, jry_description
FROM t_concours_cnc
JOIN t_comprend_cmp ON t_comprend_cmp.cnc_id = t_concours_cnc.cnc_id
JOIN t_categorie_cat ON t_comprend_cmp.cat_id = t_categorie_cat.cat_id
JOIN t_juge_jge ON t_concours_cnc.cnc_id = t_juge_jge.cnc_id
JOIN t_jury_jry ON t_juge_jge.cpt_username = t_jury_jry.cpt_username;

--3. Requête listant les concours qui ont débuté et leur phase actuelle (ex : finale)
SELECT cnc_nom, donner_phase_concours(cnc_id) FROM t_concours_cnc WHERE cnc_date_debut < CURDATE();

--4. Requête listant les concours à venir avec leur date de début
SELECT cnc_nom FROM t_concours_cnc WHERE cnc_date_debut >= CURDATE();

--5. Requête donnant toutes les caractéristiques d’un concours particulier (ID connu)
SELECT * FROM t_concours_cnc WHERE cnc_id = ID;

--6. Requête donnant les informations des membres du jury d’un concours particulier (ID connu)
SELECT jry_nom, jry_prenom, jry_description, jry_biographie, jry_url, t_concours_cnc.cnc_id FROM t_jury_jry 
JOIN t_juge_jge ON t_jury_jry.cpt_username = t_juge_jge.cpt_username
JOIN t_concours_cnc ON t_juge_jge.cnc_id = t_concours_cnc.cnc_id
WHERE t_concours_cnc.cnc_id = 1;

--7. Requête listant tous les membres de jury, classés par discipline, pour tous les concours de la plateforme


--8. Requête donnant la liste des catégories d’un concours particulier (ID connu)
--9. Requête listant de tous les administrateurs de la plateforme et les concours dont il est (/a été) responsable, s’il y en a

--sprint 2⇒
--10. Requête(s) listant tous les candidats pré-sélectionnés pour un concours particulier (ID connu) avec leurs principales données (nom, prénom, catégorie,
--date d’inscription, nombre de documents ressources téléversés)
--11. Requête(s) listant tous les candidats pré-sélectionnés classés par catégorie pour un concours particulier (ID connu)
--12. Requête donnant tous les noms des documents ressources d’un candidat (ID connu) pour un concours particulier (ID connu)
--13. Requête donnant le palmarès d’un concours particulier (ID connu) pour lequel la phase finale est terminée
--14. Requête donnant les palmarès ( nom / prénom / rang des 3 vainqueurs) des concours terminés (sans tenir compte des notes des juges au profil désactivé)


--En tant que candidat sprint 1⇒
--Inscription (ou candidature) :
--1. Requête vérifiant l’existence du couple de codes (identification / inscription)
--2. Requête d’affichage, si autorisé, de toutes les informations associées à une inscription connaissant le couple de code d’identification / code d’inscription

--sprint 2⇒
--3. Requête(s) d’insertion de toutes les données d’un candidat et de sa candidature, y compris ses documents ressources et sa catégorie
--4. Requête(s) de suppression d’une candidature connaissant le couple de code d’identification / code d’inscription


-- En tant qu’administrateur / En tant que membre du jury sprint 1⇒
-- Profils (administrateurs / membres du jury) :
-- 1. Requête listant toutes les données de tous les profils classés par statut
-- 2. Requête de vérification des données de connexion (login et mot de passe)
-- 3. Requête récupérant les données d'un profil particulier (utilisateur connecté)
-- 4. Requête de mise à jour du mot de passe d'un profil
-- 5. Requête d'ajout des données d'un profil administrateur (/ membre du jury)

-- sprint 2⇒
-- 6. Requête de désactivation d'un profil
-- 7. Requête(s) de suppression d’un profil administrateur / membre de jury et des 
-- données associées à ce profil (sans supprimer les données d’un concours démarré !)


-- En tant qu’administrateur sprint 2⇒
-- Concours / catégories / membres du jury / [+ disciplines] :
-- 1. Requête listant tous les concours ordonnés par leur date de début
-- 2. Requête listant tous les concours et leur(s) catégorie(s) et juges, s’il y en a
-- 3. Requête permettant à l’administrateur connecté l’insertion d’un concours et de ses données générales

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
-- 2. Requête listant toutes les candidatures classées par concours
-- 3. Requête listant toutes les candidatures pour un concours particulier
-- 4. Requête listant toutes les candidatures par catégorie pour un concours particulier
-- 5. Requête listant les candidatures d’un concours particulier selon leur état
-- 6. Requête donnant la liste des candidatures faites non pré-sélectionnées pour un concours particulier en phase de pré-sélection
-- 7. Requête (ou code SQL) modifiant l’état d’une candidature (ID connu)
-- 8. Requête donnant toutes les informations d’un candidat à partir de son ID (/ou de son code d’inscription au concours)
-- 9. Requête listant toutes les candidatures pré-sélectionnées classées par concours que le membre du jury connecté doit évaluer

-- En tant que membre du jury
-- 10. Requête pour vérifier si le juge connecté a déjà mis ses 4 points (/ 3 ou 2 points)
-- 11. Requête permettant au juge connecté d’attribuer une note à une candidature
-- 12. Requête permettant au juge connecté de modifier sa note pour une candidature
-- 13. Requête listant tous les candidats finalistes d’un concours (connaissant l’identifiant du membre de jury connecté)
-- et leur(s) points, s’ils en ont, en les classant dans l’ordre décroissant de leurs points (et en ne tenant compte que des
-- notes des juges dont le profil est activé)