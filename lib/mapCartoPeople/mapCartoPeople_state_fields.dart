part of map_carto_people;

// Tout ce qui doit être visible par tous les fichiers "state_*"
extension _MapPeopleFields on _MapPeopleByCityState {
  // ⚠️ NE PAS mettre des champs ici -> on ne peut pas ajouter de fields dans une extension.
  // => Donc on met des getters statiques + fonctions utilitaires partagées.
}

// ✅ On garde les constantes ici (top-level), visibles dans tous les "part"
const String kUserAgentPackageName = 'fr.asconnexion.app';

// Filtres (valeurs attendues côté API)
const List<String> kGenotypeOptions = <String>[
  'Délétion',
  'Mutation',
  'UPD',
  'ICD',
  'Clinique',
  'Mosaïque',
];

// Tailles bulles
const double kMinSize = 20.0;
const double kMaxSize = 52.0;
// Courbure taille (gamma) — <1 gonfle petits cercles
const double kSizeCurveGamma = 0.65;
