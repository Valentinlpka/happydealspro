class Category {
  final String id;
  final String name;
  final List<String> allowedAttributes;

  Category(
      {required this.id, required this.name, required this.allowedAttributes});
}

List<Category> ecommerceCategories = [
  Category(
    id: 'cat_vetements',
    name: 'Vêtements',
    allowedAttributes: [
      'taille',
      'couleur',
      'matière',
      'marque',
      'genre',
      'saison',
      'style'
    ],
  ),
  Category(
    id: 'cat_chaussures',
    name: 'Chaussures',
    allowedAttributes: [
      'taille',
      'couleur',
      'matière',
      'marque',
      'genre',
      'style',
      'type'
    ],
  ),
  Category(
    id: 'cat_electronique',
    name: 'Électronique',
    allowedAttributes: [
      'marque',
      'modèle',
      'couleur',
      'capacité',
      'taille_ecran',
      'système_exploitation',
      'processeur',
      'ram',
      'stockage'
    ],
  ),
  Category(
    id: 'cat_informatique',
    name: 'Informatique',
    allowedAttributes: [
      'marque',
      'modèle',
      'type',
      'processeur',
      'ram',
      'stockage',
      'système_exploitation',
      'taille_ecran'
    ],
  ),
  Category(
    id: 'cat_livres',
    name: 'Livres',
    allowedAttributes: [
      'auteur',
      'editeur',
      'format',
      'genre',
      'langue',
      'date_publication',
      'isbn'
    ],
  ),
  Category(
    id: 'cat_musique',
    name: 'Musique',
    allowedAttributes: ['artiste', 'genre', 'format', 'date_sortie', 'label'],
  ),
  Category(
    id: 'cat_films',
    name: 'Films et Séries TV',
    allowedAttributes: [
      'réalisateur',
      'acteurs',
      'genre',
      'format',
      'durée',
      'année',
      'langue',
      'sous-titres'
    ],
  ),
  Category(
    id: 'cat_jeux_video',
    name: 'Jeux Vidéo',
    allowedAttributes: [
      'plateforme',
      'genre',
      'editeur',
      'developpeur',
      'pegi',
      'date_sortie',
      'mode_jeu'
    ],
  ),
  Category(
    id: 'cat_maison_jardin',
    name: 'Maison et Jardin',
    allowedAttributes: [
      'type',
      'matière',
      'couleur',
      'dimensions',
      'style',
      'marque'
    ],
  ),
  Category(
    id: 'cat_bricolage',
    name: 'Bricolage',
    allowedAttributes: [
      'type',
      'marque',
      'utilisation',
      'puissance',
      'dimensions',
      'poids'
    ],
  ),
  Category(
    id: 'cat_auto_moto',
    name: 'Auto et Moto',
    allowedAttributes: ['marque', 'modèle', 'année', 'type', 'compatibilité'],
  ),
  Category(
    id: 'cat_sports_loisirs',
    name: 'Sports et Loisirs',
    allowedAttributes: [
      'type',
      'marque',
      'taille',
      'couleur',
      'matière',
      'niveau'
    ],
  ),
  Category(
    id: 'cat_beaute_sante',
    name: 'Beauté et Santé',
    allowedAttributes: [
      'type',
      'marque',
      'ingrédients',
      'volume',
      'poids',
      'utilisation',
      'genre'
    ],
  ),
  Category(
    id: 'cat_jouets_jeux',
    name: 'Jouets et Jeux',
    allowedAttributes: ['age_recommandé', 'marque', 'type', 'matière', 'thème'],
  ),
  Category(
    id: 'cat_bijoux_montres',
    name: 'Bijoux et Montres',
    allowedAttributes: [
      'type',
      'matière',
      'pierre',
      'style',
      'marque',
      'genre'
    ],
  ),
  Category(
    id: 'cat_alimentaire',
    name: 'Alimentation',
    allowedAttributes: [
      'type',
      'marque',
      'ingrédients',
      'allergènes',
      'poids',
      'volume',
      'date_peremption',
      'origine',
      'régime'
    ],
  ),
  Category(
    id: 'cat_boissons',
    name: 'Boissons',
    allowedAttributes: [
      'type',
      'marque',
      'volume',
      'degré_alcool',
      'saveur',
      'origine',
      'année'
    ],
  ),
  Category(
    id: 'cat_animaux',
    name: 'Animalerie',
    allowedAttributes: [
      'type_animal',
      'marque',
      'age_recommandé',
      'poids',
      'ingrédients',
      'taille'
    ],
  ),
  Category(
    id: 'cat_bebe_puericulture',
    name: 'Bébé et Puériculture',
    allowedAttributes: [
      'age_recommandé',
      'type',
      'marque',
      'taille',
      'poids_max',
      'matière'
    ],
  ),
  Category(
    id: 'cat_instruments_musique',
    name: 'Instruments de Musique',
    allowedAttributes: [
      'type',
      'marque',
      'matière',
      'niveau',
      'accessoires_inclus'
    ],
  ),
  Category(
    id: 'cat_fournitures_bureau',
    name: 'Fournitures de Bureau',
    allowedAttributes: ['type', 'marque', 'couleur', 'dimensions', 'quantité'],
  ),
  Category(
    id: 'cat_art_artisanat',
    name: 'Art et Artisanat',
    allowedAttributes: ['type', 'marque', 'matière', 'technique', 'dimensions'],
  ),
  Category(
    id: 'cat_voyage_bagages',
    name: 'Voyage et Bagages',
    allowedAttributes: [
      'type',
      'marque',
      'dimensions',
      'poids',
      'matière',
      'capacité'
    ],
  ),
  Category(
    id: 'cat_services_numeriques',
    name: 'Services Numériques',
    allowedAttributes: [
      'type',
      'durée',
      'compatibilité',
      'fonctionnalités',
      'niveau_accès'
    ],
  ),
  Category(
    id: 'cat_logiciels',
    name: 'Logiciels',
    allowedAttributes: [
      'type',
      'editeur',
      'version',
      'système_compatible',
      'langue',
      'licence'
    ],
  ),
];
