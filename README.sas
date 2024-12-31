# Etude-statistique-performance-etudiants-SAS.

PROC IMPORT DATAFILE="C:\Mac\Home\Desktop\students.csv" 
            OUT=Students
            DBMS=CSV 
            REPLACE;
    GETNAMES= YES;  /* Utiliser les noms de colonnes de la première ligne */
RUN;

/* Analyse descriptive */
proc means data=work.students n mean median q1 q3 std var min max;
var _numeric_; /* Toutes les variables numériques */
run;

/* Diagramme à barres pour la répartition des genres */
proc sgplot data=work.students;
   vbar gender / datalabel fillattrs=(color=blue);
   xaxis label="Genre (0 = Homme, 1 = Femme)";
   yaxis label="Nombre d'Étudiants";
   title "Répartition des Genres (Bar Chart)";
run;

/* Diagramme à barres pour la répartition des niveaux d'éducation des parents */
proc sgplot data=work.students;
   vbar parental_level_of_education / datalabel fillattrs=(color=cyan);
   xaxis label="Niveau d'Éducation des Parents";
   yaxis label="Nombre d'Étudiants";
   title "Répartition des Niveaux d'Éducation des Parents (Bar Chart)";
run;

/* Histogramme avec courbe de densité pour Math_Score */
proc sgplot data=work.students;
   histogram math_score / transparency=0.5 fillattrs=(color=blue);
   density math_score / type=kernel lineattrs=(color=red thickness=2);
   density math_score / type=normal lineattrs=(color=green thickness=2);
   xaxis label="Math Score";
   yaxis label="Densité";
   title "Distribution de Math_Score";
run;

/* Histogramme avec courbe de densité pour Reading_Score */
proc sgplot data=work.students;
   histogram reading_score / transparency=0.5 fillattrs=(color=blue);
   density reading_score / type=kernel lineattrs=(color=red thickness=2);
   density reading_score / type=normal lineattrs=(color=green thickness=2);
   xaxis label="Reading Score";
   yaxis label="Densité";
   title "Distribution de Reading_Score";
run;

/* Histogramme avec courbe de densité pour Writing_Score */
proc sgplot data=work.students;
   histogram writing_score / transparency=0.5 fillattrs=(color=blue);
   density writing_score / type=kernel lineattrs=(color=red thickness=2);
   density writing_score / type=normal lineattrs=(color=green thickness=2);
   xaxis label="Writing Score";
   yaxis label="Densité";
   title "Distribution de Writing_Score";
run;


/* Transformation des données en format long */
data long_format;
   set work.students;
   length ScoreType $10;
   Score = math_score; ScoreType = "Math"; output;
   Score = reading_score; ScoreType = "Lecture"; output;
   Score = writing_score; ScoreType = "Écriture"; output;
run;

/* Création des boxplots comparatifs */
proc sgplot data=long_format;
   vbox Score / category=ScoreType fillattrs=(color=orange);
   yaxis label="Scores" grid;
   xaxis label="Type de Score";
   title "Boxplots des Scores (Math, Lecture, Écriture)";
run;


/* QUESTION 1 */
proc means data=work.students n mean median std min max;
   var reading_score;
   title "Analyse Univariée : Statistiques Descriptives du Reading Score";
run;
 
proc sgplot data=work.students;
   histogram reading_score / transparency=0.5 fillattrs=(color=blue);
   density reading_score / type=kernel lineattrs=(color=red);
   xaxis label="Reading Score";
   yaxis label="Fréquence";
   title "Histogramme : Distribution de Reading Score";
run;
 
proc sgplot data=work.students;
   vbox reading_score / fillattrs=(color=orange);
   xaxis label="Variable";
   yaxis label="Score";
   title "Boxplot : Répartition des Scores en Lecture";
run;


/* QUESTION 2 */
/* Test t : Comparaison des moyennes des scores de mathématiques selon le genre */ 
proc ttest data=work.students; class gender; /* Variable binaire : genre (0 = Homme, 1 = Femme) */ 
var math_score; /* Variable numérique : score en mathématiques */
run;


/* Test de Mann-Whitney-Wilcoxon pour comparer les scores entre les genres */
proc npar1way data=work.students wilcoxon;
class gender; /* Variable catégorique : genre (0 = Homme, 1 = Femme) */
var math_score; /* Variable numérique : score en mathématiques */
run;

/* QUESTION 3 */
proc freq data=work.students;
    tables race_ethnicity*parental_level_of_education / chisq;
run;


/* QUESTION 4 */
proc glm data=work.students;
    class race_ethnicity parental_level_of_education;
    model average_score = race_ethnicity parental_level_of_education 
                          race_ethnicity*parental_level_of_education / ss3;
run;


/* QUESTION 5 */
/* A - Régression multiple avec hypothèses */
proc glm data=work.students;
   class lunch test_preparation_course parental_level_of_education;
   model average_score = lunch test_preparation_course parental_level_of_education / solution;
   title "Modèle Théorique : Régression multiple sur les scores moyens";
run;

/* QUESTION 5 - f */
/* Ajustement du modèle */
proc reg data=work.students outest=estimates;
   model average_score = lunch test_preparation_course parental_level_of_education / r;
   output out=residuals p=predicted r=residual;
run;

/* 1. Graphique des résidus vs valeurs prédites (homoscédasticité) */
proc sgplot data=residuals;
   scatter x=predicted y=residual;
   refline 0 / axis=y lineattrs=(color=red);
   title "Graphique des Résidus vs Valeurs Prédites";
   xaxis label="Valeurs Prédites";
   yaxis label="Résidus";
run;

/* 2. Histogramme des résidus (normalité) */
proc univariate data=residuals normal;
   var residual;
   histogram residual / normal kernel;
   inset mean std / position=ne;
   title "Histogramme des Résidus avec Courbe de Densité";
run;

/* Boxplot des résidus par catégorie */
proc sgplot data=residuals;
   vbox residual / category=lunch;
   title "Boxplot des Résidus par Lunch";
   xaxis label="Lunch (0 = Repas réduit, 1 = Repas standard)";
   yaxis label="Résidus";
run;

proc sgplot data=residuals;
   vbox residual / category=test_preparation_course;
   title "Boxplot des Résidus par Test Preparation Course";
   xaxis label="Test Preparation Course (0 = Aucun cours, 1 = Cours suivi)";
   yaxis label="Résidus";
run;

proc sgplot data=residuals;
   vbox residual / category=parental_level_of_education;
   title "Boxplot des Résidus par Niveau d'Éducation des Parents";
   xaxis label="Parental Level of Education";
   yaxis label="Résidus";
run;




